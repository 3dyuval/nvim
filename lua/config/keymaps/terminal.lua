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
local function _5_()
  return require("summon").open("terminal")
end
lset("n", "<leader>tr", _5_, {desc = "Terminal (summon)"})
local function _6_()
  return require("summon").pick()
end
lset("n", "<leader>tt", _6_, {desc = "Pick (summon)"})
local function _7_()
  return require("summon").open("claude")
end
return lset("n", "\27[44;6u", _7_, {desc = "Claude-Code (bound to kitty-{PID})"})
