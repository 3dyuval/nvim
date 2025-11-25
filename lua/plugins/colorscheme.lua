-- Colorscheme configuration
-- This file is managed by omarchy-theme-set-neovim

return {
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    opts = {
      transparent_background = true,
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight-night",
    },
  },
}
