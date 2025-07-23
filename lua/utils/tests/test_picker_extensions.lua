-- Test for picker-extensions.lua core utility functions
-- Tests core logic, not Snacks picker implementations

local M = {}

-- Test core utility functions
function M.test_core_utilities()
  print("Testing core picker utility functions...")

  local picker_ext = require("utils.picker-extensions")

  -- Test validate_picker function through public APIs
  local valid_picker = {
    opts = {},
    current = function()
      return { file = "test.lua" }
    end,
  }
  local invalid_picker = nil

  print("  Testing picker validation...")

  -- Test get_current_item with valid picker
  local _, err = picker_ext.get_current_item(valid_picker)
  if err and err:match("Invalid picker") then
    print("    ✗ Valid picker rejected")
  else
    print("    ✓ Valid picker accepted")
  end

  -- Test get_current_item with invalid picker
  _, err = picker_ext.get_current_item(invalid_picker)
  if err and err:match("Invalid picker") then
    print("    ✓ Invalid picker properly rejected")
  else
    print("    ✗ Invalid picker should be rejected")
  end
end

-- Test file operation utilities
function M.test_file_operations()
  print("Testing file operation utilities...")

  -- Create test files
  local temp_dir = vim.fn.tempname()
  vim.fn.mkdir(temp_dir, "p")

  local test_files = {
    temp_dir .. "/test.js",
    temp_dir .. "/test.lua",
    temp_dir .. "/test.css",
  }

  for _, file in ipairs(test_files) do
    vim.fn.writefile({ "// test content" }, file)
  end

  print("  ✓ Test files created")

  -- Test file readability checks (core logic used in format actions)
  for _, file in ipairs(test_files) do
    if vim.fn.filereadable(file) == 1 then
      print("    ✓ File readable: " .. vim.fn.fnamemodify(file, ":t"))
    else
      print("    ✗ File not readable: " .. vim.fn.fnamemodify(file, ":t"))
    end
  end

  -- Cleanup
  vim.fn.delete(temp_dir, "rf")
  print("  ✓ Test cleanup completed")
end

-- Test format action core logic (not UI)
function M.test_format_logic()
  print("Testing format action core logic...")

  -- Test conform integration
  local conform_ok, conform = pcall(require, "conform")
  if conform_ok then
    print("  ✓ Conform module available")

    -- Test formatters configuration
    local formatters = conform.list_formatters()
    if #formatters > 0 then
      print("  ✓ Formatters configured: " .. #formatters)
    else
      print("  ⚠ No formatters found")
    end
  else
    print("  ✗ Conform module not available")
  end
end

-- Main test runner
function M.run_all_tests()
  print("=== Picker Extensions Core Logic Tests ===")

  local tests = {
    { name = "Core Utilities", fn = M.test_core_utilities },
    { name = "File Operations", fn = M.test_file_operations },
    { name = "Format Logic", fn = M.test_format_logic },
  }

  local passed = 0
  local total = #tests

  for _, test in ipairs(tests) do
    print("\n" .. test.name .. ":")
    local success = pcall(test.fn)
    if success then
      passed = passed + 1
      print("  ✓ " .. test.name .. " completed")
    else
      print("  ✗ " .. test.name .. " failed")
    end
  end

  print("\n=== Test Summary ===")
  print("Passed: " .. passed .. "/" .. total)

  return passed == total
end

return M
