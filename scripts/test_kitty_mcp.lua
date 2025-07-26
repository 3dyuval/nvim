#!/usr/bin/env lua

-- Load the kitty-mcp functions
package.path = package.path .. ";./scripts/?.lua"
local kitty_mcp = dofile("scripts/kitty-mcp.lua")

-- Test sending a command to neovim
print("Testing kitty-mcp send_text to neovim...")

-- Try to send an escape key first
os.execute('kitten @ send-text --match "var:IS_NVIM" "\\x1b"')
os.execute("sleep 0.2")

-- Then send the echo command
os.execute('kitten @ send-text --match "var:IS_NVIM" ":echo \\"Hello from kitty-mcp test\\""')
os.execute("sleep 0.2")

-- Send enter
os.execute('kitten @ send-text --match "var:IS_NVIM" "\\r"')

print("Command sent! Check the neovim window.")

