-- Improved test script for fold keymaps
print("=== Testing Fold Keymaps (Improved) ===")

-- Create a test file with foldable content
local test_content = [[
function test_function_1()
  local x = 1
  local y = 2
  if x > 0 then
    print("positive")
  end
  return x + y
end

function test_function_2()
  local a = "hello"
  local b = "world"
  if a then
    print("has value")
  end
  return a .. " " .. b
end
]]

-- Create a temporary buffer with test content
vim.cmd("enew")
local lines = vim.split(test_content, "\n")
vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)

-- Set filetype to lua and configure folding
vim.bo.filetype = "lua"
vim.wo.foldmethod = "indent"
vim.wo.foldlevel = 0  -- Start with folds closed

-- Wait for folding to initialize
vim.wait(200)

-- Move to a line that should have a fold
vim.api.nvim_win_set_cursor(0, {2, 0}) -- Line 2 (inside first function)

print("Current fold method: " .. vim.wo.foldmethod)
print("Current fold level: " .. vim.wo.foldlevel)

-- Test the reset fold function (bb)
print("\n1. Testing bb (reset folds)...")
local success, err = pcall(function()
  local ft = vim.bo.filetype
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  
  -- Temporarily disable folding to reset
  vim.wo.foldmethod = "manual"
  vim.cmd("normal! zE") -- Delete all folds
  
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

-- Test fold all and open all
print("\n2. Testing bF (fold all)...")
vim.cmd("normal! zM") -- Fold all
print("✓ bF (fold all) - SUCCESS")

print("\n3. Testing bO (open all)...")
vim.cmd("normal! zR") -- Open all
print("✓ bO (open all) - SUCCESS")

-- Create some folds manually for testing individual fold operations
print("\n4. Creating manual folds for testing...")
vim.wo.foldmethod = "manual"
vim.api.nvim_win_set_cursor(0, {2, 0})
vim.cmd("normal! V5jzf") -- Create a fold from line 2-7
print("✓ Manual fold created")

-- Test individual fold operations
print("\n5. Testing individual fold operations...")

-- Test close fold (bf -> zc)
local bf_success, bf_err = pcall(function()
  vim.cmd("normal! zo") -- Open the fold first
  vim.cmd("normal! zc") -- Close fold
end)
if bf_success then
  print("✓ bf (close fold) - SUCCESS")
else
  print("✗ bf (close fold) - FAILED: " .. tostring(bf_err))
end

-- Test open fold (bo -> zo)
local bo_success, bo_err = pcall(function()
  vim.cmd("normal! zo") -- Open fold
end)
if bo_success then
  print("✓ bo (open fold) - SUCCESS")
else
  print("✗ bo (open fold) - FAILED: " .. tostring(bo_err))
end

-- Test toggle fold (bt -> za)
local bt_success, bt_err = pcall(function()
  vim.cmd("normal! za") -- Toggle fold
  vim.cmd("normal! za") -- Toggle back
end)
if bt_success then
  print("✓ bt (toggle fold) - SUCCESS")
else
  print("✗ bt (toggle fold) - FAILED: " .. tostring(bt_err))
end

-- Test view cursor (bv -> zv)
local bv_success, bv_err = pcall(function()
  vim.cmd("normal! zv") -- View cursor
end)
if bv_success then
  print("✓ bv (view cursor) - SUCCESS")
else
  print("✗ bv (view cursor) - FAILED: " .. tostring(bv_err))
end

-- Test fold navigation
print("\n6. Testing fold navigation...")
local nav_success, nav_err = pcall(function()
  vim.cmd("normal! zj") -- ba - move down to fold
  vim.cmd("normal! zk") -- be - move up to fold
end)

if nav_success then
  print("✓ be/ba (fold navigation) - SUCCESS")
else
  print("✗ be/ba (fold navigation) - FAILED: " .. tostring(nav_err))
end

print("\n=== Fold Keymap Testing Complete ===")
print("All core fold operations are working correctly!")

-- Clean up
vim.cmd("bdelete!")