-- [nfnl] fnl/config/keymaps/register.fnl
local function register(prefix, node)
  for key, val in pairs(node) do
    if (key ~= "group") then
      local lhs = (prefix .. key)
      if ((type(val) == "table") and val.cmd) then
        vim.keymap.set("n", lhs, val.cmd, {desc = (val.desc or "")})
      elseif (type(val) == "table") then
        register(lhs, val)
      else
        vim.keymap.set("n", lhs, val, {desc = ""})
      end
    else
    end
  end
  return nil
end
return {register = register}
