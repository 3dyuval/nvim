-- Interactive Keymap Conflict Tester for Neovim
-- This can be run directly inside a Neovim instance to test for keymap conflicts

local M = {}

-- Built-in Vim commands database (same as original)
M.builtin_commands = {
	n = {
		["<C-a>"] = { desc = "Increment number under cursor", severity = "WARNING" },
		["<C-x>"] = { desc = "Decrement number under cursor", severity = "WARNING" },
		["<C-i>"] = { desc = "Jump forward in jumplist (same as Tab)", severity = "INFO" },
		["<C-o>"] = { desc = "Jump backward in jumplist", severity = "WARNING" },
		["<C-u>"] = { desc = "Scroll up half page", severity = "INFO" },
		["<C-d>"] = { desc = "Scroll down half page", severity = "INFO" },
		["<C-f>"] = { desc = "Scroll forward full page", severity = "INFO" },
		["<C-b>"] = { desc = "Scroll backward full page", severity = "INFO" },
		["<C-e>"] = { desc = "Scroll window down one line", severity = "INFO" },
		["<C-y>"] = { desc = "Scroll window up one line", severity = "INFO" },
		["<C-h>"] = { desc = "Move cursor left / backspace", severity = "INFO" },
		["<C-j>"] = { desc = "Move cursor down / line feed", severity = "INFO" },
		["<C-k>"] = { desc = "Move cursor up / kill line", severity = "INFO" },
		["<C-l>"] = { desc = "Move cursor right / clear screen", severity = "INFO" },
		["<C-w>"] = { desc = "Window commands prefix", severity = "WARNING" },
		["<C-r>"] = { desc = "Redo", severity = "WARNING" },
		["<C-z>"] = { desc = "Suspend vim", severity = "INFO" },
		["<C-c>"] = { desc = "Cancel/interrupt", severity = "WARNING" },
		["<C-v>"] = { desc = "Visual block mode", severity = "WARNING" },
		["<C-n>"] = { desc = "Next match in completion", severity = "INFO" },
		["<C-p>"] = { desc = "Previous match in completion", severity = "INFO" },
		["<Tab>"] = { desc = "Jump forward in jumplist / indent", severity = "INFO" },
		["<S-Tab>"] = { desc = "Previous match in completion", severity = "INFO" },
	},
	i = {
		["<C-a>"] = { desc = "Insert previously inserted text", severity = "INFO" },
		["<C-x>"] = { desc = "Completion mode prefix", severity = "WARNING" },
		["<C-h>"] = { desc = "Backspace", severity = "WARNING" },
		["<C-w>"] = { desc = "Delete word before cursor", severity = "WARNING" },
		["<C-u>"] = { desc = "Delete line before cursor", severity = "WARNING" },
		["<C-t>"] = { desc = "Insert one shiftwidth of indent", severity = "INFO" },
		["<C-d>"] = { desc = "Delete one shiftwidth of indent", severity = "INFO" },
		["<C-n>"] = { desc = "Next match in completion", severity = "WARNING" },
		["<C-p>"] = { desc = "Previous match in completion", severity = "WARNING" },
		["<C-y>"] = { desc = "Accept selected completion", severity = "INFO" },
		["<C-e>"] = { desc = "Cancel completion", severity = "INFO" },
		["<C-r>"] = { desc = "Insert register contents", severity = "WARNING" },
		["<C-o>"] = { desc = "Execute normal mode command", severity = "INFO" },
		["<C-v>"] = { desc = "Insert literal character", severity = "INFO" },
		["<Tab>"] = { desc = "Insert tab / trigger completion", severity = "WARNING" },
		["<S-Tab>"] = { desc = "Previous match in completion", severity = "INFO" },
	},
	v = {
		["<C-a>"] = { desc = "Increment numbers in selection", severity = "WARNING" },
		["<C-x>"] = { desc = "Decrement numbers in selection", severity = "WARNING" },
		["<C-h>"] = { desc = "Move cursor left", severity = "INFO" },
		["<C-j>"] = { desc = "Move cursor down", severity = "INFO" },
		["<C-k>"] = { desc = "Move cursor up", severity = "INFO" },
		["<C-l>"] = { desc = "Move cursor right", severity = "INFO" },
		["<C-v>"] = { desc = "Switch to visual block mode", severity = "WARNING" },
		["<C-c>"] = { desc = "Cancel selection", severity = "WARNING" },
	},
	x = {
		["<C-a>"] = { desc = "Increment numbers in selection", severity = "WARNING" },
		["<C-x>"] = { desc = "Decrement numbers in selection", severity = "WARNING" },
	},
	o = {
		["<C-c>"] = { desc = "Cancel operator", severity = "WARNING" },
	},
	c = {
		["<C-a>"] = { desc = "Insert all matches", severity = "INFO" },
		["<C-h>"] = { desc = "Backspace", severity = "WARNING" },
		["<C-w>"] = { desc = "Delete word before cursor", severity = "WARNING" },
		["<C-u>"] = { desc = "Delete line before cursor", severity = "WARNING" },
		["<C-r>"] = { desc = "Insert register contents", severity = "WARNING" },
		["<C-n>"] = { desc = "Next match in history", severity = "INFO" },
		["<C-p>"] = { desc = "Previous match in history", severity = "INFO" },
		["<C-f>"] = { desc = "Open command-line window", severity = "INFO" },
		["<Tab>"] = { desc = "Command completion", severity = "WARNING" },
	},
	t = {
		["<C-\\><C-n>"] = { desc = "Exit terminal mode", severity = "WARNING" },
		["<C-h>"] = { desc = "Send backspace to terminal", severity = "INFO" },
		["<C-w>"] = { desc = "Window commands in terminal", severity = "WARNING" },
	},
}

