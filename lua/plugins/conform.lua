function js_formatter(bufnr)
  -- Get the directory of the current buffer
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local dirname = vim.fn.fnamemodify(bufname, ":h")

  -- Use conform's built-in config definitions
  local util = require("conform.util")

  -- Simple check using vim.fs.find (more reliable)
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

  local has_prettier = vim.fs.find(prettier_configs, {
    path = dirname,
    upward = true,
    limit = 1,
  })[1] ~= nil

  local has_biome = vim.fs.find({ "biome.json", "biome.jsonc" }, {
    path = dirname,
    upward = true,
    limit = 1,
  })[1] ~= nil

  -- Return formatter based on what's available
  -- Prefer prettier if both exist
  if has_prettier then
    return { "prettier" }
  elseif has_biome then
    return { "biome" }
  else
    -- Default to biome if no configs found (will use nvim fallback)
    return { "biome" }
  end
end

return {
  "stevearc/conform.nvim",
  dependencies = { "williamboman/mason.nvim" }, -- Ensure Mason loads first
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      typescript = function(bufnr)
        return js_formatter(bufnr)
      end,
      javascript = function(bufnr)
        return js_formatter(bufnr)
      end,
      typescriptreact = function(bufnr)
        return js_formatter(bufnr)
      end,
      javascriptreact = function(bufnr)
        return js_formatter(bufnr)
      end,
      json = function(bufnr)
        return js_formatter(bufnr)
      end,
      html = { "prettier" },
      htmlangular = { "prettier" },
      vue = { "biome" },
      css = { "biome" },
      scss = { "biome" },
    },
    formatters = {
      -- Only override when we want different behavior
      biome = {
        inherit = true, -- Keep all default settings
        args = function(self, ctx)
          -- Let conform find config normally
          local util = require("conform.util")
          local config_path = util.root_file({ "biome.json", "biome.jsonc" })(self, ctx)

          if config_path then
            -- Use default behavior
            return { "format", "--stdin-file-path", "$FILENAME" }
          else
            -- Fallback to nvim config
            return {
              "format",
              "--config-path",
              vim.fn.stdpath("config") .. "/biome.json",
              "--stdin-file-path",
              "$FILENAME",
            }
          end
        end,
      },
      prettier = {
        inherit = true,
        args = function(self, ctx)
          -- Check using conform's own method
          local prettierd = require("conform.formatters.prettierd")
          local has_config = prettierd.cwd(self, ctx)

          if has_config then
            return { "--stdin-filepath", "$FILENAME" }
          else
            return {
              "--config",
              vim.fn.stdpath("config") .. "/.prettierrc",
              "--stdin-filepath",
              "$FILENAME",
            }
          end
        end,
      },
      -- Stylua already handles --search-parent-directories, so we just add fallback
      stylua = {
        inherit = true,
        prepend_args = function(self, ctx)
          local util = require("conform.util")
          local has_config = util.root_file({ ".stylua.toml", "stylua.toml" })(self, ctx)

          if not has_config then
            -- Add config path before other args
            return { "--config-path", vim.fn.stdpath("config") .. "/stylua.toml" }
          end
          return {}
        end,
      },
    },
  },
}
