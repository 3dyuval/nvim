-- Keymap Utils - Core map processor
-- Minimal implementation of lil.nvim core for keymap-utils

local key = require("keymap-utils.key")
local utils = require("keymap-utils.utils")

local flags = utils.flags
local cascadeSymbols = utils.cascadeSymbols
local logmap = utils.logmap

-- Default keymap function (vim.keymap.set or fallback)
local outside = type(vim) == "table"
    and type(vim.keymap) == "table"
    and type(vim.keymap.set) == "function"
    and vim.keymap.set
  or function()
    print("keymap-utils: no mapper function available")
  end

-- Default config
local config = {
  [flags.func] = outside,
  [flags.opts] = {},
  [flags.off] = false,
  [flags.raw] = false,
  [flags.log] = false,
  "",
  "",
  [flags.mode] = { "n" },
  key = "", -- accumulated key string
}

-- Extract callable from metatable if present
local function extractCaller(t)
  local mt = getmetatable(t)
  if mt and mt.__call then
    return function()
      t()
    end
  end
  return nil
end

-- Main recursive function
local function builtin(prev, left, right)
  local next = cascadeSymbols(prev, right)
  next.expects = false
  next[1], next[2] = "", ""

  if next[flags.off] then
    return nil
  end
  if utils.symbols[left] then
    return nil
  end

  if type(left) == "table" then
    if prev.expects then
      next.key = next.key .. prev[1] .. (prev.expects and left.pure or "") .. prev[2]
    end
    next.expects = left.expects
    next[1], next[2] = left[1] or "", left[2] or ""
    if left.mode then
      next[flags.mode] = left.mode
    end
  elseif type(left) == "string" then
    next.key = next.key .. (prev[1] or "") .. left .. (prev[2] or "")
    next[1], next[2] = "", ""
  elseif type(left) == "number" then
    next.key = next.key
  end

  local callable = extractCaller(right)
  if callable then
    right = callable
  end

  if type(right) ~= "table" or prev[flags.raw] then
    next.key = next.key .. (next[1] or "") .. (next[2] or "")
    for _, mode in pairs(next[flags.mode]) do
      if type(mode) == "table" then
        mode = mode.mode
      end
      if next[flags.log] then
        logmap(mode, next.key, right, next[flags.opts], next)
      end
      next[flags.func](mode, next.key, right, next[flags.opts], next)
    end
    return
  end

  for left2, right2 in pairs(right) do
    builtin(next, left2, right2)
  end
end

-- Public map function
local function map(map_def)
  return builtin(config, "", map_def)
end

return {
  map = map,
  config = config,
  builtin = builtin,
}
