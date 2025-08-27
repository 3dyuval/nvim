local lil = require("lil")
local func = lil.flags.func
local opts = lil.flags.opts

local M = {}

local function which(m, l, r, o, _next)
  vim.keymap.set(m, l, r, { desc = o and o.desc or nil })
end

local function desc(d, value)
  return {
    value,
    [func] = which,
    [opts] = { desc = d },
  }
end

local map = vim.keymap.set

local function remap(mode, lhs, rhs, opts)
  pcall(vim.keymap.del, mode, lhs)
  map(mode, lhs, rhs, opts)
end

M.remap = remap
M.which = which
M.desc = desc
M.func = func
M.opts = opts
M.map = lil.map

return M
