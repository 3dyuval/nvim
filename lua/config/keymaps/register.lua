-- [nfnl] fnl/config/keymaps/register.fnl
local function register(prefix, node)
  for key, val in pairs(node) do
    local lhs = (prefix .. key)
    if (type(val) == "table") then
      register(lhs, val)
    else
      vim.keymap.set("n", lhs, val, {desc = ""})
    end
  end
  return nil
end
return {register = register}
