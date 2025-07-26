#!/usr/bin/env lua

-- Test buffer modification using kitty-mcp module
local kitty = require("kitty-mcp")

print("Testing buffer modification with kitty-mcp module...")

-- Launch neovim
local test_file = "scripts/tmp/buffer_test.txt"
local result, success, created_file = kitty.launch_nvim_test("Buffer Test", test_file, true, false)

if success then
	print("✅ Neovim launched, now testing buffer modification...")

	local match = "title:Buffer Test"

	-- Method 1: Use vim normal mode commands to add text
	print("Adding text using normal mode commands...")

	-- Go to end of file and enter insert mode
	kitty.send_text(match, "Go", false)
	os.execute("sleep 0.3")

	-- Add visible test content
	kitty.send_text(
		match,
		"\n\n--- BUFFER MODIFICATION TEST ---\nThis text was added by kitty-mcp module!\nTime: " .. os.date(),
		false
	)
	os.execute("sleep 0.3")

	-- Exit insert mode
	kitty.send_text(match, "\x1b", false)
	os.execute("sleep 0.3")

	-- Save the file
	kitty.send_nvim_command(match, "w", false)

	print("✅ Buffer modification commands sent")
	print("📝 Check the 'Buffer Test' window to see if text was added")
	print("📁 Check " .. test_file .. " to see if it was saved")
else
	print("❌ Failed to launch neovim")
end
