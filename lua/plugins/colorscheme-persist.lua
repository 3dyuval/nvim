return {
  -- Set initial colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "ashen",
    },
  },

  -- Override the colorscheme picker to persist changes
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      {
        "<leader>uC",
        function()
          require("telescope.builtin").colorscheme({
            enable_preview = true,
            attach_mappings = function(prompt_bufnr, _)
              local actions = require("telescope.actions")
              actions.select_default:replace(function()
                local selection = require("telescope.actions.state").get_selected_entry()
                actions.close(prompt_bufnr)
                vim.cmd.colorscheme(selection.value)

                -- Update the config file directly
                local config_file = vim.fn.stdpath("config")
                  .. "/lua/plugins/colorscheme-persist.lua"
                local content = vim.fn.readfile(config_file)

                -- Find and replace the colorscheme line
                for i, line in ipairs(content) do
                  if line:match('colorscheme%s*=%s*"') then
                    content[i] = string.format('      colorscheme = "%s",', selection.value)
                    break
                  end
                end

                vim.fn.writefile(content, config_file)
              end)
              return true
            end,
          })
        end,
        desc = "Colorscheme with preview (persistent)",
      },
    },
  },

  -- Auto-apply colorscheme changes across all sessions
  {
    "folke/lazy.nvim",
    config = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyReload",
        callback = function()
          vim.schedule(function()
            -- Reload this file to get the updated colorscheme
            package.loaded["plugins.colorscheme-persist"] = nil
            local config = require("plugins.colorscheme-persist")
            local colorscheme = nil
            for _, plugin in ipairs(config) do
              if plugin[1] == "LazyVim/LazyVim" and plugin.opts then
                colorscheme = plugin.opts.colorscheme
                break
              end
            end
            if colorscheme then
              vim.cmd.colorscheme(colorscheme)
            end
          end)
        end,
      })
    end,
  },
}
