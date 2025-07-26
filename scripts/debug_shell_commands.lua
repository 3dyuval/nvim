#!/usr/bin/env lua

-- Debug what shell commands we're actually executing
local kitty = require("kitty-mcp")

print("=== DEBUGGING SHELL COMMAND EXECUTION ===")

local match = "title:Basic Test"

-- Let's see what the actual shell command looks like
local function debug_kitty_command(cmd)
	local full_cmd = string.format("kitten @ %s", cmd)
	print("EXACT COMMAND: " .. full_cmd)
	print("COMMAND LENGTH: " .. #full_cmd)
	print("COMMAND BYTES:")
	for i = 1, #full_cmd do
		local char = full_cmd:sub(i, i)
		local byte = string.byte(char)
		print(string.format("  [%d] '%s' (0x%02x)", i, char, byte))
	end
	print("---")
	return os.execute(full_cmd)
end

print("Testing individual send-text commands:")

print("\n1. Escape command:")
debug_kitty_command(string.format("send-text --match '%s' \"\\x1b\"", match))

print("\n2. Colon command:")
debug_kitty_command(string.format("send-text --match '%s' \":\"", match))

print("\n3. Echo command:")
debug_kitty_command(string.format("send-text --match '%s' \"echo test\"", match))

print("\n4. Enter command:")
debug_kitty_command(string.format("send-text --match '%s' \"\\r\"", match))

print("\nTry running these exact commands manually to see if they work!")