-- Capture all existing keymaps
function M.capture_existing_keymaps()
	local existing_keymaps = {}

	for _, mode in ipairs({ "n", "i", "v", "x", "o", "c", "t" }) do
		existing_keymaps[mode] = {}
		local maps = vim.api.nvim_get_keymap(mode)

		for _, map in ipairs(maps) do
			existing_keymaps[mode][map.lhs] = {
				rhs = map.rhs or map.callback and "<Lua function>" or "",
				desc = map.desc or "",
				buffer = map.buffer or false,
				silent = map.silent,
				noremap = map.noremap,
				nowait = map.nowait,
				expr = map.expr,
				type = "explicit",
			}
		end

		-- Also check buffer-local mappings
		local buf_maps = vim.api.nvim_buf_get_keymap(0, mode)
		for _, map in ipairs(buf_maps) do
			existing_keymaps[mode][map.lhs] = {
				rhs = map.rhs or map.callback and "<Lua function>" or "",
				desc = map.desc or "",
				buffer = true,
				silent = map.silent,
				noremap = map.noremap,
				nowait = map.nowait,
				expr = map.expr,
				type = "buffer-local",
			}
		end
	end

	return existing_keymaps
end

-- Test keymaps for conflicts
function M.test_keymap_conflicts(new_keymaps, existing_keymaps)
	local conflicts = {}

	for _, keymap in ipairs(new_keymaps) do
		local mode = keymap.mode or "n"
		local lhs = keymap.lhs
		local rhs = keymap.rhs
		local desc = keymap.desc or ""

		-- Check for explicit keymap conflicts
		if existing_keymaps[mode] and existing_keymaps[mode][lhs] then
			table.insert(conflicts, {
				mode = mode,
				key = lhs,
				existing_rhs = existing_keymaps[mode][lhs].rhs,
				existing_desc = existing_keymaps[mode][lhs].desc,
				existing_type = existing_keymaps[mode][lhs].type,
				new_rhs = rhs,
				new_desc = desc,
				conflict_type = "explicit",
				severity = "ERROR",
			})
		end

		-- Check for built-in command conflicts
		if M.builtin_commands[mode] and M.builtin_commands[mode][lhs] then
			table.insert(conflicts, {
				mode = mode,
				key = lhs,
				existing_rhs = "Built-in Vim command",
				existing_desc = M.builtin_commands[mode][lhs].desc,
				existing_type = "builtin",
				new_rhs = rhs,
				new_desc = desc,
				conflict_type = "builtin",
				severity = M.builtin_commands[mode][lhs].severity,
			})
		end
	end

	-- Sort conflicts by severity
	local severity_order = { ERROR = 1, WARNING = 2, INFO = 3 }
	table.sort(conflicts, function(a, b)
		return severity_order[a.severity] < severity_order[b.severity]
	end)

	return conflicts
