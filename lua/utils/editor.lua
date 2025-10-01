-- Editor operations utilities
local M = {}

M.reload_config = function()
  vim.cmd(":source $MYVIMRC")
  vim.notify("Config reloaded")
end

M.reload_keymaps = function()
  -- Clear module cache for keymaps and all utils modules
  for module_name, _ in pairs(package.loaded) do
    if
      module_name:match("^config%.keymaps")
      or module_name:match("^utils%.")
      or module_name:match("^keymap%-utils")
    then
      package.loaded[module_name] = nil
    end
  end

  -- Re-require keymaps (will also re-require all utils)
  local success, err = pcall(function()
    require("config.keymaps")
  end)

  if success then
    vim.notify("Keymaps reloaded", vim.log.levels.INFO)
  else
    vim.notify("Keymap reload failed: " .. tostring(err), vim.log.levels.ERROR)
  end
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
