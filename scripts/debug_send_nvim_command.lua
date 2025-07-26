#!/usr/bin/env lua

-- Debug send_nvim_command step by step
print("=== Debug send_nvim_command components ===")

-- Find an existing neovim window to test on
local handle = io.popen("kitten @ ls | jq '.[] | .tabs[] | .windows[] | select(.user_vars.IS_NVIM) | .id' | head -1")
local window_id = handle:read("*l")
handle:close()

if not window_id or window_id == "" then
	print("❌ No neovim window found. Please open a neovim window first.")
	return
end

print("🎯 Testing on window ID: " .. window_id)

-- Test 1: Escape sequence (ensure normal mode)
print("\n=== Test 1: Escape sequence ===")
local cmd1 = string.format('kitten @ send-text --match "id:%s" "\\x1b"', window_id)
print("Command: " .. cmd1)
os.execute(cmd1)
os.execute("sleep 1")
print("✅ Escape sent (should ensure normal mode)")

-- Test 2: Command entry (without execution)
print("\n=== Test 2: Command entry ===")
local cmd2 = string.format('kitten @ send-text --match "id:%s" ":echo \\"TEST MESSAGE\\""', window_id)
print("Command: " .. cmd2)
os.execute(cmd2)
os.execute("sleep 1")
print("✅ Command sent (should see ':echo \"TEST MESSAGE\"' in command line)")

-- Test 3: Command execution (Enter key)
print("\n=== Test 3: Command execution ===")
local cmd3 = string.format('kitten @ send-text --match "id:%s" "\\r"', window_id)
print("Command: " .. cmd3)
os.execute(cmd3)
os.execute("sleep 1")
print("✅ Enter sent (should execute command and show TEST MESSAGE)")

-- Test 4: All together (buffer modification)
print("\n=== Test 4: All together (buffer modification) ===")
print("Adding text to buffer...")

-- Go to end and enter insert mode
local cmd4a = string.format('kitten @ send-text --match "id:%s" "Go"', window_id)
os.execute(cmd4a)
os.execute("sleep 0.5")

-- Add text
local cmd4b = string.format('kitten @ send-text --match "id:%s" "\\nDEBUG TEST: %s"', window_id, os.date())
os.execute(cmd4b)
os.execute("sleep 0.5")

-- Exit insert mode
local cmd4c = string.format('kitten @ send-text --match "id:%s" "\\x1b"', window_id)
os.execute(cmd4c)
os.execute("sleep 0.5")

-- Save file (all in one)
local cmd4d = string.format('kitten @ send-text --match "id:%s" ":w\\r"', window_id)
print("Save command: " .. cmd4d)
os.execute(cmd4d)
os.execute("sleep 0.5")

print("✅ Complete test done - check the neovim window for:")
print("  1. 'TEST MESSAGE' should have appeared")
print("  2. Text should be added to the buffer")
print("  3. File should be saved")

