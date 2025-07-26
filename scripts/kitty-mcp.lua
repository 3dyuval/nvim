#!/usr/bin/env lua

-- Kitty MCP (Model Context Protocol) Integration Test Script
-- This script demonstrates and tests kitty's remote control capabilities
--
-- PREREQUISITES:
-- 1. Kitty terminal with remote control enabled
-- 2. Add to kitty.conf: allow_remote_control yes
-- 3. Optional: remote_control_password your_password_here
-- 4. Lua interpreter installed (lua or luajit)
--
-- USAGE:
-- Interactive menu (default):
--   lua kitty-mcp.lua
--
-- Run full test suite:
--   lua kitty-mcp.lua test
--
-- List windows and tabs:
--   lua kitty-mcp.lua list
--
-- Show help:
--   lua kitty-mcp.lua help
--
-- KITTY CONFIGURATION ADDITIONS:
-- Add these lines to your kitty.conf:
--   # Enable remote control
--   allow_remote_control yes
--
--   # Optional: Set password for security
--   # remote_control_password your_password_here
--
--   # Optional: Listen on socket
--   # listen_on unix:/tmp/kitty
--
-- FEATURES:
-- - Launch new tabs and windows
-- - Send text to specific windows/tabs
-- - Find and manage Neovim instances
-- - Test broadcast functionality
-- - Direct JSON protocol communication
-- - Auto-detection of kitty environment
--
-- Note: This script uses simple pattern matching for JSON parsing
-- For production use, consider installing a proper JSON library like lua-cjson

-- Configuration
local KITTY_SOCKET = "unix:/tmp/kitty"
local VERBOSE = true

-- Helper function to execute shell commands and capture output
local function execute_command(cmd)
	local handle = io.popen(cmd .. " 2>&1")
	local result = handle:read("*a")
	local success = handle:close()
	return result, success
end

-- Helper function to execute kitty remote control commands
local function kitty_command(cmd, use_socket)
	local full_cmd
	if use_socket then
		full_cmd = string.format("kitten @ --to %s %s", KITTY_SOCKET, cmd)
	else
		full_cmd = string.format("kitten @ %s", cmd)
	end

	if VERBOSE then
		print("Executing: " .. full_cmd)
	end

	local result, success = execute_command(full_cmd)

	if VERBOSE and result ~= "" then
		print("Result: " .. result)
	end

	return result, success
end

-- Simple JSON parser (if json library not available)
local function simple_json_parse(str)
	-- This is a very basic implementation for demonstration
	-- In production, use a proper JSON library
	local ok, result = pcall(function()
		return load("return " .. str:gsub('("[^"]-"):', "[%1]="))()
	end)
	if ok then
		return result
	else
		return nil, "JSON parse error"
	end
end

