-- [nfnl] fnl/blink/sources/commitlint.fnl
local function make_item(v, spec)
  return {label = v, detail = spec.detail, kind_name = spec.kind_name, kind_icon = spec.icon, kind_hl = spec.hl}
end
local function build_items(labels, spec)
  local out = {}
  for _, v in ipairs((labels or {})) do
    table.insert(out, make_item(v, spec))
  end
  return out
end
local builtin_type_spec = {kind_name = "BuiltinType", icon = vim.fn.nr2char(61483), hl = "Function", detail = "commit type (builtin)"}
local custom_type_spec = {kind_name = "CustomType", icon = vim.fn.nr2char(61484), hl = "Constant", detail = "commit type (custom)"}
local scope_spec = {kind_name = "Scope", icon = vim.fn.nr2char(62599), hl = "String", detail = "commit scope"}
local builtin_types = {feat = true, fix = true, docs = true, style = true, refactor = true, perf = true, test = true, build = true, ci = true, chore = true, revert = true}
local function build_type_items(labels)
  local out = {}
  for _, v in ipairs((labels or {})) do
    local function _1_()
      if builtin_types[v] then
        return builtin_type_spec
      else
        return custom_type_spec
      end
    end
    table.insert(out, make_item(v, _1_()))
  end
  return out
end
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
  local _3_
  do
    local t_2_ = ctx.cursor
    if (nil ~= t_2_) then
      t_2_ = t_2_[2]
    else
    end
    _3_ = t_2_
  end
  col = (_3_ or #line)
  local before = line:sub(1, col)
  local bufnr = vim.api.nvim_get_current_buf()
  local finish
  local function _5_(items)
    return callback({items = items, is_incomplete_backward = false, is_incomplete_forward = false})
  end
  finish = _5_
  if before:match("^%s*[%w_/-]*%([^)]*$") then
    return finish(build_items(vim.b[bufnr].commitlint_scopes, scope_spec))
  elseif before:match("^%s*[%w_/-]*$") then
    return finish(build_type_items(vim.b[bufnr].commitlint_types))
  else
    return finish({})
  end
end
return M
