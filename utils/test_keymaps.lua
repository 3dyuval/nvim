#!/usr/bin/env lua

-- keymap_tester.lua
-- Usage: echo 'keymaps_lua_table' | lua keymap_tester.lua
-- Or: lua keymap_tester.lua < keymaps.lua

-- Simple table serializer (replacement for vim.inspect)
local function serialize_table(t, indent)
  indent = indent or 0
  local spaces = string.rep("  ", indent)

  if type(t) ~= "table" then
    if type(t) == "string" then
      return string.format('"%s"', t:gsub('"', '\\"'))
    else
      return tostring(t)
    end
  end

  local result = "{\n"
  for k, v in pairs(t) do
    local key_str
    if type(k) == "string" then
      key_str = string.format("%s = ", k)
    else
      key_str = string.format("[%s] = ", k)
    end

    result = result .. spaces .. "  " .. key_str .. serialize_table(v, indent + 1) .. ",\n"
  end
  result = result .. spaces .. "}"

  return result
end

local function test_keymaps(keymaps)
  -- Create a temporary test file
  local test_file = "/tmp/nvim_keymap_test.lua"

  -- Generate test script content
  local test_content = [[
-- Keymap conflict tester
local conflicts = {}
local existing_keymaps = {}

-- Capture existing keymaps
local function capture_existing_keymaps()
    for _, mode in ipairs({'n', 'i', 'v', 'x', 'o', 'c', 't'}) do
        existing_keymaps[mode] = {}
        local maps = vim.api.nvim_get_keymap(mode)
        for _, map in ipairs(maps) do
            existing_keymaps[mode][map.lhs] = {
                rhs = map.rhs or '',
                desc = map.desc or '',
                buffer = map.buffer or false
            }
        end
    end
end

-- Test new keymaps for conflicts
local function test_keymap_conflicts(new_keymaps)
    for _, keymap in ipairs(new_keymaps) do
        local mode = keymap.mode or 'n'
        local lhs = keymap.lhs
        local rhs = keymap.rhs
        local desc = keymap.desc or ''
        
        if existing_keymaps[mode] and existing_keymaps[mode][lhs] then
            table.insert(conflicts, {
                mode = mode,
                key = lhs,
                existing_rhs = existing_keymaps[mode][lhs].rhs,
                existing_desc = existing_keymaps[mode][lhs].desc,
                new_rhs = rhs,
                new_desc = desc
            })
        end
    end
end

-- Capture existing keymaps first
capture_existing_keymaps()

-- Test keymaps from input
local test_keymaps = ]] .. serialize_table(keymaps) .. [[

test_keymap_conflicts(test_keymaps)

-- Output results to stdout
if #conflicts > 0 then
    print("CONFLICTS FOUND:")
    for _, conflict in ipairs(conflicts) do
        print(string.format("Mode: %s, Key: %s", conflict.mode, conflict.key))
        print(string.format("  Existing: %s (%s)", conflict.existing_rhs, conflict.existing_desc))
        print(string.format("  New: %s (%s)", conflict.new_rhs, conflict.new_desc))
        print("---")
    end
else
    print("NO CONFLICTS FOUND")
end

-- Exit nvim
vim.cmd('qall!')
]]

  -- Write test file
  local file = io.open(test_file, "w")
  if not file then
    print("Error: Could not create test file")
    return false
  end
  file:write(test_content)
  file:close()

  -- Run nvim in headless mode
  local cmd = string.format("nvim --headless -u NONE -c 'source %s'", test_file)
  local success = os.execute(cmd)

  -- Cleanup
  os.remove(test_file)

  return success == 0
end

-- Read from stdin
local function read_stdin()
  local input = ""
  for line in io.lines() do
    input = input .. line .. "\n"
  end
  return input:gsub("\n$", "") -- Remove trailing newline
end

-- Main logic
local keymaps = nil

-- Simple way to check if we have stdin input
local input_available = false
local stdin_content = ""

-- Check if we can read from stdin immediately
local success, result = pcall(function()
  local line = io.read("*line")
  if line then
    stdin_content = line .. "\n"
    -- Read the rest
    for additional_line in io.lines() do
      stdin_content = stdin_content .. additional_line .. "\n"
    end
    input_available = true
  end
end)

if input_available and stdin_content ~= "" then
  -- Remove trailing newline
  stdin_content = stdin_content:gsub("\n$", "")

  -- Try to evaluate as Lua table
  local func, load_err = load("return " .. stdin_content)
  if func then
    local eval_success, result = pcall(func)
    if eval_success then
      keymaps = result
    else
      print("Error evaluating input:", result)
      os.exit(1)
    end
  else
    print("Error loading input:", load_err)
    print("Make sure your input is a valid Lua table")
    os.exit(1)
  end
else
  -- Use example keymaps for testing
  keymaps = {
    { mode = "n", lhs = "<leader>ff", rhs = ":Telescope find_files<CR>", desc = "Find files" },
    { mode = "n", lhs = "<leader>fg", rhs = ":Telescope live_grep<CR>", desc = "Live grep" },
    { mode = "n", lhs = "<C-h>", rhs = "<C-w>h", desc = "Window left" },
    { mode = "i", lhs = "jk", rhs = "<Esc>", desc = "Exit insert mode" },
    { mode = "v", lhs = "<leader>y", rhs = '"+y', desc = "Copy to clipboard" },
  }
  print("No stdin input detected, using example keymaps...")
end

-- Run the test
print("Testing keymaps for conflicts...")
test_keymaps(keymaps)
