-- Keymap Utils - Utility functions and flags
-- Minimal implementation of lil.nvim utils for keymap-utils

local M = {}

-- Shallow table copy
local function copy(tbl)
  local result = {}
  for key, value in pairs(tbl) do
    result[key] = value
  end
  return result
end
M.copy = copy

-- Debug printing helper
local function printable(value, nest)
  if nest == nil then
    nest = 9
  end
  if type(value) == "string" then
    return value
  elseif type(value) == "table" then
    if nest <= 0 then
      return "{...}"
    end
    local result = {}
    for key, val in pairs(value) do
      table.insert(result, printable(key, nest - 1) .. "=" .. printable(val, nest - 1))
    end
    return "{" .. table.concat(result, ", ") .. "}"
  elseif type(value) == "function" then
    return "F" .. string.sub(tostring(value), 12) .. ""
  end
  return tostring(value)
end
M.printable = printable

-- Unique flag objects (empty tables as unique keys)
M.flags = {
  opts = {},
  func = function() end, -- highlight as function
  disabled = {},
  mode = {},
  log = {},
  raw = {},
}

-- Symbol lookup table for flag detection
M.symbols = {
  [M.flags.opts] = true,
  [M.flags.func] = true,
  [M.flags.raw] = true,
  [M.flags.disabled] = true,
  [M.flags.mode] = true,
  [M.flags.log] = true,
}

-- Cascade symbols from source to target
-- Merges flag values from source table into a copy of target
function M.cascadeSymbols(target, source)
  source = type(source) == "table" and source or {}
  local result = {}
  for key, value in pairs(target) do
    result[key] = value
  end
  for key, value in pairs(source) do
    if M.symbols[key] then
      result[key] = value
    end
  end
  return result
end

-- Debug logging for keymaps
function M.logmap(m, l, r, o)
  print(printable(m), printable(l), printable(r), printable(o))
end

return M
