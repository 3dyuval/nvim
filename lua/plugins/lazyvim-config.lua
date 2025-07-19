return {
	{
		"LazyVim/LazyVim",
		init = function()
			-- Override the default wrap_spell autocmd to disable spell checking
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("override_wrap_spell", { clear = true }),
				pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
				callback = function()
					vim.opt_local.wrap = true
					vim.opt_local.spell = false -- disable spell by default
				end,
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		init = function()
			local keys = require("lazyvim.plugins.lsp.keymaps").get()
			-- Disable the default <leader>cr code action binding
			keys[#keys + 1] = { "<leader>cr", false }
		end,
	},
}
