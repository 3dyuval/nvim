-- [nfnl] fnl/workspace/buffer-nav.fnl
local M = {}
local function listed()
  local tbl_26_ = {}
  local i_27_ = 0
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    local val_28_
    if (vim.bo[b].buflisted and vim.api.nvim_buf_is_loaded(b)) then
      val_28_ = b
    else
      val_28_ = nil
    end
    if (nil ~= val_28_) then
      i_27_ = (i_27_ + 1)
      tbl_26_[i_27_] = val_28_
    else
    end
  end
  return tbl_26_
end
local function bento_visible_3f()
  return (vim.o.showtabline ~= 0)
end
local function kitty_tab(action)
  local socket = (vim.env.KITTY_LISTEN_ON or "unix:@mykitty")
  return vim.system({"kitty", "@", "--to", socket, "action", action}, {text = true})
end
M.next = function()
  local bufs = listed()
  local cur = vim.api.nvim_get_current_buf()
  if (not bento_visible_3f() or (cur == bufs[#bufs])) then
    return kitty_tab("next_tab")
  else
    return vim.cmd("bnext")
  end
end
M.prev = function()
  local bufs = listed()
  local cur = vim.api.nvim_get_current_buf()
  if (not bento_visible_3f() or (cur == bufs[1])) then
    return kitty_tab("previous_tab")
  else
    return vim.cmd("bprev")
  end
end
return M
