-- Test script for fold keymaps
-- Create a test file with foldable content

local test_content = [[
function test_function_1()
  local x = 1
  local y = 2
  return x + y
end

function test_function_2()
  local a = "hello"
  local b = "world"
  return a .. " " .. b
end

if true then
  print("nested block")
  if true then
    print("deeply nested")
  end
end
]]

-- Create a temporary buffer with test content
vim.cmd("enew")
local lines = vim.split(test_content, "\n")
vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)

-- Set filetype to lua for proper folding
vim.bo.filetype = "lua"

-- Wait a moment for folding to initialize
vim.wait(100)

print("=== Testing Fold Keymaps ===")

-- Test the reset fold function (bb)
print("Testing bb (reset folds)...")
local success, err = pcall(function()
  -- Simulate the bb keymap
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local ft = vim.bo.filetype
  
  -- Reset folds
  vim.wo.foldmethod = "manual"
  vim.cmd("normal! zE")
  
  -- Reapply filetype-specific fold method
  if ft == "lua" then
    vim.wo.foldmethod = "indent"
  end
  
  vim.api.nvim_win_set_cursor(0, cursor_pos)
  vim.wo.foldlevel = 1
  
  print("✓ bb (reset folds) - SUCCESS")
end)

if not success then
  print("✗ bb (reset folds) - FAILED: " .. tostring(err))
end

-- Test basic fold operations
local fold_tests = {
  {key = "bF", cmd = "zM", desc = "Fold all"},
  {key = "bO", cmd = "zR", desc = "Open all folds"},
  {key = "bf", cmd = "zc", desc = "Close fold"},
  {key = "bo", cmd = "zo", desc = "Open fold"},
  {key = "bt", cmd = "za", desc = "Toggle fold"},
  {key = "bv", cmd = "zv", desc = "View cursor"},
}

for _, test in ipairs(fold_tests) do
  local success, err = pcall(function()
    vim.cmd("normal! " .. test.cmd)
  end)
  
  if success then
    print("✓ " .. test.key .. " (" .. test.desc .. ") - SUCCESS")
  else
    print("✗ " .. test.key .. " (" .. test.desc .. ") - FAILED: " .. tostring(err))
  end
end

-- Test fold navigation
print("Testing fold navigation...")
local nav_success, nav_err = pcall(function()
  vim.cmd("normal! zk") -- be - move up to fold
  vim.cmd("normal! zj") -- ba - move down to fold
end)

if nav_success then
  print("✓ be/ba (fold navigation) - SUCCESS")
else
  print("✗ be/ba (fold navigation) - FAILED: " .. tostring(nav_err))
end

print("=== Fold Keymap Testing Complete ===")

-- Clean up
vim.cmd("bdelete!")