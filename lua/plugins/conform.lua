return {
  "stevearc/conform.nvim",
  dependencies = { "williamboman/mason.nvim" }, -- Ensure Mason loads first
  opts = {
    formatters_by_ft = {
      typescript = { "prettier", "biome" },
      javascript = { "prettier", "biome" },
      typescriptreact = { "prettier", "biome" },
      javascriptreact = { "prettier", "biome" },
      json = { "biome" },
      html = { "prettier" },
      htmlangular = { "prettier" },
      vue = { "prettier" },
    },
    formatters = {
      biome = {
        args = {
          "format",
          "--config-path",
          vim.fn.stdpath("config") .. "/biome.json",
          "--stdin-file-path",
          "$FILENAME",
        },
      },
      -- prettier config would go here if you need to override it
    },
  },
}
