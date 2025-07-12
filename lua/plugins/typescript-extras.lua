return {
  -- Show TypeScript errors in virtual text with better formatting
  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    event = "LspAttach",
    config = function()
      require("lsp_lines").setup()
      -- Disable virtual_text since lsp_lines replaces it
      vim.diagnostic.config({
        virtual_text = false,
      })
    end,
  },

  -- TypeScript hover information with better formatting
  {
    "rmagatti/goto-preview",
    event = "BufEnter",
    config = function()
      require("goto-preview").setup({
        width = 120,
        height = 25,
        default_mappings = false,
        debug = false,
        opacity = nil,
        post_open_hook = nil,
      })
    end,
    keys = {
      { "gpd", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>", desc = "Preview Definition" },
      {
        "gpt",
        "<cmd>lua require('goto-preview').goto_preview_type_definition()<CR>",
        desc = "Preview Type Definition",
      },
      { "gpi", "<cmd>lua require('goto-preview').goto_preview_implementation()<CR>", desc = "Preview Implementation" },
      { "gpr", "<cmd>lua require('goto-preview').goto_preview_references()<CR>", desc = "Preview References" },
      { "gP", "<cmd>lua require('goto-preview').close_all_win()<CR>", desc = "Close All Previews" },
    },
  },

  -- Better TypeScript error highlighting and type information
  {
    "folke/trouble.nvim",
    opts = {
      -- Remove icons config since LazyVim handles this
      fold_open = "v",
      fold_closed = ">",
      indent_lines = false,
    },
  },
}
