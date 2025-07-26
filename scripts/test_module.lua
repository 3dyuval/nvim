#!/usr/bin/env lua

-- Test the kitty-mcp module functionality
local kitty = require("scripts.kitty-mcp")

print("Testing kitty-mcp as module...")

-- Test 1: Launch neovim in pane
local test_file = "scripts/tmp/module_test.txt"
local result, success, created_file = kitty.launch_nvim_test("Module Test", test_file, true, false)

if success then
	print("✅ Module launched neovim successfully")

	-- Test 2: Send a simple command
	kitty.send_nvim_command("title:Module Test", "echo 'Hello from module!'", false)

	-- Test 3: Test lua execution
	kitty.send_nvim_lua("title:Module Test", "print('Lua execution test')", false)

	-- Test 4: Write file test
	kitty.send_nvim_write_file("title:Module Test", "scripts/tmp/module_output.txt", "Module test successful!", false)

	print("✅ All module tests sent")
	print("📝 Check the 'Module Test' window and scripts/tmp/module_output.txt")
else
	print("❌ Failed to launch neovim with module")
end

