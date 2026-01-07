return {
  -- Disable friendly-snippets (use only custom snippets)
  { "rafamadriz/friendly-snippets", enabled = false },

  {
    "saghen/blink.cmp",

    opts = {
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        per_filetype = {
          sql = { "dadbod", "buffer" },
          mysql = { "dadbod", "buffer" },
          plsql = { "dadbod", "buffer" },
          -- Disable snippets for JS/TS/Vue (use LSP completions only)
          javascript = { "lsp", "path", "buffer" },
          javascriptreact = { "lsp", "path", "buffer" },
          typescript = { "lsp", "path", "buffer" },
          typescriptreact = { "lsp", "path", "buffer" },
          vue = { "lsp", "path", "snippets", "buffer" }, -- custom snippets only (friendly-snippets disabled)
          html = { "lsp", "path", "buffer" },
          css = { "lsp", "path", "buffer" },
          scss = { "lsp", "path", "buffer" },
          json = { "lsp", "path", "buffer" },
        },
        providers = {
          lsp = {
            name = "lsp",
            enabled = true,
            module = "blink.cmp.sources.lsp",
            fallbacks = { "buffer" },
          },
          dadbod = {
            name = "Dadbod",
            module = "vim_dadbod_completion.blink",
          },
        },
      },
      completion = {
        accept = {
          auto_brackets = {
            enabled = true,
            default_brackets = { "(", ")" },
            kind_resolution = {
              enabled = true,
              blocked_filetypes = { "typescriptreact", "javascriptreact", "typescript", "javascript" },
            },
            semantic_token_resolution = {
              enabled = true,
              blocked_filetypes = { "typescriptreact", "javascriptreact", "typescript", "javascript" },
              timeout_ms = 400,
            },
          },
        },
      },
    },
  },
}
