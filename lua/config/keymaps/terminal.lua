-- [nfnl] fnl/config/keymaps/terminal.fnl
local lset = vim.keymap.set
local function _1_()
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", false)
  local function _2_()
    return pcall(vim.api.nvim_win_close, win, false)
  end
  return vim.schedule(_2_)
end
lset("t", "<C-w>", _1_, {desc = "Close terminal window"})
lset("t", "\27[101;6u", "<C-\\><C-n><C-u>", {desc = "Scroll up in terminal"})
lset("t", "\27[97;6u", "<C-\\><C-n><C-d>", {desc = "Scroll down in terminal"})
for key, dir in pairs({["<C-h>"] = "move_cursor_left", ["<C-a>"] = "move_cursor_down", ["<C-e>"] = "move_cursor_up", ["<C-i>"] = "move_cursor_right"}) do
  local function _3_()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", false)
    local function _4_()
      return require("smart-splits")[dir]()
    end
    return vim.schedule(_4_)
  end
  lset("t", key, _3_, {desc = ("Window " .. string.gsub(dir, "move_cursor_", ""))})
end
local function goto_nearest_terminal(insert_3f)
  local focused = false
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if focused then break end
    local buf = vim.api.nvim_win_get_buf(win)
    local name = vim.api.nvim_buf_get_name(buf)
    if name:match("^term://") then
      vim.api.nvim_set_current_win(win)
      focused = true
    else
    end
  end
  if not focused then
    local best = nil
    local best_used = -1
    for _, b in ipairs(vim.fn.getbufinfo()) do
      if ((b.loaded == 1) and b.name:match("^term://") and (b.lastused > best_used)) then
        best = b.bufnr
        best_used = b.lastused
      else
      end
    end
    if best then
      vim.api.nvim_set_current_buf(best)
    else
      vim.cmd("belowright split")
      vim.cmd("terminal")
    end
  else
  end
  if insert_3f then
    return vim.cmd("startinsert")
  else
    return nil
  end
end
local function _10_()
  return goto_nearest_terminal(false)
end
lset("n", "<leader>tt", _10_, {desc = "Go to nearest terminal"})
local function _11_()
  return goto_nearest_terminal(true)
end
return lset("n", "<leader>tr", _11_, {desc = "Go to nearest terminal (insert)"})
