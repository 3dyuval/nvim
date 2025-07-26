-- Minimal init for tests (inspired by conform.nvim)
vim.cmd([[set runtimepath+=.]])

vim.o.swapfile = false
vim.bo.swapfile = false

-- Basic setup for testing
vim.opt.termguicolors = true
vim.opt.hidden = true

-- Load our config modules for testing
require("config.lazy")
require("config.options")

-- Simple test helper
_G.test_util = {
	reset_editor = function()
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
				vim.api.nvim_buf_delete(buf, { force = true })
			end
		end
		vim.cmd("silent! %bwipeout!")
	end,
}
