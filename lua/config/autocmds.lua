-- restore cursor to file position in previous editing session
vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function(args)
		local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
		local line_count = vim.api.nvim_buf_line_count(args.buf)
		if mark[1] > 0 and mark[1] <= line_count then
			vim.api.nvim_buf_call(args.buf, function()
				vim.cmd('normal! g`"zz')
			end)
		end
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "snacks_win", "snacks_picker", "snacks_explorer" },
	callback = function()
		vim.opt_local.swapfile = false
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "javascript", "typescript", "json", "lua", "python", "css", "scss" },
	callback = function()
		-- Auto-pair configuration for specific filetypes
		-- The mini.pairs plugin handles {} expansion automatically
	end,
})

vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Disable "modifiable is off" notifications globally
vim.opt.shortmess:append("F")

-- Enable syntax highlighting for log files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.log",
	callback = function()
		vim.bo.filetype = "log"
	end,
})

vim.api.nvim_create_user_command("CopyLocation", function(opts)
	local filepath = vim.fn.expand("%:p")
	local line = vim.fn.line(".")
	local col = vim.fn.col(".")

	-- Different format options
	local formats = {
		default = "%s:%d:%d",
		relative = "%s:%d:%d", -- Will use relative path
		simple = "%s (line %d)",
		github = "%s#L%d", -- GitHub-style link format
	}

	-- Use relative path if requested
	if opts.args == "rel" or opts.args == "relative" then
		filepath = vim.fn.expand("%:.") -- Relative to cwd
	elseif opts.args == "name" then
		filepath = vim.fn.expand("%:t") -- Just filename
	end

	local format = formats[opts.args] or formats.default
	local location = string.format(format, filepath, line, col)

	vim.fn.setreg("+", location)
	print("Copied: " .. location)
end, {
	nargs = "?",
	complete = function()
		return { "rel", "relative", "name", "github", "simple" }
	end,
})
