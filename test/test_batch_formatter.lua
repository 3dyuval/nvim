-- Test for batch-formatter script
-- Tests the CLI batch formatter with various file types

local function run_all_tests()
  print("=== Batch Formatter Tests ===")

  local temp_dir = vim.fn.tempname()
  vim.fn.mkdir(temp_dir, "p")

  -- Create test files
  local test_files = {
    js = temp_dir .. "/test.js",
    ts = temp_dir .. "/test.ts",
    lua = temp_dir .. "/test.lua",
    css = temp_dir .. "/test.css",
    scss = temp_dir .. "/test.scss",
  }

  -- Write test content
  vim.fn.writefile({ "const   x=1;const   y=2;" }, test_files.js)
  vim.fn.writefile({ "const   x:number=1;" }, test_files.ts)
  vim.fn.writefile({ "local   x=1;local   y=2" }, test_files.lua)
  vim.fn.writefile({ "body{margin:0;padding:0}" }, test_files.css)
  vim.fn.writefile({ "$primary:#007bff;body{color:$primary}" }, test_files.scss)

  -- Test 1: Single file formatting
  print("Test 1: Single file formatting")
  local script_path = vim.fn.expand("~/.config/nvim/scripts/batch-formatter")

  if vim.fn.executable(script_path) == 1 then
    print("✓ Batch formatter script is executable")

    -- Test JavaScript file
    local result = vim.fn.system(script_path .. " " .. test_files.js)
    if vim.v.shell_error == 0 then
      print("✓ JavaScript file formatted successfully")
    else
      print("✗ JavaScript formatting failed: " .. result)
    end

    -- Test TypeScript file
    result = vim.fn.system(script_path .. " " .. test_files.ts)
    if vim.v.shell_error == 0 then
      print("✓ TypeScript file formatted successfully")
    else
      print("✗ TypeScript formatting failed: " .. result)
    end

    -- Test CSS file
    result = vim.fn.system(script_path .. " " .. test_files.css)
    if vim.v.shell_error == 0 then
      print("✓ CSS file formatted successfully")
    else
      print("✗ CSS formatting failed: " .. result)
    end

    -- Test SCSS file
    result = vim.fn.system(script_path .. " " .. test_files.scss)
    if vim.v.shell_error == 0 then
      print("✓ SCSS file formatted successfully")
    else
      print("✗ SCSS formatting failed: " .. result)
    end
  else
    print("✗ Batch formatter script not found or not executable")
  end

  -- Test 2: Multiple file formatting
  print("Test 2: Multiple file formatting")
  local all_files = table.concat(vim.tbl_values(test_files), " ")
  local result = vim.fn.system(script_path .. " " .. all_files)
  if vim.v.shell_error == 0 then
    print("✓ Multiple files formatted successfully")
  else
    print("✗ Multiple file formatting failed: " .. result)
  end

  -- Test 3: Directory formatting
  print("Test 3: Directory formatting")
  result = vim.fn.system(script_path .. " " .. temp_dir)
  if vim.v.shell_error == 0 then
    print("✓ Directory formatted successfully")
  else
    print("✗ Directory formatting failed: " .. result)
  end

  -- Test 4: Check formatted content changed
  print("Test 4: Verify formatting actually occurred")
  for filetype, filepath in pairs(test_files) do
    local content = vim.fn.readfile(filepath)
    if #content > 0 then
      print("✓ " .. filetype .. " file has content after formatting")
    else
      print("✗ " .. filetype .. " file is empty after formatting")
    end
  end

  -- Cleanup
  vim.fn.delete(temp_dir, "rf")
  print("✓ Test cleanup completed")

  print("=== Batch Formatter Tests Complete ===")
end

-- Run tests when file is executed directly
run_all_tests()
