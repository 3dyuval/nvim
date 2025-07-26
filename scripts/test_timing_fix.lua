#!/usr/bin/env lua

-- Test the three critical components of send_nvim_command with proper timing
local kitty = require("kitty-mcp")

print("=== TESTING NEOVIM COMMAND COMPONENTS WITH PROPER TIMING ===")
print()

-- First, launch a simple neovim instance
local test_file = "scripts/tmp/timing_test.txt"
local result, success, created_file = kitty.launch_nvim_test("Timing Test", test_file, true, false)

if not success then
	print("❌ Failed to launch neovim")
	os.exit(1)
end

print("✅ Neovim launched. Testing individual components...")
print()

local match = "title:Timing Test"

-- Test 1: Can we execute a simple write command?
print("📝 Test 1: Simple write command")
kitty.send_nvim_command(match, "w", false)
os.execute("sleep 1")

-- Check if file was modified
local file = io.open(created_file, "r")
if file then
	local content = file:read("*a")
	file:close()
	print("File size after write:", #content, "bytes")
else
	print("❌ Could not read file")
end

-- Test 2: Add a line and save
print("\n📝 Test 2: Add text and save")
kitty.send_nvim_command(match, "normal Go", false) -- Go to end and add new line
os.execute("sleep 0.5")
kitty.send_nvim_command(match, "normal a--- Test successful at " .. os.date() .. " ---", false)
os.execute("sleep 0.5")
kitty.send_nvim_command(match, "w", false)
os.execute("sleep 1")

-- Check if content was added
file = io.open(created_file, "r")
if file then
	local content = file:read("*a")
	file:close()
	if content:find("Test successful") then
		print("✅ Content was added and saved!")
		print("Final file content length:", #content, "bytes")
	else
		print("❌ Content was not added")
		print("Current content preview:", content:sub(1, 200) .. "...")
	end
else
	print("❌ Could not read file after test")
end

print("\n🔍 Check the 'Timing Test' window to verify commands executed")
print("📁 File location:", created_file)

