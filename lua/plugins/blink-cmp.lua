return {
  "saghen/blink.cmp",
  opts = {
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
      providers = {
        lsp = {
          name = "lsp",
          enabled = true,
          module = "blink.cmp.sources.lsp",
          fallbacks = { "buffer" },
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
}
