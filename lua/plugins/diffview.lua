return {
	"sindrets/diffview.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	cmd = { "DiffviewOpen", "DiffviewFileHistory" },
	config = function()
		local ok, diffview = pcall(require, "diffview")
		if not ok then
			vim.notify("Failed to load diffview.nvim", vim.log.levels.ERROR)
			return
		end

		diffview.setup({
			enhanced_diff_hl = true, -- Better word-level diff highlighting
			use_icons = true,
			show_help_hints = true, -- Show keyboard shortcuts
			watch_index = true, -- Update automatically
			-- Default args to ensure proper merge conflict handling
			default_args = {
				DiffviewOpen = { "--imply-local" },
				DiffviewFileHistory = {},
			},
			view = {
				default = {
					layout = "diff2_horizontal",
					winbar_info = true,
				},
				merge_tool = {
					layout = "diff3_horizontal",
					disable_diagnostics = true,
					winbar_info = true,
				},
				file_history = {
					layout = "diff2_horizontal",
					winbar_info = false,
				},
			},
			diff_binaries = false,
			hooks = {
				diff_buf_read = function()
					-- Disable folding in diff buffers with error handling
					local ok, err = pcall(function()
						vim.opt_local.foldenable = false
					end)
					if not ok then
						vim.notify("Error in diff_buf_read hook: " .. tostring(err), vim.log.levels.WARN)
					end
				end,
			},
			file_panel = {
				listing_style = "tree",
				tree_options = {
					flatten_dirs = true,
					folder_statuses = "only_folded",
				},
				win_config = {
					position = "left",
					width = 40, -- Slightly wider to show stats
				},
			},
			keymaps = {
				view = {
					-- Disable default conflict resolution keymaps to avoid conflicts
					["<leader>co"] = false,
					["<leader>ct"] = false,
					["<leader>cb"] = false,
					["<leader>ca"] = false,
					["<leader>cO"] = false,
					["<leader>cT"] = false,
					["<leader>cB"] = false,
					["<leader>cA"] = false,
					["dx"] = false, -- Disable default conflict delete
					["dX"] = false, -- Disable default conflict delete all

					["q"] = "<Cmd>DiffviewClose<CR>",

					-- Smart diff/conflict operations using Tree-sitter
					{
						"n",
						"go",
						function()
							local function is_in_conflict()
								local ok, parser = pcall(vim.treesitter.get_parser, 0)
								if not ok then
									return false
								end

								local row = vim.api.nvim_win_get_cursor(0)[1] - 1
								local query = vim.treesitter.query.get(parser:lang(), "conflict")

								if query then
									local tree = parser:parse()[1]
									for _, node in query:iter_captures(tree:root(), 0, row, row + 1) do
										return true
									end
								end
								return false
							end

							if is_in_conflict() then
								require("diffview.actions").conflict_choose("theirs")
							else
								-- For 3-way merge, use numbered do commands
								-- Try diffget from buffer 3 (theirs) first, fallback to regular diffget
								local ok = pcall(function()
									vim.cmd("diffget 3")
								end)
								if not ok then
									vim.cmd("diffget")
								end
							end
						end,
						{ desc = "Smart get: diffget or choose theirs" },
					},

					{
						"n",
						"gp",
						function()
							local function is_in_conflict()
								local ok, parser = pcall(vim.treesitter.get_parser, 0)
								if not ok then
									return false
								end

								local row = vim.api.nvim_win_get_cursor(0)[1] - 1
								local query = vim.treesitter.query.get(parser:lang(), "conflict")

								if query then
									local tree = parser:parse()[1]
									for _, node in query:iter_captures(tree:root(), 0, row, row + 1) do
										return true
									end
								end
								return false
							end

							if is_in_conflict() then
								require("diffview.actions").conflict_choose("ours")
							else
								-- For 3-way merge, use numbered dp commands
								-- Try diffput to buffer 1 (ours) first, fallback to regular diffput
								local ok = pcall(function()
									vim.cmd("diffput 1")
								end)
								if not ok then
									vim.cmd("diffput")
								end
							end
						end,
						{ desc = "Smart put: diffput or choose ours" },
					},

					{ "n", "gO", "<Cmd>%diffget<CR>", { desc = "Get ALL hunks from other buffer" } },
					{ "n", "gP", "<Cmd>%diffput<CR>", { desc = "Put ALL hunks to other buffer" } },

					-- Conflict navigation
					{
						"n",
						"]x",
						function()
							require("diffview.actions").next_conflict()
						end,
						{ desc = "Next conflict" },
					},
					{
						"n",
						"[x",
						function()
							require("diffview.actions").prev_conflict()
						end,
						{ desc = "Previous conflict" },
					},

					{
						"n",
						"gs",
						function()
							local ok, result = pcall(function()
								local added, removed, changed = 0, 0, 0
								local total_lines = vim.fn.line("$")
								for i = 1, total_lines do
									local hl = vim.fn.diff_hlID(i, 1)
									if hl == vim.fn.hlID("DiffAdd") then
										added = added + 1
									elseif hl == vim.fn.hlID("DiffDelete") then
										removed = removed + 1
									elseif hl == vim.fn.hlID("DiffChange") then
										changed = changed + 1
									end
								end
								return string.format("Stats: +%d -%d ~%d", added, removed, changed)
							end)
							if ok then
								vim.notify(result)
							else
								vim.notify("Unable to calculate diff statistics")
							end
						end,
						{ desc = "Show diff statistics" },
					},
				},
				file_panel = {
					["<leader>cO"] = false,
					["<leader>cT"] = false,
					["<leader>cB"] = false,
					["<leader>cA"] = false,
					["q"] = "<Cmd>DiffviewClose<CR>",
				},
				file_history_panel = {
					["q"] = "<Cmd>DiffviewClose<CR>",
				},
			},
		})
	end,
}
