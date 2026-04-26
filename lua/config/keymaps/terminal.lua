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
local function _3_()
  return require("summon").open("terminal")
end
lset("n", "<leader>tr", _3_, {desc = "Terminal (summon)"})
local function _4_()
  return require("summon").pick()
end
lset("n", "<leader>tt", _4_, {desc = "Pick (summon)"})
local function _5_()
  return require("summon").open("claude")
end
return lset("n", "\27[44;6u", _5_, {desc = "Claude-Code (bound to kitty-{PID})"})
