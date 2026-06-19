-- [nfnl] fnl/blink/sources/commitlint.fnl
local function build_items(labels, spec)
  local out = {}
  for _, v in ipairs((labels or {})) do
    table.insert(out, {label = v, detail = spec.detail, kind_name = spec.kind_name, kind_icon = spec.icon, kind_hl = spec.hl})
  end
  return out
end
local type_spec = {kind_name = "Type", icon = vim.fn.nr2char(61483), hl = "Function", detail = "commit type"}
local scope_spec = {kind_name = "Scope", icon = vim.fn.nr2char(62599), hl = "String", detail = "commit scope"}
local M = {}
M.new = function()
  return setmetatable({}, {__index = M})
end
M.get_trigger_characters = function(self)
  return {"(", ","}
end
M.get_completions = function(self, ctx, callback)
  local line = (ctx.line or "")
  local col
  local _2_
  do
    local t_1_ = ctx.cursor
    if (nil ~= t_1_) then
      t_1_ = t_1_[2]
    else
    end
    _2_ = t_1_
  end
  col = (_2_ or #line)
  local before = line:sub(1, col)
  local bufnr = vim.api.nvim_get_current_buf()
  local finish
  local function _4_(items)
    return callback({items = items, is_incomplete_backward = false, is_incomplete_forward = false})
  end
  finish = _4_
  if before:match("^%s*[%w_/-]*%([^)]*$") then
    return finish(build_items(vim.b[bufnr].commitlint_scopes, scope_spec))
  elseif before:match("^%s*[%w_/-]*$") then
    return finish(build_items(vim.b[bufnr].commitlint_types, type_spec))
  else
    return finish({})
  end
end
return M
