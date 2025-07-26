#!/usr/bin/env lua

-- keymap_tester.lua
-- Usage: echo 'keymaps_lua_table' | lua keymap_tester.lua
-- Or: lua keymap_tester.lua < keymaps.lua

-- Simple table serializer (replacement for vim.inspect)
local function serialize_table(t, indent)
	indent = indent or 0
	local spaces = string.rep("  ", indent)

	if type(t) ~= "table" then
		if type(t) == "string" then
			return string.format('"%s"', t:gsub('"', '\\"'))
		else
			return tostring(t)
		end
	end

	local result = "{\n"
	for k, v in pairs(t) do
		local key_str
		if type(k) == "string" then
			key_str = string.format("%s = ", k)
		else
			key_str = string.format("[%s] = ", k)
		end

		result = result .. spaces .. "  " .. key_str .. serialize_table(v, indent + 1) .. ",\n"
	end
	result = result .. spaces .. "}"

	return result
end

local function test_keymaps(keymaps)
	-- Create a temporary test file
	local test_file = "/tmp/nvim_keymap_test.lua"

	-- Generate test script content
	local test_content = [[
-- Keymap conflict tester
local conflicts = {}
local existing_keymaps = {}

-- Built-in Vim commands database
local builtin_commands = {
    n = {
        ['<C-a>'] = { desc = 'Increment number under cursor', severity = 'WARNING' },
        ['<C-x>'] = { desc = 'Decrement number under cursor', severity = 'WARNING' },
        ['<C-i>'] = { desc = 'Jump forward in jumplist (same as Tab)', severity = 'INFO' },
        ['<C-o>'] = { desc = 'Jump backward in jumplist', severity = 'WARNING' },
        ['<C-u>'] = { desc = 'Scroll up half page', severity = 'INFO' },
        ['<C-d>'] = { desc = 'Scroll down half page', severity = 'INFO' },
        ['<C-f>'] = { desc = 'Scroll forward full page', severity = 'INFO' },
        ['<C-b>'] = { desc = 'Scroll backward full page', severity = 'INFO' },
        ['<C-e>'] = { desc = 'Scroll window down one line', severity = 'INFO' },
        ['<C-y>'] = { desc = 'Scroll window up one line', severity = 'INFO' },
        ['<C-h>'] = { desc = 'Move cursor left / backspace', severity = 'INFO' },
        ['<C-j>'] = { desc = 'Move cursor down / line feed', severity = 'INFO' },
        ['<C-k>'] = { desc = 'Move cursor up / kill line', severity = 'INFO' },
        ['<C-l>'] = { desc = 'Move cursor right / clear screen', severity = 'INFO' },
        ['<C-w>'] = { desc = 'Window commands prefix', severity = 'WARNING' },
        ['<C-r>'] = { desc = 'Redo', severity = 'WARNING' },
        ['<C-z>'] = { desc = 'Suspend vim', severity = 'INFO' },
        ['<C-c>'] = { desc = 'Cancel/interrupt', severity = 'WARNING' },
        ['<C-v>'] = { desc = 'Visual block mode', severity = 'WARNING' },
        ['<C-n>'] = { desc = 'Next match in completion', severity = 'INFO' },
        ['<C-p>'] = { desc = 'Previous match in completion', severity = 'INFO' },
        ['<Tab>'] = { desc = 'Jump forward in jumplist / indent', severity = 'INFO' },
        ['<S-Tab>'] = { desc = 'Previous match in completion', severity = 'INFO' },
    },
    i = {
        ['<C-a>'] = { desc = 'Insert previously inserted text', severity = 'INFO' },
        ['<C-x>'] = { desc = 'Completion mode prefix', severity = 'WARNING' },
        ['<C-h>'] = { desc = 'Backspace', severity = 'WARNING' },
        ['<C-w>'] = { desc = 'Delete word before cursor', severity = 'WARNING' },
        ['<C-u>'] = { desc = 'Delete line before cursor', severity = 'WARNING' },
        ['<C-t>'] = { desc = 'Insert one shiftwidth of indent', severity = 'INFO' },
        ['<C-d>'] = { desc = 'Delete one shiftwidth of indent', severity = 'INFO' },
        ['<C-n>'] = { desc = 'Next match in completion', severity = 'WARNING' },
        ['<C-p>'] = { desc = 'Previous match in completion', severity = 'WARNING' },
        ['<C-y>'] = { desc = 'Accept selected completion', severity = 'INFO' },
        ['<C-e>'] = { desc = 'Cancel completion', severity = 'INFO' },
        ['<C-r>'] = { desc = 'Insert register contents', severity = 'WARNING' },
        ['<C-o>'] = { desc = 'Execute normal mode command', severity = 'INFO' },
        ['<C-v>'] = { desc = 'Insert literal character', severity = 'INFO' },
        ['<Tab>'] = { desc = 'Insert tab / trigger completion', severity = 'WARNING' },
        ['<S-Tab>'] = { desc = 'Previous match in completion', severity = 'INFO' },
    },
    v = {
        ['<C-a>'] = { desc = 'Increment numbers in selection', severity = 'WARNING' },
        ['<C-x>'] = { desc = 'Decrement numbers in selection', severity = 'WARNING' },
        ['<C-h>'] = { desc = 'Move cursor left', severity = 'INFO' },
        ['<C-j>'] = { desc = 'Move cursor down', severity = 'INFO' },
        ['<C-k>'] = { desc = 'Move cursor up', severity = 'INFO' },
        ['<C-l>'] = { desc = 'Move cursor right', severity = 'INFO' },
        ['<C-v>'] = { desc = 'Switch to visual block mode', severity = 'WARNING' },
        ['<C-c>'] = { desc = 'Cancel selection', severity = 'WARNING' },
    },
    x = {
        ['<C-a>'] = { desc = 'Increment numbers in selection', severity = 'WARNING' },
        ['<C-x>'] = { desc = 'Decrement numbers in selection', severity = 'WARNING' },
    },
    o = {
        ['<C-c>'] = { desc = 'Cancel operator', severity = 'WARNING' },
    },
    c = {
        ['<C-a>'] = { desc = 'Insert all matches', severity = 'INFO' },
        ['<C-h>'] = { desc = 'Backspace', severity = 'WARNING' },
        ['<C-w>'] = { desc = 'Delete word before cursor', severity = 'WARNING' },
        ['<C-u>'] = { desc = 'Delete line before cursor', severity = 'WARNING' },
        ['<C-r>'] = { desc = 'Insert register contents', severity = 'WARNING' },
        ['<C-n>'] = { desc = 'Next match in history', severity = 'INFO' },
        ['<C-p>'] = { desc = 'Previous match in history', severity = 'INFO' },
        ['<C-f>'] = { desc = 'Open command-line window', severity = 'INFO' },
        ['<Tab>'] = { desc = 'Command completion', severity = 'WARNING' },
    },
    t = {
        ['<C-\\><C-n>'] = { desc = 'Exit terminal mode', severity = 'WARNING' },
        ['<C-h>'] = { desc = 'Send backspace to terminal', severity = 'INFO' },
        ['<C-w>'] = { desc = 'Window commands in terminal', severity = 'WARNING' },
    }
}

-- Capture existing keymaps
local function capture_existing_keymaps()
    for _, mode in ipairs({'n', 'i', 'v', 'x', 'o', 'c', 't'}) do
        existing_keymaps[mode] = {}
        local maps = vim.api.nvim_get_keymap(mode)
        for _, map in ipairs(maps) do
            existing_keymaps[mode][map.lhs] = {
                rhs = map.rhs or '',
                desc = map.desc or '',
                buffer = map.buffer or false,
                type = 'explicit'
            }
            -- Debug: print leader keymaps
            if mode == 'n' and string.find(map.lhs, '<leader>') then
                print("DEBUG: Found keymap " .. map.lhs .. " -> " .. (map.rhs or '') .. " (" .. (map.desc or '') .. ")")
            end
        end
    end
end

-- Test new keymaps for conflicts
local function test_keymap_conflicts(new_keymaps)
    for _, keymap in ipairs(new_keymaps) do
        local mode = keymap.mode or 'n'
        local lhs = keymap.lhs
        local rhs = keymap.rhs
        local desc = keymap.desc or ''

        -- Check for explicit keymap conflicts
        if existing_keymaps[mode] and existing_keymaps[mode][lhs] then
            table.insert(conflicts, {
                mode = mode,
                key = lhs,
                existing_rhs = existing_keymaps[mode][lhs].rhs,
                existing_desc = existing_keymaps[mode][lhs].desc,
                new_rhs = rhs,
                new_desc = desc,
                conflict_type = 'explicit',
                severity = 'ERROR'
            })
        end

        -- Check for built-in command conflicts
        if builtin_commands[mode] and builtin_commands[mode][lhs] then
            table.insert(conflicts, {
                mode = mode,
                key = lhs,
                existing_rhs = 'Built-in Vim command',
                existing_desc = builtin_commands[mode][lhs].desc,
                new_rhs = rhs,
                new_desc = desc,
                conflict_type = 'builtin',
                severity = builtin_commands[mode][lhs].severity
            })
        end
    end
end

-- Capture existing keymaps first
capture_existing_keymaps()

-- Test keymaps from input
local test_keymaps = ]] .. serialize_table(keymaps) .. [[

test_keymap_conflicts(test_keymaps)

-- Sort conflicts by severity (ERROR > WARNING > INFO)
local severity_order = { ERROR = 1, WARNING = 2, INFO = 3 }
table.sort(conflicts, function(a, b)
    return severity_order[a.severity] < severity_order[b.severity]
end)

-- Output results to stdout
if #conflicts > 0 then
    print("CONFLICTS FOUND:")
    print("")

    -- Group by severity
    local current_severity = nil
    for _, conflict in ipairs(conflicts) do
        if conflict.severity ~= current_severity then
            current_severity = conflict.severity
            print(string.format("=== %s LEVEL ===", current_severity))
        end

        print(string.format("Mode: %s, Key: %s [%s]", conflict.mode, conflict.key, conflict.conflict_type))
        print(string.format("  Existing: %s (%s)", conflict.existing_rhs, conflict.existing_desc))
        print(string.format("  New: %s (%s)", conflict.new_rhs, conflict.new_desc))

        if conflict.conflict_type == 'builtin' then
            print("  ⚠️  This will override built-in Vim functionality!")
        end
        print("---")
    end

    -- Summary
    local error_count = 0
    local warning_count = 0
    local info_count = 0

    for _, conflict in ipairs(conflicts) do
        if conflict.severity == 'ERROR' then
            error_count = error_count + 1
        elseif conflict.severity == 'WARNING' then
            warning_count = warning_count + 1
        elseif conflict.severity == 'INFO' then
            info_count = info_count + 1
        end
    end

    print("")
    print("SUMMARY:")
    if error_count > 0 then
        print(string.format("  🚨 %d ERROR(s) - Explicit keymap conflicts", error_count))
    end
    if warning_count > 0 then
        print(string.format("  ⚠️  %d WARNING(s) - Important built-in overrides", warning_count))
    end
    if info_count > 0 then
        print(string.format("  ℹ️  %d INFO - Less critical built-in overrides", info_count))
    end
else
    print("NO CONFLICTS FOUND")
end

-- Exit nvim
vim.cmd('qall!')
]]

	-- Write test file
	local file = io.open(test_file, "w")
	if not file then
		print("Error: Could not create test file")
		return false
	end
	file:write(test_content)
	file:close()

	-- Run nvim with full config but capture output and exit quickly
	local temp_output = "/tmp/nvim_keymap_output.txt"
	local cmd = string.format(
		"timeout 10s nvim --headless -c 'source %s' 2>&1 | tee %s; echo $? > %s.exit",
		test_file,
		temp_output,
		temp_output
	)
	local success = os.execute(cmd)

	-- Read and display output
	local output_file = io.open(temp_output, "r")
	if output_file then
		local output = output_file:read("*all")
		print(output)
		output_file:close()
	end

	-- Cleanup
	os.remove(test_file)
	os.remove(temp_output)
	os.remove(temp_output .. ".exit")

	return success == 0
