return {
  -- Disable bufferline in favor of bento.nvim
  { "akinsho/bufferline.nvim", enabled = false },

  -- Bento: buffer manager with tabline
  {
    "3dyuval/bento.nvim",
    dev = true,
    lazy = false,
    opts = {
      main_keymap = ";",
      ui = {
        mode = "tabline",
        tabline = {
          separator_symbol = " ",
        },
      },
      highlights = {
        current = "Bold",
        active = "Normal",
        inactive = "Comment",
        modified = "DiagnosticWarn",
        label_minimal = "Comment",
        window_bg = "Normal",
        separator = "Comment",
      },
    },
  },
}
