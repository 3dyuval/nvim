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
  { "neanias/everforest-nvim", enabled = true },
  { "gthelding/monokai-pro.nvim", enabled = true },
  { "marko-cerovac/material.nvim", enabled = true },
  { "shaunsingh/nord.nvim", enabled = true, name = "nord" },
  { "AlexvZyl/nordic.nvim", enabled = false },
  { "ribru17/bamboo.nvim", enabled = true },
  { "kepano/flexoki-neovim", name = "flexoki", enabled = true },
  { "tahayvr/matteblack.nvim", enabled = true },
  { "bjarneo/aether.nvim", enabled = true },
  { "bjarneo/hackerman.nvim", enabled = true },
  {
    "3dyuval/retro-fallout.nvim",
    dependencies = {
      { "3dyuval/colortweak.nvim" },
    },
    lazy = false,
    priority = 1000,
    config = function()
      require("retro-fallout").setup({
        transparent = false,
        dim_inactive = false,
        dim_snacks_bg = true,
        colors = {
          dimmed = {
            s = -100,
          },
        },
        ft = {
          yaml = {
            h = 180,
            s = 100,
          },
        },
      })
    end,
  },
  -- Disable unused LazyVim defaults
  { "Mofiqul/dracula.nvim", enabled = false },
  { "navarasu/onedark.nvim", enabled = false },
  { "EdenEast/nightfox.nvim", enabled = false },
  { "sainnhe/everforest", enabled = false },
  { "loctvl842/monokai-pro.nvim", enabled = false },
  -- Note: LSP keymaps are now consolidated in lua/plugins/lsp-keymaps.lua
}
