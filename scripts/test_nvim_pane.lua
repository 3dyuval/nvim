#!/usr/bin/env lua

-- Test script for neovim pane functionality
dofile("scripts/kitty-mcp.lua")

print("Testing Neovim pane launch and command sending...")

-- Test launching neovim in a pane
local test_file = "scripts/tmp/test_nvim_pane.txt"
local result, success, created_file = launch_nvim_test("Test Neovim Pane", test_file, true, false)

if success then
	print("✅ Neovim pane launched successfully")
	print("📁 Test file: " .. (created_file or "unknown"))

	-- Test sending a command
	local match_criteria = "title:Test Neovim Pane"

	-- Send a simple echo command
	send_nvim_command(match_criteria, 'echo "Hello from test script!"', false)

	print("✅ Command sent to Neovim pane")
	print("📝 Check the 'Test Neovim Pane' window to see the result")
else
	print("❌ Failed to launch Neovim pane")
end