-- List all windows and tabs
local function list_windows(use_socket)
	print("\n=== Listing all windows and tabs ===")
	local result = kitty_command("ls", use_socket)

	-- Try to parse JSON output
	if result:match("^%[") then
		-- It's JSON, try to parse it
		local data = simple_json_parse(result)
		if data then
			print("Found " .. #data .. " OS window(s)")
			for i, os_window in ipairs(data) do
				print(string.format("OS Window %d (ID: %s)", i, os_window.id or "unknown"))
				if os_window.tabs then
					for j, tab in ipairs(os_window.tabs) do
						print(string.format("  Tab %d: %s", j, tab.title or "untitled"))
						if tab.windows then
							for k, window in ipairs(tab.windows) do
								print(
									string.format("    Window %d: %s (PID: %s)", k, window.title or "untitled", window.pid or "unknown")
								)
							end
						end
					end
				end
			end
		end
	else
		print("Raw output:")
		print(result)
	end

	return result
end

-- Launch a new tab
local function launch_tab(title, command, use_socket)
	print(string.format("\n=== Launching new tab: %s ===", title))
	local cmd = string.format('launch --type=tab --tab-title="%s" %s', title, command or "bash")
	return kitty_command(cmd, use_socket)
end

-- Launch a new window
local function launch_window(title, command, use_socket)
	print(string.format("\n=== Launching new window: %s ===", title))
	local cmd = string.format('launch --type=window --title="%s" %s', title, command or "bash")
	return kitty_command(cmd, use_socket)
end

-- Launch neovim with test file (configurable tab/pane)
local function launch_nvim_test(title, test_file, use_pane, use_socket)
	title = title or "Neovim Test"
	test_file = test_file or "/tmp/test_file.txt"
	use_pane = use_pane or false

	-- Ensure directory exists
	local dir = test_file:match("(.*/)")
	if dir then
		os.execute("mkdir -p " .. dir)
	end

	-- Create descriptive test file
	local file = io.open(test_file, "w")
	if file then
		local content = string.format(
			[[# Neovim Test File - %s
Generated at: %s

This is a test file for kitty-mcp neovim integration.
File path: %s

## Test Status
- ✅ File created successfully
- ⏳ Waiting for neovim to load plugins...
- 🔄 Ready for command testing

## Instructions
You can edit this content for testing purposes.
Commands sent via kitty-mcp will appear below:

---
]],
			title,
			os.date("%Y-%m-%d %H:%M:%S"),
			test_file
		)

		file:write(content)
		file:close()
		print("✅ Test file created: " .. test_file)
	else
		print("❌ Failed to create test file: " .. test_file)
		return nil, false, nil
	end

	local launch_type = use_pane and "window" or "tab"
	local title_flag = use_pane and "--title" or "--tab-title"

	-- Convert to absolute path to ensure correct file is opened
	local abs_test_file = test_file
	if not test_file:match("^/") then
		local cwd = io.popen("pwd"):read("*l")
		abs_test_file = cwd .. "/" .. test_file
	end

	print(string.format("\n=== Launching Neovim in new %s: %s ===", launch_type, title))
	print("Opening file: " .. abs_test_file)
	local cmd = string.format('launch --type=%s %s="%s" nvim "%s"', launch_type, title_flag, title, abs_test_file)

	local result, success = kitty_command(cmd, use_socket)

	if success then
		print("⏳ Waiting for Neovim and plugins to load (6 seconds)...")
		os.execute("sleep 6") -- Increased wait time for plugin loading
		return result, success, test_file
	else
		print("❌ Failed to launch Neovim")
		return result, success, nil
	end
end

-- Send neovim command (properly handles escape sequences)
local function send_nvim_command(match_criteria, command, use_socket)
	print(string.format("\n=== Sending Neovim command: %s ===", command))

	-- Send escape to ensure normal mode (Python-style escape)
	kitty_command(string.format("send-text --match '%s' '\\e'", match_criteria), use_socket)
	os.execute("sleep 0.1") -- 100ms delay for mode transition

	-- Send colon to enter command mode
	kitty_command(string.format("send-text --match '%s' ':'", match_criteria), use_socket)
	os.execute("sleep 0.05") -- 50ms delay

	-- Send the actual command
	kitty_command(string.format("send-text --match '%s' '%s'", match_criteria, command), use_socket)
	os.execute("sleep 0.05") -- 50ms delay

	-- Send enter to execute
	kitty_command(string.format("send-text --match '%s' '\\r'", match_criteria), use_socket)
	os.execute("sleep 0.2") -- Wait for command execution

	return true
end

-- Send lua code to neovim
local function send_nvim_lua(match_criteria, lua_code, use_socket)
	print(string.format("\n=== Sending Neovim Lua: %s ===", lua_code))

	-- Escape the lua code for shell
	local escaped_code = lua_code:gsub('"', '\\"'):gsub("'", "\\'")
	local command = string.format("lua %s", escaped_code)

	return send_nvim_command(match_criteria, command, use_socket)
end

-- Write data to file from neovim using lua
local function send_nvim_write_file(match_criteria, output_file, data, use_socket)
	print(string.format("\n=== Writing to file: %s ===", output_file))

	-- Escape the data and file path for lua
	local escaped_data = data:gsub('"', '\\"'):gsub("\n", "\\n")
	local escaped_file = output_file:gsub('"', '\\"')

	local lua_code = string.format(
		[[
		local file = io.open("%s", "w")
		if file then
			file:write("%s")
			file:close()
			print("File written successfully: %s")
		else
			print("Error: Could not write to file: %s")
		end
	]],
		escaped_file,
		escaped_data,
		escaped_file,
		escaped_file
	)

	return send_nvim_lua(match_criteria, lua_code, use_socket)
end

-- Load and execute a neovim script via require
local function send_nvim_require(match_criteria, module_path, use_socket)
	print(string.format("\n=== Loading Neovim module: %s ===", module_path))

	local lua_code = string.format('require("%s")', module_path)
	return send_nvim_lua(match_criteria, lua_code, use_socket)
end

-- Execute a function in a neovim module
local function send_nvim_call_function(match_criteria, module_path, function_name, args, use_socket)
	print(string.format("\n=== Calling %s.%s ===", module_path, function_name))

	args = args or ""
	local lua_code = string.format('require("%s").%s(%s)', module_path, function_name, args)
	return send_nvim_lua(match_criteria, lua_code, use_socket)
end

-- Send text to a specific window/tab
local function send_text(match_criteria, text, use_socket)
	print(string.format("\n=== Sending text to windows matching: %s ===", match_criteria))
	-- Use single quotes to avoid shell escaping issues with backslashes
	local cmd = string.format("send-text --match '%s' '%s'", match_criteria, text:gsub("'", "'\"'\"'"))
	return kitty_command(cmd, use_socket)
end

-- Find all Neovim windows
local function find_nvim_windows(use_socket)
	print("\n=== Finding all Neovim windows ===")
	local result = kitty_command("ls", use_socket)

	-- Simple pattern matching to find nvim processes
	local nvim_count = 0
	for line in result:gmatch("[^\n]+") do
		if line:match("nvim") or line:match("var:IS_NVIM") then
			nvim_count = nvim_count + 1
			print("Found Neovim: " .. line)
		end
	end

	print(string.format("Total Neovim instances: %d", nvim_count))
	return nvim_count
end

-- Focus a specific window
local function focus_window(match_criteria, use_socket)
	print(string.format("\n=== Focusing window: %s ===", match_criteria))
	local cmd = string.format("focus-window --match '%s'", match_criteria)
	return kitty_command(cmd, use_socket)
end

-- Close a window
local function close_window(match_criteria, use_socket)
	print(string.format("\n=== Closing window: %s ===", match_criteria))
	local cmd = string.format("close-window --match '%s'", match_criteria)
	return kitty_command(cmd, use_socket)
end

-- Test broadcast functionality
local function test_broadcast(use_socket)
	print("\n=== Testing broadcast functionality ===")
	local cmd = 'launch --allow-remote-control kitty +kitten broadcast --match-tab state:focused "Test broadcast message"'
	return kitty_command(cmd, use_socket)
end

-- Direct protocol test (JSON)
local function test_json_protocol()
	print("\n=== Testing direct JSON protocol ===")
	local json_cmd = '{"cmd":"ls","version":[0,14,2]}'
	local cmd = string.format("echo -en '\\eP@kitty-cmd%s\\e\\\\' | socat - %s", json_cmd, KITTY_SOCKET)

	print("Executing: " .. cmd)
	local result = execute_command(cmd)
	print("Result: " .. result)

	return result
end

-- Main test suite
local function run_tests(use_socket)
	print("=== Kitty MCP Integration Test Suite ===")
	print("Socket: " .. (use_socket and KITTY_SOCKET or "direct"))
	print("")

	-- Override use_socket to false if we're inside kitty
	if os.getenv("KITTY_WINDOW_ID") then
		print("Running inside kitty, using direct connection")
		use_socket = false
	end

	-- Test 1: List windows
	list_windows(use_socket)

	-- Test 2: Launch a test tab
	launch_tab("MCP Test Tab", "echo 'Hello from MCP test'; bash", use_socket)

	-- Wait a bit for the tab to open
	os.execute("sleep 1")

	-- Test 3: Send text to the new tab
	send_text("title:MCP Test Tab", 'echo "Text sent via remote control"', use_socket)

	-- Test 4: Find Neovim windows
	find_nvim_windows(use_socket)

	-- Test 5: Launch Neovim for testing
	launch_tab("Neovim Test", "/home/yuval/.local/bin/nvim /tmp/test_keymap.lua", use_socket)
	os.execute("sleep 2")

	-- Test 6: Send command to Neovim
	send_text("title:Neovim Test", ':echo "Hello from Kitty MCP"', use_socket)

	-- Test 7: List windows again to see changes
	list_windows(use_socket)

	-- Test 8: Focus test
	focus_window("title:MCP Test Tab", use_socket)

	-- Test 9: Clean up - close test windows
	print("\n=== Cleaning up test windows ===")
	close_window("title:MCP Test Tab", use_socket)
	close_window("title:Neovim Test", use_socket)
end

-- Interactive menu
local function interactive_menu()
	while true do
		print("\n=== Kitty MCP Test Menu ===")
		print("1. List all windows and tabs")
		print("2. Launch new tab")
		print("3. Launch new window")
		print("4. Send text to window")
		print("5. Find Neovim windows")
		print("6. Run full test suite")
		print("7. Test JSON protocol")
		print("8. Toggle socket usage")
		print("9. Toggle verbose mode")
		print("0. Exit")
		io.write("Choice: ")

		local choice = io.read()
		local use_socket = true

		if choice == "1" then
			list_windows(use_socket)
		elseif choice == "2" then
			io.write("Tab title: ")
			local title = io.read()
			io.write("Command (default: bash): ")
			local cmd = io.read()
			if cmd == "" then
				cmd = "bash"
			end
			launch_tab(title, cmd, use_socket)
		elseif choice == "3" then
			io.write("Window title: ")
			local title = io.read()
			io.write("Command (default: bash): ")
			local cmd = io.read()
			if cmd == "" then
				cmd = "bash"
			end
			launch_window(title, cmd, use_socket)
		elseif choice == "4" then
			io.write("Match criteria (e.g., title:MyTab): ")
			local match = io.read()
			io.write("Text to send: ")
			local text = io.read()
			send_text(match, text, use_socket)
		elseif choice == "5" then
			find_nvim_windows(use_socket)
		elseif choice == "6" then
			run_tests(use_socket)
		elseif choice == "7" then
			test_json_protocol()
		elseif choice == "8" then
			use_socket = not use_socket
			print("Socket usage: " .. tostring(use_socket))
		elseif choice == "9" then
			VERBOSE = not VERBOSE
			print("Verbose mode: " .. tostring(VERBOSE))
		elseif choice == "0" then
			break
		else
			print("Invalid choice")
		end
	end
end

-- Command line argument parsing
local function main(args)
	-- Auto-detect if we're inside kitty
	local use_socket = not os.getenv("KITTY_WINDOW_ID")

	if #args == 0 then
		interactive_menu()
	elseif args[1] == "test" then
		run_tests(use_socket)
	elseif args[1] == "list" then
		list_windows(use_socket)
	elseif args[1] == "help" then
		print([[
Usage: lua kitty-mcp.lua [command]

Commands:
    test     Run the full test suite
    list     List all windows and tabs
    help     Show this help message
    (none)   Start interactive menu

Examples:
    lua kitty-mcp.lua
    lua kitty-mcp.lua test
    lua kitty-mcp.lua list
]])
	else
		print("Unknown command: " .. args[1])
		print("Use 'help' for usage information")
	end
end

-- Module exports
local M = {
	-- Core functions
	execute_command = execute_command,
	kitty_command = kitty_command,

	-- Window/tab management
	list_windows = list_windows,
	launch_tab = launch_tab,
	launch_window = launch_window,
	launch_nvim_test = launch_nvim_test,
	focus_window = focus_window,
	close_window = close_window,

	-- Text and command sending
	send_text = send_text,
	send_nvim_command = send_nvim_command,
	send_nvim_lua = send_nvim_lua,
	send_nvim_write_file = send_nvim_write_file,
	send_nvim_require = send_nvim_require,
	send_nvim_call_function = send_nvim_call_function,

	-- Utility functions
	find_nvim_windows = find_nvim_windows,
	test_broadcast = test_broadcast,
	test_json_protocol = test_json_protocol,
	run_tests = run_tests,

	-- Configuration
	KITTY_SOCKET = KITTY_SOCKET,
	VERBOSE = VERBOSE,
}

-- Run as standalone script if executed directly
if arg and arg[0] and arg[0]:match("kitty%-mcp%.lua$") then
	main(arg or {})
end

-- Return module for require() usage
return M
