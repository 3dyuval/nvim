return {
  {
    "folke/ts-comments.nvim",
    enabled = false, -- Using Comment.nvim instead
    opts = {},
    event = "VeryLazy",
  },
  {
    "numToStr/Comment.nvim",
    opts = {
      -- Enable basic commenting
      toggler = {
        line = "gcc", -- Line-comment toggle
        block = "gbc", -- Block-comment toggle
      },
      opleader = {
        line = "gc", -- Line-comment operator
        block = "gb", -- Block-comment operator
      },
      -- Extra mappings
      extra = {
        above = "gcO", -- Add comment above
        below = "gco", -- Add comment below
        eol = "gcA", -- Add comment at end of line
      },
    },
    event = "VeryLazy",
  },
}
