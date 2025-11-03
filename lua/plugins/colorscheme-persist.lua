return {
  -- Set initial colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "material-deep-ocean",
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
