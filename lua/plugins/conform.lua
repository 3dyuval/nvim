return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      typescript = { "biome" },
      javascript = { "biome" },
      typescriptreact = { "biome" },
      javascriptreact = { "biome" },
      json = { "biome" },
      html = { "prettier" },
      htmlangular = { "prettier" },
      vue = { "prettier" },
    },
    formatters = {
      prettier = {
        args = { "--config", vim.fn.stdpath("config") .. "/.prettierrc", "--stdin-filepath", "$FILENAME" },
      },
    },
    -- Enable format on save
    -- format_on_save = {
    -- timeout_ms = 500,
    -- lsp_fallback = true,
    -- },
  },
}
