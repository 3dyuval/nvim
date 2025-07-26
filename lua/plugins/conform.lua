return {
	"stevearc/conform.nvim",
	dependencies = { "williamboman/mason.nvim" }, -- Ensure Mason loads first
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			typescript = { "biome", "biome-organize-imports" },
			javascript = { "biome", "biome-organize-imports" },
			typescriptreact = { "biome", "biome-organize-imports" },
			javascriptreact = { "biome", "biome-organize-imports" },
			json = { "biome" },
			html = { "prettier" },
			htmlangular = { "prettier" },
			vue = { "prettier" },
			css = { "prettier" },
			scss = { "prettier" },
		},
		-- formatters = {
		--   -- Remove custom biome config to use standard auto-discovery
		--   -- Both biome and biome-organize-imports will now use util.root_file()
		-- },
	},
}