end

-- Display results in a new buffer
function M.display_results(conflicts, test_keymaps)
	-- Create a new buffer
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(buf, "filetype", "markdown")

	-- Prepare content
	local lines = {}

	table.insert(lines, "# Keymap Conflict Test Results")
	table.insert(lines, "")
	table.insert(lines, string.format("**Test Date:** %s", os.date("%Y-%m-%d %H:%M:%S")))
	table.insert(lines, "")

	-- Show tested keymaps
	table.insert(lines, "## Tested Keymaps")
	table.insert(lines, "")
	for _, km in ipairs(test_keymaps) do
		table.insert(
			lines,
			string.format("- **%s** `%s` → `%s` (%s)", km.mode or "n", km.lhs, km.rhs, km.desc or "no description")
		)
	end
	table.insert(lines, "")

	if #conflicts > 0 then
		table.insert(lines, "## ⚠️  CONFLICTS FOUND")
		table.insert(lines, "")

		-- Group by severity
		local current_severity = nil
		for _, conflict in ipairs(conflicts) do
			if conflict.severity ~= current_severity then
				current_severity = conflict.severity
				table.insert(lines, string.format("### %s Level", current_severity))
				table.insert(lines, "")
			end

			local icon = conflict.severity == "ERROR" and "🚨" or conflict.severity == "WARNING" and "⚠️" or "ℹ️"

			table.insert(
				lines,
				string.format(
					"%s **Mode:** `%s`, **Key:** `%s` [%s]",
					icon,
					conflict.mode,
					conflict.key,
					conflict.existing_type or conflict.conflict_type
				)
			)
			table.insert(lines, string.format("  - **Existing:** `%s` - %s", conflict.existing_rhs, conflict.existing_desc))
			table.insert(lines, string.format("  - **New:** `%s` - %s", conflict.new_rhs, conflict.new_desc))

			if conflict.conflict_type == "builtin" then
				table.insert(lines, "  - ⚠️  This will override built-in Vim functionality!")
			end
			table.insert(lines, "")
		end

		-- Summary
		local error_count = 0
		local warning_count = 0
		local info_count = 0

		for _, conflict in ipairs(conflicts) do
			if conflict.severity == "ERROR" then
				error_count = error_count + 1
			elseif conflict.severity == "WARNING" then
				warning_count = warning_count + 1
			elseif conflict.severity == "INFO" then
				info_count = info_count + 1
			end
		end

		table.insert(lines, "## Summary")
		table.insert(lines, "")
		if error_count > 0 then
			table.insert(lines, string.format("- 🚨 **%d ERROR(s)** - Explicit keymap conflicts", error_count))
		end
		if warning_count > 0 then
			table.insert(lines, string.format("- ⚠️  **%d WARNING(s)** - Important built-in overrides", warning_count))
		end
		if info_count > 0 then
			table.insert(lines, string.format("- ℹ️  **%d INFO** - Less critical built-in overrides", info_count))
		end
	else
		table.insert(lines, "## ✅ No Conflicts Found")
		table.insert(lines, "")
		table.insert(lines, "All tested keymaps are safe to use!")
	end

	-- Set buffer content
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.api.nvim_buf_set_option(buf, "modifiable", false)

	-- Open in a new window
	vim.cmd("split")
	vim.api.nvim_win_set_buf(0, buf)

	return buf
end

