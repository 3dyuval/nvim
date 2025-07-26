#!/usr/bin/env lua

-- Simple visual test to see if commands are working
local kitty = require("kitty-mcp")

print("=== SIMPLE VISUAL TEST ===")

-- Launch neovim with a small test file
local test_file = "scripts/tmp/visual_test.txt"
local result, success, created_file = kitty.launch_nvim_test("Visual Test", test_file, true, false)

if not success then
	print("❌ Failed to launch neovim")
	os.exit(1)
end

local match = "title:Visual Test"

print("✅ Neovim launched. Now watch the window while we send commands...")
print("Press Enter when ready to start the visual test:")
io.read()

-- Test 1: Simple character insertion
print("Sending: ESC + i + 'HELLO' + ESC")
kitty.send_text(match, "\x1bi", false) -- ESC + i (insert mode)
os.execute("sleep 0.2")
kitty.send_text(match, "HELLO", false) -- Type HELLO
os.execute("sleep 0.2")
kitty.send_text(match, "\x1b", false) -- ESC (back to normal)
os.execute("sleep 1")

-- Test 2: Command mode test
print("Sending command: :echo 'Command mode test'")
kitty.send_nvim_command(match, "echo 'Command mode test'", false)
os.execute("sleep 2")

-- Test 3: Save command
print("Sending: :w")
kitty.send_nvim_command(match, "w", false)

print("\n🔍 Check the Visual Test window:")
print("1. Did you see 'HELLO' appear in the buffer?")
print("2. Did you see the echo message in the command line?")
print("3. Did you see the save confirmation?")
print("\nFile location:", created_file)

