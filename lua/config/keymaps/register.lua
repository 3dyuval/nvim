-- [nfnl] fnl/config/keymaps/register.fnl
local function register(prefix, node)
  for key, val in pairs(node) do
    if key ~= "group" then
      local lhs = (prefix .. key)
      if (type(val) == "table") and val.cmd then
        vim.keymap.set("n", lhs, val.cmd, { desc = (val.desc or "") })
      elseif type(val) == "table" then
        register(lhs, val)
      else
        vim.keymap.set("n", lhs, val, { desc = "" })
      end
    else
    end
  end
  return nil
end
local function very_lazy(f)
  local ok, lv = pcall(require, "lazyvim.util")
  if ok and lv and lv.on_very_lazy then
    return lv.on_very_lazy(f)
  else
    local function _3_()
      f()
      return nil
    end
    return vim.api.nvim_create_autocmd("User", { pattern = "VeryLazy", callback = _3_ })
  end
end
local function register_very_lazy(prefix, node)
  local function _5_()
    return register(prefix, node)
  end
  return very_lazy(_5_)
end
local function del_very_lazy(mode, keys)
  local function _6_()
    for _, lhs in ipairs(keys) do
      pcall(vim.keymap.del, mode, lhs)
    end
    return nil
  end
  return very_lazy(_6_)
end
return {
  register = register,
  ["very-lazy"] = very_lazy,
  ["register-very-lazy"] = register_very_lazy,
  ["del-very-lazy"] = del_very_lazy,
}
