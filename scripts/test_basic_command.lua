#!/usr/bin/env lua

-- Test if basic commands are working at all
local kitty = require("kitty-mcp")

print("=== BASIC COMMAND TEST ===")

-- Launch neovim with a small test file
local test_file = "scripts/tmp/basic_test.txt"
local result, success, created_file = kitty.launch_nvim_test("Basic Test", test_file, true, false)

if not success then
	print("❌ Failed to launch neovim")
	os.exit(1)
end

local match = "title:Basic Test"

print("✅ Neovim launched. Testing basic commands...")
print("Press Enter when ready:")
io.read()

-- Test 1: Just try to show line numbers
print("Test 1: Show line numbers (:set number)")
kitty.send_nvim_command(match, "set number", false)
os.execute("sleep 2")

-- Test 2: Try to echo something
print("Test 2: Echo test (:echo 'hello')")
kitty.send_nvim_command(match, "echo 'hello'", false)
os.execute("sleep 2")

-- Test 3: Try to write the file
print("Test 3: Write file (:w)")
kitty.send_nvim_command(match, "w", false)
os.execute("sleep 2")

print("\n🔍 Check the Basic Test window:")
print("1. Do you see line numbers appear?")
print("2. Do you see 'hello' message?")
print("3. Do you see any write confirmation?")
print("4. Are any commands visible in command line mode?")

