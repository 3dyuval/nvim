-- Integration test for the formatter API
-- Run this with: nvim --headless -c "source test-integration.lua" -c "qa"

print("=== Testing Formatter Integration ===")

-- Test 1: Check if formatter module loads
local success, formatter = pcall(require, "utils.formatter")
if success then
  print("✓ Formatter module loaded successfully")
else
  print("✗ Failed to load formatter module: " .. formatter)
  return
end

-- Test 2: Check if CLI script exists
local script_path = vim.fn.expand("~/.config/nvim/format")
if vim.fn.executable(script_path) == 1 then
  print("✓ CLI formatter script found and executable")
else
  print("✗ CLI formatter script not found or not executable")
  return
end

-- Test 3: Check if picker-extensions module loads
local success, picker_extensions = pcall(require, "utils.picker-extensions")
if success then
  print("✓ Picker extensions module loaded successfully")
else
  print("✗ Failed to load picker extensions module: " .. picker_extensions)
  return
end

-- Test 4: Check if save-patterns module loads
local success, save_patterns = pcall(require, "utils.save-patterns")
if success then
  print("✓ Save patterns module loaded successfully")
else
  print("✗ Failed to load save patterns module: " .. save_patterns)
  return
end

-- Test 5: Create a test file and format it
local test_file = vim.fn.tempname() .. ".js"
vim.fn.writefile({
  "const   x=1;const   y=2;",
  "function test(a,b){return a+b}"
}, test_file)

print("✓ Created test file: " .. test_file)

-- Test 6: Test the async formatter API
local completion_status = nil
local job_id = formatter.format_file(test_file, {
  verbose = true,
  on_progress = function(status)
    print("  Progress: " .. status.message)
  end,
  on_complete = function(status)
    completion_status = status
    print("  Completed: " .. status.message)
  end
})

if job_id then
  print("✓ Formatter job started with ID: " .. job_id)
  
  -- Wait for completion
  local timeout = 0
  while completion_status == nil and timeout < 50 do
    vim.wait(100)
    timeout = timeout + 1
  end
  
  if completion_status then
    if completion_status.exit_code == 0 then
      print("✓ Formatting completed successfully")
    else
      print("⚠ Formatting completed with warnings/errors (exit code: " .. completion_status.exit_code .. ")")
      print("  This is normal for files with linting warnings")
    end
  else
    print("✗ Formatting timed out")
  end
else
  print("✗ Failed to start formatter job")
end

-- Test 7: Check file was actually formatted
local formatted_content = vim.fn.readfile(test_file)
if #formatted_content > 0 then
  print("✓ Test file content after formatting:")
  for i, line in ipairs(formatted_content) do
    print("  " .. i .. ": " .. line)
  end
  
  -- Check if formatting actually changed the content
  local original_line = "const   x=1;const   y=2;"
  local formatted_line = formatted_content[1]
  if formatted_line and formatted_line ~= original_line then
    print("✓ File was actually formatted (content changed)")
  else
    print("⚠ File content might not have changed")
  end
else
  print("✗ Test file is empty after formatting")
end

-- Test 8: Test the setup functionality
local setup_success = pcall(formatter.setup, {
  verbose = true,
  auto_notification = true
})

if setup_success then
  print("✓ Formatter setup completed successfully")
else
  print("✗ Formatter setup failed")
end

-- Test 9: Check if user commands were created
local commands = vim.api.nvim_get_commands({})
if commands.Format and commands.FormatCheck and commands.FormatJobs then
  print("✓ User commands created successfully")
else
  print("✗ User commands not created properly")
end

-- Cleanup
vim.fn.delete(test_file)
print("✓ Test file cleaned up")

print("=== Integration Test Complete ===")