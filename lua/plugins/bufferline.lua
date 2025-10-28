return {
  "akinsho/bufferline.nvim",
  dependencies = {
    "lewis6991/gitsigns.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    options = {
      animation = true,
      truncate_names = true,
      termguicolors = false,
      separator_style = "slant",
      groupns = {
        items = {
          require("bufferline.groups").builtin.pinned:with({ icon = " " }),
        },
      },
    },
    highlights = {
      fill = {
        bg = {
          attribute = "fg",
          highlight = "Pmenu",
        },
      },
      buffer_selected = {
        bold = true,
        italic = false,
      },
    },
  },
}
