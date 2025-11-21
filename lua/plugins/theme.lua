return {
  {
    "marko-cerovac/material.nvim",
    priority = 1000,
    opts = {
      contrast = {
        terminal = false,
        sidebars = false,
        floating_windows = false,
        cursor_line = false,
        non_current_windows = false,
        filetypes = {},
      },
      styles = {
        comments = { italic = true },
        strings = {},
        keywords = {},
        functions = {},
        variables = {},
      },
      plugins = {
        "gitsigns",
        "nvim-cmp",
        "nvim-tree",
        "telescope",
        "which-key",
      },
      disable = {
        colored_cursor = false,
        borders = false,
        background = false,
        term_colors = false,
        eob_lines = false,
      },
      high_visibility = {
        lighter = false,
        darker = false,
      },
      lualine_style = "default",
      async_loading = true,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "material-palenight",
    },
  },
}
