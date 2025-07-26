return {
	"kevinhwang91/nvim-ufo",
	dependencies = {
		"kevinhwang91/promise-async",
	},
	event = "BufReadPost",
	opts = {
		-- Use treesitter for folding
		provider_selector = function(bufnr, filetype, buftype)
			return { "treesitter", "indent" }
		end,
		-- Simple fold text with line count
		fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
			local newVirtText = {}
			local suffix = (" 󰁂 %d "):format(endLnum - lnum)
			local sufWidth = vim.fn.strdisplaywidth(suffix)
			local targetWidth = width - sufWidth
			local curWidth = 0
			for _, chunk in ipairs(virtText) do
				local chunkText = chunk[1]
				local chunkWidth = vim.fn.strdisplaywidth(chunkText)
				if targetWidth > curWidth + chunkWidth then
					table.insert(newVirtText, chunk)
				else
					chunkText = truncate(chunkText, targetWidth - curWidth)
					local hlGroup = chunk[2]
					table.insert(newVirtText, { chunkText, hlGroup })
					chunkWidth = vim.fn.strdisplaywidth(chunkText)
					if curWidth + chunkWidth < targetWidth then
						suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
					end
					break
				end
				curWidth = curWidth + chunkWidth
			end
			table.insert(newVirtText, { suffix, "MoreMsg" })
			return newVirtText
		end,
	},
	config = function(_, opts)
		require("ufo").setup(opts)

		-- Ensure foldlevel is respected
		vim.o.foldlevel = 99
		vim.o.foldlevelstart = 99

		-- Simple import folding for TS files only
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "typescript", "typescriptreact" },
			callback = function()
				vim.defer_fn(function()
					-- Only fold consecutive import lines at the start of file
					local lines = vim.api.nvim_buf_get_lines(0, 0, 20, false)
					local import_start, import_end = nil, nil

					for i, line in ipairs(lines) do
						if line:match("^import ") then
							if not import_start then
								import_start = i
							end
							import_end = i
						elseif import_start and not line:match("^%s*$") then
							break -- Stop at first non-import, non-empty line
						end
					end

					if import_start and import_end and (import_end - import_start) >= 2 then
						-- Use UFO's API instead of vim's fold command to avoid foldmethod conflicts
						pcall(function()
							-- Temporarily set foldmethod to manual for creating folds
							local old_foldmethod = vim.wo.foldmethod
							vim.wo.foldmethod = "manual"
							vim.cmd(import_start .. "," .. import_end .. "fold")
							vim.wo.foldmethod = old_foldmethod
						end)
					end
				end, 100)
			end,
		})
	end,
}
