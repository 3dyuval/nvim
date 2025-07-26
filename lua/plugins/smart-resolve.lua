return {
	{
		"smart-resolve",
		dir = vim.fn.stdpath("config"),
		name = "smart-resolve",
		dependencies = { "sindrets/diffview.nvim", "folke/snacks.nvim" },
		config = function()
			-- Install git-resolve-conflict if not present
			local function install_git_resolve_conflict()
				local handle = io.popen("which git-resolve-conflict 2>/dev/null")
				if not handle then
					return false
				end
				local result = handle:read("*a") or ""
				handle:close()

				if result == "" then
					vim.notify("git-resolve-conflict in not installed", vim.log.levels.WARN)
				end
			end

			-- Auto-install on startup
			install_git_resolve_conflict()

			-- Jump to next/previous conflict functions
			local function next_conflict()
				local found = vim.fn.search("^<<<<<<<", "W")
				if found == 0 then
					vim.notify("No more conflicts found", vim.log.levels.INFO)
				end
			end

			local function prev_conflict()
				local found = vim.fn.search("^<<<<<<<", "bW")
				if found == 0 then
					vim.notify("No more conflicts found", vim.log.levels.INFO)
				end
			end

			-- Smart resolve function
			local function smart_resolve_current_file()
				local file = vim.api.nvim_buf_get_name(0)
				if file == "" then
					vim.notify("No file in current buffer", vim.log.levels.WARN)
					return
				end

				-- Handle diffview buffers
				if file:match("^diffview://") then
					-- Extract real file path from diffview buffer name
					-- Format: diffview://[git_root]/[panel]/[file_path]
					local real_file = file:gsub("^diffview://[^/]+/[^/]+/", "")
					if real_file and real_file ~= "" then
						-- Get git root and construct full path
						local git_root = vim.fn.system("git rev-parse --show-toplevel"):gsub("\n", "")
						file = git_root .. "/" .. real_file
					end
				end

				-- Get git root directory from file's directory first
				local file_dir = vim.fn.fnamemodify(file, ":h")
				local git_root =
					vim.fn.system("cd " .. vim.fn.shellescape(file_dir) .. " && git rev-parse --show-toplevel"):gsub("\n", "")

				-- Convert absolute path to relative path from git root
				local relative_file = file:gsub("^" .. vim.pesc(git_root) .. "/", "")

				-- Check if file is in conflicted state using git
				local git_unmerged_cmd = string.format(
					"cd %s && git diff --name-only --diff-filter=U | grep -Fxq %s",
					vim.fn.shellescape(git_root),
					vim.fn.shellescape(relative_file)
				)
				local _is_conflicted = vim.fn.system(git_unmerged_cmd) -- Check conflict status
				local exit_code = vim.v.shell_error

				if exit_code ~= 0 then
					vim.notify("File is not in conflicted state: " .. relative_file, vim.log.levels.INFO)
					return
				end

				-- Present options
				local choices = {
					"1. Union (merge both changes)",
					"2. Ours (keep our changes)",
					"3. Theirs (keep their changes)",
					"4. Cancel",
				}

				vim.ui.select(choices, {
					prompt = "Smart resolve conflicts in " .. vim.fn.fnamemodify(file, ":t") .. ":",
				}, function(choice, idx)
					if not choice or idx == 4 then
						return
					end

					local strategies = { "union", "ours", "theirs" }
					local strategy = strategies[idx]

					-- Run git-resolve-conflict with relative path
					local cmd = string.format(
						"cd %s && git-resolve-conflict --%s %s",
						vim.fn.shellescape(git_root),
						strategy,
						vim.fn.shellescape(relative_file)
					)
					local output = vim.fn.system(cmd)
					local exit_code = vim.v.shell_error

					if exit_code == 0 then
						-- Reload the buffer to show resolved conflicts
						vim.cmd("checktime")
						-- Display the output from git-resolve-conflict which includes count
						vim.notify(output:gsub("\n", ""), vim.log.levels.INFO)
					else
						vim.notify("Failed to resolve conflicts: " .. output, vim.log.levels.ERROR)
					end
				end)
			end

			-- Auto-load in diffview merge mode
			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = "*",
				callback = function()
					-- Check if we're in diffview merge mode
					local bufname = vim.api.nvim_buf_get_name(0)
					local is_diffview = bufname:match("diffview://") ~= nil
					local _is_merge_mode = vim.fn.exists("*diffview#get_current_view") == 1 -- Check merge mode

					if is_diffview or vim.wo.diff then
						-- Add diffview-specific keymap (silently)
						vim.keymap.set("n", "<leader>gr", smart_resolve_current_file, {
							buffer = true,
							desc = "Smart resolve conflicts (diffview)",
						})
					end
				end,
			})

			-- Auto-trigger when opening files with conflicts (once per buffer)
			local notified_buffers = {}
			vim.api.nvim_create_autocmd("BufReadPost", {
				pattern = "*",
				callback = function()
					local bufnr = vim.api.nvim_get_current_buf()
					if notified_buffers[bufnr] then
						return
					end

					-- Check if file has conflicts
					local has_conflicts = vim.fn.search("^<<<<<<< ", "nw") > 0
					if has_conflicts then
						notified_buffers[bufnr] = true
						vim.notify("Conflicts detected! Use <leader>gr for smart resolution", vim.log.levels.WARN)
					end
				end,
			})

			-- Command and global keymap
			vim.api.nvim_create_user_command("SmartResolve", smart_resolve_current_file, {
				desc = "Smart resolve conflicts in current file",
			})

			-- Test command to verify plugin is loaded
			vim.api.nvim_create_user_command("SmartResolveTest", function()
				vim.notify("SmartResolve plugin is loaded and working!", vim.log.levels.INFO)
			end, {
				desc = "Test if SmartResolve plugin is loaded",
			})

			vim.keymap.set("n", "<leader>gr", smart_resolve_current_file, {
				desc = "Smart resolve conflicts",
			})

			-- Conflict navigation keymaps
			vim.keymap.set("n", "]x", next_conflict, { desc = "Next conflict" })
			vim.keymap.set("n", "[x", prev_conflict, { desc = "Previous conflict" })
		end,
	},
}
