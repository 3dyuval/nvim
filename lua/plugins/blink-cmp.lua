return {
  "saghen/blink.cmp",
  opts = {
    completion = {
      accept = {
        auto_brackets = {
          enabled = true,
          default_brackets = { "(", ")" },
          kind_resolution = {
            enabled = true,
            blocked_filetypes = { 'typescriptreact', 'javascriptreact', 'typescript', 'javascript' },
          },
          semantic_token_resolution = {
            enabled = true,
            blocked_filetypes = { 'typescriptreact', 'javascriptreact', 'typescript', 'javascript' },
            timeout_ms = 400,
          },
        },
      },
    },
  },
}