-- Test the actual keymaps defined in keymaps.lua
print("=== Testing Actual Fold Keymaps ===")

-- Load the keymaps configuration
local success, err = pcall(function()
  dofile(vim.fn.stdpath("config") .. "/lua/config/keymaps.lua")
end)

if not success then
  print("✗ Failed to load keymaps.lua: " .. tostring(err))
  return
end

print("✓ Keymaps loaded successfully")

-- Create test content
local test_content = [[
function test_function()
  local x = 1
  if x > 0 then
    print("positive")
  end
  return x
end
]]

vim.cmd("enew")
local lines = vim.split(test_content, "\n")
vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
vim.bo.filetype = "lua"
vim.wo.foldmethod = "indent"
vim.wo.foldlevel = 0

-- Wait for folding
vim.wait(200)

-- Test each keymap by checking if it's defined
local keymaps_to_test = {
  {key = "bb", desc = "Reset folds for filetype"},
  {key = "be", desc = "Move up to fold"},
  {key = "ba", desc = "Move down to fold"},
  {key = "bf", desc = "Close fold"},
  {key = "bo", desc = "Open fold"},
  {key = "bt", desc = "Toggle fold"},
  {key = "bv", desc = "View cursor"},
  {key = "bF", desc = "Fold entire buffer"},
  {key = "bO", desc = "Open all folds"},
}

print("\nChecking keymap definitions:")
for _, keymap in ipairs(keymaps_to_test) do
  local maps = vim.api.nvim_get_keymap('n')
  local found = false
  
  for _, map in ipairs(maps) do
    if map.lhs == keymap.key then
      found = true
      print("✓ " .. keymap.key .. " (" .. keymap.desc .. ") - DEFINED")
      break
    end
  end
  
  if not found then
    print("✗ " .. keymap.key .. " (" .. keymap.desc .. ") - NOT FOUND")
  end
end

-- Test the bb (reset folds) function specifically
print("\nTesting bb (reset folds) function:")
vim.api.nvim_win_set_cursor(0, {2, 0})

local bb_success, bb_err = pcall(function()
  -- Find the bb keymap and execute its function
  local maps = vim.api.nvim_get_keymap('n')
  for _, map in ipairs(maps) do
    if map.lhs == "bb" then
      if map.callback then
        map.callback()
        print("✓ bb function executed successfully")
      else
        print("✗ bb keymap found but no callback function")
      end
      break
    end
  end
end)

if not bb_success then
  print("✗ bb function failed: " .. tostring(bb_err))
end

print("\n=== Actual Keymap Testing Complete ===")

-- Clean up
vim.cmd("bdelete!")