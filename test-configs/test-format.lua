-- Test Lua formatting
local function test_function(param1, param2)
  if param1 == param2 then
    return true
  else
    return false
  end
end

-- Test table formatting
local tbl = { a = 1, b = 2, c = 3, d = 4 }

-- Test array formatting
local arr = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }

return { test_function = test_function, tbl = tbl, arr = arr }
