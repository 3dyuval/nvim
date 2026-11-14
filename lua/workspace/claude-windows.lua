-- [nfnl] fnl/workspace/claude-windows.fnl
local function _1_()
  local buf = vim.api.nvim_get_current_buf()
  if vim.b[buf].claudecode_diff_tab_name then
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local wbuf = vim.api.nvim_win_get_buf(win)
      if (vim.bo[wbuf].buftype == "terminal") and string.match(vim.api.nvim_buf_get_name(wbuf), "claude") then
        pcall(vim.api.nvim_win_close, win, false)
        return
      else
      end
    end
    return nil
  else
    return nil
  end
end
vim.api.nvim_create_autocmd("BufWinEnter", { callback = _1_ })
local function _4_()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local name = vim.api.nvim_buf_get_name(buf)
    if name:match("claude") and (vim.bo[buf].buftype == "terminal") then
      vim.api.nvim_set_current_win(win)
      vim.cmd("startinsert")
      return
    else
    end
  end
  return nil
end
vim.api.nvim_create_autocmd("FocusGained", { callback = _4_ })
return {}
