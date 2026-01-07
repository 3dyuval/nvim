return {
  -- Disable bufferline in favor of bento.nvim
  { "akinsho/bufferline.nvim", enabled = false },

  -- Bento: buffer manager with tabline
  {
    "serhez/bento.nvim",
    opts = {
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
