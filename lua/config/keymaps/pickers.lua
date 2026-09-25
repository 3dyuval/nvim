-- [nfnl] fnl/config/keymaps/pickers.fnl
local lset = vim.keymap.set
local function _1_()
  return require("workspace.session").open()
end
lset("n", "<leader>qs", _1_, {desc = "Session picker"})
local function _2_()
  return vim.api.nvim_feedkeys(":terminal ", "t", false)
end
lset("n", "<leader>tt", _2_, {desc = "Terminal prefill"})
local function _3_()
  return require("workspace.kitty-send").send()
end
lset({"n", "x"}, "<leader>rs", _3_, {desc = "Kitty: send line/selection"})
local function _4_()
  return require("workspace.kitty-send").open("hsplit")
end
lset("n", "<leader>rr", _4_, {desc = "Kitty: open runner (bottom)"})
local function _5_()
  return require("workspace.kitty-send").open("vsplit")
end
lset("n", "<leader>rR", _5_, {desc = "Kitty: open runner (right)"})
local function _6_()
  return vim.cmd("Yazi")
end
return lset("n", "<leader>ff", _6_, {desc = "Yazi at current file"})
