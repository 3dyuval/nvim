return {
  "saghen/blink.cmp",

  opts = {
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
      per_filetype = {
        sql = { "dadbod", "buffer" },
        mysql = { "dadbod", "buffer" },
        plsql = { "dadbod", "buffer" },
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
}