end

-- Read from stdin
local function _read_stdin() -- Reserved for future stdin input
	local input = ""
	for line in io.lines() do
		input = input .. line .. "\n"
	end
	return input:gsub("\n$", "") -- Remove trailing newline
end

-- Main logic
local keymaps = nil

-- Simple way to check if we have stdin input
local input_available = false
local stdin_content = ""

-- Check if we can read from stdin immediately
local _success, _result = pcall(function()
	local line = io.read("*line")
	if line then
		stdin_content = line .. "\n"
		-- Read the rest
		for additional_line in io.lines() do
			stdin_content = stdin_content .. additional_line .. "\n"
		end
		input_available = true
	end
end)

if input_available and stdin_content ~= "" then
	-- Remove trailing newline
	stdin_content = stdin_content:gsub("\n$", "")

	-- Try to evaluate as Lua table
	local func, load_err = load("return " .. stdin_content)
	if func then
		local eval_success, result = pcall(func)
		if eval_success then
			keymaps = result
		else
			print("Error evaluating input:", result)
			os.exit(1)
		end
	else
		print("Error loading input:", load_err)
		print("Make sure your input is a valid Lua table")
		os.exit(1)
	end
else
	-- Use example keymaps for testing
	keymaps = {
		{ mode = "n", lhs = "<leader>ff", rhs = ":Telescope find_files<CR>", desc = "Find files" },
		{ mode = "n", lhs = "<leader>fg", rhs = ":Telescope live_grep<CR>", desc = "Live grep" },
		{ mode = "n", lhs = "<C-h>", rhs = "<C-w>h", desc = "Window left" },
		{ mode = "i", lhs = "jk", rhs = "<Esc>", desc = "Exit insert mode" },
		{ mode = "v", lhs = "<leader>y", rhs = '"+y', desc = "Copy to clipboard" },
	}
	print("No stdin input detected, using example keymaps...")
end

-- Run the test
print("Testing keymaps for conflicts...")
test_keymaps(keymaps)
