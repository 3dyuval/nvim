local text_filetypes = { "markdown", "text", "feature", "gitcommit" }

return {
  -- markdown-preview.nvim (from LazyVim) - add keymaps
  {
    "iamcco/markdown-preview.nvim",
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", ft = "markdown", desc = "Markdown preview" },
    },
  },
  {
    "folke/todo-comments.nvim",
    cmd = { "TodoTrouble" },
    event = "LazyFile",
    opts = {},
    -- moved to ../config/keymaps.lua
  },
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
    enabled = true,

    ft = text_filetypes,
    opts = {
      -- Move emphasis surround off ds/cs so nvim-surround's ds/cs win in
      -- markdown (ds( etc. was being shadowed). Kept on the g-surround
      -- namespace alongside gs/gss.
      mappings = {
        inline_surround_delete = "gsd",
        inline_surround_change = "gsc",
      },
    },
    keys = {
      { "<leader>pf", "<cmd>MDTaskToggle<cr>", ft = text_filetypes, desc = "Toggle task checkbox" },
      {
        "<leader>pl",
        "<cmd>MDListItemBelow<cr>",
        ft = text_filetypes,
        desc = "Add list item below",
      },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = text_filetypes,
    opts = {
      enabled = true,
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
    keys = {
      { "<leader>um", ":RenderMarkdown toggle<cr>", ft = text_filetypes, desc = "Toggle render markdown" },
    },
  },
}
