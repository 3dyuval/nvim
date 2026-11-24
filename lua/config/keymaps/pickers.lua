-- [nfnl] fnl/config/keymaps/pickers.fnl
local lset = vim.keymap.set
local function _1_()
  return require("workspace.kitty-send").send()
end
lset({ "n", "x" }, "<leader>rs", _1_, { desc = "Kitty: send line/selection" })
local function _2_()
  return require("workspace.kitty-send").open("hsplit")
end
lset("n", "<leader>rr", _2_, { desc = "Kitty: open runner (bottom)" })
local function _3_()
  return require("workspace.kitty-send").open("vsplit")
end
lset("n", "<leader>rR", _3_, { desc = "Kitty: open runner (right)" })
local function _4_()
  return require("workspace.pkg-scripts").pick()
end
lset("n", "<leader>rp", _4_, { desc = "Run package.json script -> quickfix" })
local function _5_()
  return Snacks.picker.resume()
end
lset("n", "<leader><leader>", _5_, { desc = "Resume last picker" })
local function _6_()
  return Snacks.picker.git_files()
end
return lset("n", "<leader>fg", _6_, { desc = "Find git files" })
