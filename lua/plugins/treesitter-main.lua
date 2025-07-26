return {
	"nvim-treesitter/nvim-treesitter",
	opts = function(_, opts)
		-- Ensure JSX/TSX parsers are installed
		opts.ensure_installed = opts.ensure_installed or {}
		vim.list_extend(opts.ensure_installed, {
			"javascript",
			"typescript",
			"tsx",
			"html",
			"css",
		})

		-- Enable autotag integration (Takuya's way)
		opts.autotag = {
			enable = true,
		}

		-- Add error handling for highlighting
		opts.highlight = opts.highlight or {}
		opts.highlight.additional_vim_regex_highlighting = false
		opts.highlight.disable = function(lang, buf)
			-- Disable for large files or if buffer is invalid
			local max_filesize = 100 * 1024 -- 100 KB
			local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
			if ok and stats and stats.size > max_filesize then
				return true
			end

			-- Check if buffer is valid
			return not vim.api.nvim_buf_is_valid(buf)
		end

		return opts
	end,
}
