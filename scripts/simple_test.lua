#!/usr/bin/env lua

-- Simple test without using the full kitty-mcp module
-- Usage: lua simple_test.lua [use_pane]
local use_pane = (arg and arg[1] == "true") or false
local launch_type = use_pane and "window" or "tab"
local title_flag = use_pane and "--title" or "--tab-title"

print("Testing basic kitty " .. launch_type .. " launch...")

-- Create test file
local test_file = "scripts/tmp/simple_test.txt"
os.execute("mkdir -p scripts/tmp")

local file = io.open(test_file, "w")
if file then
	file:write("# Simple Test File\n\nThis is a test for kitty pane functionality.\n")
	file:close()
	print("✅ Test file created: " .. test_file)
else
	print("❌ Failed to create test file")
	return
end

-- Launch neovim
print("Launching neovim in " .. launch_type .. "...")
local cmd = string.format(
	'kitten @ launch --type=%s %s="Simple Test %s" nvim %s',
	launch_type,
	title_flag,
	launch_type:gsub("^%l", string.upper),
	test_file
)
print("Command: " .. cmd)

local handle = io.popen(cmd .. " 2>&1")
local output = handle:read("*a")
local success = handle:close()

print("Output: " .. (output or "none"))
if success then
	print("✅ Pane launched successfully")

	-- Wait for neovim to load
	print("Waiting for neovim to load...")
	os.execute("sleep 3")

	-- Test sending commands that actually modify the buffer
	print("Sending test commands...")
	local title_match = "Simple Test " .. launch_type:gsub("^%l", string.upper)

	-- First ensure we're in normal mode
	local send_cmd = string.format('kitten @ send-text --match "title:%s" "\\x1b"', title_match)
	os.execute(send_cmd)
	os.execute("sleep 0.2")

	-- Go to end of file and enter insert mode
	send_cmd = string.format('kitten @ send-text --match "title:%s" "Go"', title_match)
	os.execute(send_cmd)
	os.execute("sleep 0.2")

	-- Insert test text
	send_cmd = string.format(
		'kitten @ send-text --match "title:%s" "\\n\\n--- Test from kitty-mcp ---\\nThis line was added by the test script!"',
		title_match
	)
	os.execute(send_cmd)
	os.execute("sleep 0.2")

	-- Exit insert mode
	send_cmd = string.format('kitten @ send-text --match "title:%s" "\\x1b"', title_match)
	os.execute(send_cmd)
	os.execute("sleep 0.2")

	-- Save the file to verify
	send_cmd = string.format('kitten @ send-text --match "title:%s" ":w\\r"', title_match)
	os.execute(send_cmd)
	os.execute("sleep 0.5")

	print("✅ Commands sent to " .. launch_type)
	print("📝 Check the '" .. title_match .. "' " .. launch_type .. " to see if text was added")
	print("📁 Also check " .. test_file .. " to see if it was modified")
else
	print("❌ Failed to launch pane")
end
