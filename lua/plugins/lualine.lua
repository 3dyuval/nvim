return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    local function formatter_status()
      local buf = vim.api.nvim_get_current_buf()

      -- Use the same logic as js_formatter to get actual formatters
      local filetype = vim.bo[buf].filetype
      local formatters

      -- For JS/TS files, use our custom logic
      if vim.tbl_contains({ "javascript", "typescript", "javascriptreact", "typescriptreact", "json" }, filetype) then
        local bufname = vim.api.nvim_buf_get_name(buf)
        local dirname = vim.fn.fnamemodify(bufname, ":h")

        local prettier_configs = {
          ".prettierrc",
          ".prettierrc.json",
          ".prettierrc.yml",
          ".prettierrc.yaml",
          ".prettierrc.json5",
          ".prettierrc.js",
          ".prettierrc.cjs",
          ".prettierrc.mjs",
          ".prettierrc.toml",
          "prettier.config.js",
          "prettier.config.cjs",
          "prettier.config.mjs",
        }

        local has_prettier = vim.fs.find(prettier_configs, { path = dirname, upward = true, limit = 1 })[1] ~= nil
        local has_biome = vim.fs.find({ "biome.json", "biome.jsonc" }, { path = dirname, upward = true, limit = 1 })[1]
          ~= nil

        if has_prettier then
          formatters = { { name = "prettier" } }
        elseif has_biome then
          formatters = { { name = "biome" } }
        else
          formatters = { { name = "biome" } } -- Default fallback
        end
      else
        formatters = require("conform").list_formatters(buf)
      end

      if #formatters == 0 then
        return ""
      end

      local formatter_icons = {
        prettier = "", -- Prettier icon
        biome = "", -- Plant/leaf icon for Biome
        stylua = "󰢱", -- Lua icon
        eslint = "󰱺", -- ESLint icon
      }

      local function get_config_status(formatter_name)
        local dirname = vim.fn.expand("%:p:h")
        local config_files = {
          prettier = { ".prettierrc", ".prettierrc.json", ".prettierrc.js", "prettier.config.js" },
          biome = { "biome.json", "biome.jsonc" },
          stylua = { ".stylua.toml", "stylua.toml" },
          eslint = { ".eslintrc", ".eslintrc.json", ".eslintrc.js", "eslint.config.js" },
        }

        if config_files[formatter_name] then
          local found = vim.fs.find(config_files[formatter_name], {
            path = dirname,
            upward = true,
            limit = 1,
          })[1]
          return found and " " or " 󱁽" -- Local config vs global/fallback
        end
        return " " -- Default to local
      end

      local result = {}
      for _, formatter in ipairs(formatters) do
        local icon = formatter_icons[formatter.name] or "󰉿"
        local config_icon = get_config_status(formatter.name)
        table.insert(result, icon .. config_icon)
      end

      return table.concat(result, " ")
    end

    -- Interview timer countdown
    table.insert(opts.sections.lualine_z, {
      function()
        return require("timers.integrations.lualine").closest_timer()
      end,
      color = "WarningMsg",
    })

    -- Add formatter status component with click handler
    table.insert(opts.sections.lualine_b, {
      formatter_status,
      on_click = function()
        local buf = vim.api.nvim_get_current_buf()
        local formatters = require("conform").list_formatters(buf)

        if #formatters == 0 then
          vim.notify("No formatters available", vim.log.levels.INFO)
          return
        end

        -- Find config file for the first formatter
        local formatter = formatters[1]
        local dirname = vim.fn.expand("%:p:h")
        local config_files = {
          prettier = { ".prettierrc", ".prettierrc.json", ".prettierrc.js", "prettier.config.js" },
          biome = { "biome.json", "biome.jsonc" },
          stylua = { ".stylua.toml", "stylua.toml" },
          eslint = { ".eslintrc", ".eslintrc.json", ".eslintrc.js", "eslint.config.js" },
        }

        local formatter_configs = config_files[formatter.name]
        if formatter_configs then
          local found_config = vim.fs.find(formatter_configs, {
            path = dirname,
            upward = true,
            limit = 1,
          })[1]

          if found_config then
            vim.cmd("edit " .. found_config)
          else
            -- Open fallback config
            local fallback_config = vim.fn.stdpath("config") .. "/" .. formatter_configs[1]
            if vim.fn.filereadable(fallback_config) == 1 then
              vim.cmd("edit " .. fallback_config)
            else
              vim.notify("No config file found for " .. formatter.name, vim.log.levels.WARN)
            end
          end
        else
          vim.notify("Unknown formatter: " .. formatter.name, vim.log.levels.WARN)
        end
      end,
    })

    return opts
  end,
}
