local text_filetypes = { "markdown", "text", "feature", "gitcommit" }

return {
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      -- Disable markdown linters completely
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.markdown = {}
      opts.linters_by_ft["markdown.mdx"] = {}
      return opts
    end,
  },
  {
    "tadmccorkle/markdown.nvim",
    enabled = false, -- Temporarily disabled due to treesitter compatibility issue
    ft = text_filetypes,
    opts = {},
    keys = {
      { "<leader>pf", "<cmd>MDTaskToggle<cr>", ft = text_filetypes, desc = "Toggle task checkbox" },
      {
        "<leader>pl",
        "<cmd>MDListItemBelow<cr>",
        ft = text_filetypes,
        desc = "Add list item below",
      },
      { "<leader>t", "]]", ft = text_filetypes, desc = "Next heading" },
      { "<leader>tl", "gliw", mode = "n", ft = text_filetypes, desc = "Add link to word" },
      { "<leader>tl", "gl", mode = "v", ft = text_filetypes, desc = "Add link (visual)" },
    },
  },
  {
    "bngarren/checkmate.nvim",
    ft = text_filetypes,
    opts = {
      files = {
        "*",
      },
      keys = false,
    },
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = text_filetypes,
    opts = {
      -- file_types = text_filetypes,
      code = {
        sign = false,
        width = "block",
        right_pad = 1,
      },
      heading = {
        sign = false,
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
      },
    },
  },
}
