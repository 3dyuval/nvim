-- [nfnl] fnl/workspace/kitty-send.fnl
local M = {}
local kitten = (vim.fn.expand("~") .. "/.config/kitty/neighboring_window.py")
local direction = "right"
local function run_kitten(args)
  local socket = (vim.env.KITTY_LISTEN_ON or "unix:@mykitty")
  local cmd = vim.list_extend({"kitty", "@", "--to", socket, "kitten", kitten}, args)
  local function _1_(res)
    if (res.code ~= 0) then
      local function _2_()
        return vim.notify(("kitty send failed: " .. (res.stderr or "")), vim.log.levels.ERROR)
      end
      return vim.schedule(_2_)
    else
      return nil
    end
  end
  return vim.system(cmd, {text = true}, _1_)
end
local function selection_or_line()
  local mode = vim.api.nvim_get_mode().mode
  if mode:match("[vV\22]") then
    vim.cmd("normal! \27")
  else
  end
  if mode:match("[vV\22]") then
    return vim.api.nvim_buf_get_lines(0, (vim.fn.getpos("'<")[2] - 1), vim.fn.getpos("'>")[2], false)
  else
    return {vim.api.nvim_get_current_line()}
  end
end
M.send = function()
  return run_kitten(vim.list_extend({"send", direction, "--"}, selection_or_line()))
end
M.open = function()
  return run_kitten({direction})
end
return M