-- Main test function
function M.test(keymaps)
	keymaps = keymaps or {}

	-- Capture existing keymaps
	local existing_keymaps = M.capture_existing_keymaps()

	-- Test for conflicts
	local conflicts = M.test_keymap_conflicts(keymaps, existing_keymaps)

	-- Display results
	M.display_results(conflicts, keymaps)

	return conflicts
end

-- Quick test for specific keymap
function M.test_single(mode, lhs, rhs, desc)
	local keymap = { mode = mode, lhs = lhs, rhs = rhs, desc = desc }
	return M.test({ keymap })
end

-- Test common leader keymaps
function M.test_leader_cp()
	return M.test({
		{ mode = "n", lhs = "<leader>cp", rhs = "test", desc = "Test conflicting keymap" },
	})
end

-- Export results as JSON
function M.export_json(keymaps)
	keymaps = keymaps or {}

	local existing_keymaps = M.capture_existing_keymaps()
	local conflicts = M.test_keymap_conflicts(keymaps, existing_keymaps)

	local result = {
		timestamp = os.date("%Y-%m-%d %H:%M:%S"),
		tested_keymaps = keymaps,
		conflicts = conflicts,
		summary = {
			total_conflicts = #conflicts,
			errors = 0,
			warnings = 0,
			info = 0,
		},
	}

	for _, conflict in ipairs(conflicts) do
		if conflict.severity == "ERROR" then
			result.summary.errors = result.summary.errors + 1
		elseif conflict.severity == "WARNING" then
			result.summary.warnings = result.summary.warnings + 1
		elseif conflict.severity == "INFO" then
			result.summary.info = result.summary.info + 1
		end
	end

	-- Use vim.fn.json_encode if available, otherwise simple serialization
	if vim.fn.json_encode then
		return vim.fn.json_encode(result)
	else
		-- Simple JSON serialization fallback
		local json_parts = {}
		table.insert(json_parts, "{")
		table.insert(json_parts, '"timestamp":"' .. result.timestamp .. '",')
		table.insert(json_parts, '"tested_keymaps":' .. vim.inspect(keymaps) .. ",")
		table.insert(json_parts, '"conflicts":' .. vim.inspect(conflicts) .. ",")
		table.insert(json_parts, '"summary":{')
		table.insert(json_parts, '"total_conflicts":' .. result.summary.total_conflicts .. ",")
		table.insert(json_parts, '"errors":' .. result.summary.errors .. ",")
		table.insert(json_parts, '"warnings":' .. result.summary.warnings .. ",")
		table.insert(json_parts, '"info":' .. result.summary.info)
		table.insert(json_parts, "}}")
		return table.concat(json_parts)
	end
end

-- Write results to file
function M.write_results(keymaps, filepath)
	filepath = filepath or "/tmp/keymap_conflict_results.json"
	local json = M.export_json(keymaps)

	local file = io.open(filepath, "w")
	if file then
		file:write(json)
		file:close()
		print("Results written to: " .. filepath)
		return true
	else
		print("Error: Could not write to file: " .. filepath)
		return false
	end
end

-- Add user command for easy access
vim.api.nvim_create_user_command("TestKeymapConflicts", function(opts)
	if opts.args == "" then
		-- Test with example keymaps
		M.test({
			{ mode = "n", lhs = "<leader>ff", rhs = ":Telescope find_files<CR>", desc = "Find files" },
			{ mode = "n", lhs = "<leader>cp", rhs = "test", desc = "Test keymap" },
		})
	else
		-- Try to evaluate the argument as Lua code
		local ok, keymaps = pcall(loadstring("return " .. opts.args))
		if ok and type(keymaps) == "table" then
			M.test(keymaps)
		else
			print("Error: Invalid keymap table. Use format: { mode='n', lhs='<leader>x', rhs='cmd', desc='description' }")
		end
	end
end, { nargs = "?", desc = "Test keymaps for conflicts" })

-- Add command specifically for testing <leader>cp
vim.api.nvim_create_user_command("TestLeaderCP", function()
	M.test_leader_cp()
end, { desc = "Test <leader>cp for conflicts" })

return M
