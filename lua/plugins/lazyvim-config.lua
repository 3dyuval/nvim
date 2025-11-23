return {
  {
    "LazyVim/LazyVim",
    init = function()
      -- Override the default wrap_spell autocmd to disable spell checking
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("override_wrap_spell", { clear = true }),
        pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
        callback = function()
          vim.opt_local.wrap = true
          vim.opt_local.spell = false -- disable spell by default
        end,
      })
    end,
  },

  -- Enable colorschemes used by omarchy themes
  { "folke/tokyonight.nvim", enabled = true },
  { "catppuccin/nvim", name = "catppuccin", enabled = true },
  { "ellisonleao/gruvbox.nvim", enabled = true },
  { "rebelot/kanagawa.nvim", enabled = true },
  { "rose-pine/neovim", name = "rose-pine", enabled = true },
  { "sainnhe/everforest", enabled = true },
  { "loctvl842/monokai-pro.nvim", enabled = true },
  { "marko-cerovac/material.nvim", enabled = true },
  { "AlexvZyl/nordic.nvim", enabled = true },
  { "ribru17/bamboo.nvim", enabled = true },
  { "kepano/flexoki-neovim", name = "flexoki", enabled = true },
  -- Disable unused LazyVim defaults
  { "Mofiqul/dracula.nvim", enabled = false },
  { "navarasu/onedark.nvim", enabled = false },
  { "EdenEast/nightfox.nvim", enabled = false },
  -- Note: LSP keymaps are now consolidated in lua/plugins/lsp-keymaps.lua
}
