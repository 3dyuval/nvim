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

-- Run visual selection with interpreter
-- Usage: editor.run_selection("node -e")
-- For stdin-based: editor.run_selection("lua -", true)
M.run_selection = function(command, stdin)
  return function()
    local _, ls, cs = unpack(vim.fn.getpos("v"))
    local _, le, ce = unpack(vim.fn.getpos("."))
    if ls > le or (ls == le and cs > ce) then
      ls, le = le, ls
      cs, ce = ce, cs
    end
    local lines = vim.api.nvim_buf_get_lines(0, ls - 1, le, false)
    if #lines == 0 then
      return
    end
    lines[#lines] = lines[#lines]:sub(1, ce)
    lines[1] = lines[1]:sub(cs)
    local text = table.concat(lines, "\n")

    local result
    if stdin then
      result = vim.fn.system(command, text)
    else
      result = vim.fn.system(command .. ' "' .. text:gsub('"', '\\"') .. '"')
    end
    print(result)
    if vim.v.shell_error ~= 0 then
      print("exit: " .. vim.v.shell_error)
    end
  end
end

return M
