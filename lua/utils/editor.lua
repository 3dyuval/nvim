-- Editor operations utilities
local M = {}

M.reload_config = function()
  vim.cmd(":source $MYVIMRC")
  vim.notify("Config reloaded")
end

M.reload_keymaps = function()
  vim.cmd("source " .. vim.fn.stdpath("config") .. "/lua/config/keymaps.lua")
  vim.notify("keymaps reloaded")
end

M.typescript_check = function()
  vim.cmd("split | terminal tsc --noEmit")
end

M.paste_inline = function()
  local reg_type = vim.fn.getregtype('"')
  if reg_type == "V" then -- line-wise register
    vim.cmd("normal! gp")
  else
    vim.cmd("normal! p")
  end
end

return M
