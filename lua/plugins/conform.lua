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
    },
    -- Enable format on save
    -- format_on_save = {
    -- timeout_ms = 500,
    -- lsp_fallback = true,
    -- },
  },
}
