-- [nfnl] fnl/config/keymaps/utils.fnl
local lset = vim.keymap.set
local ufo = require("ufo")
lset("n", "<leader>gs", ":DiffviewOpen %", {desc = "File DiffviewOpen history", noremap = true})
local function _1_()
  return ufo.action.openFoldsWith(0)
end
lset("n", "ff", _1_, {desc = "Close all folds (fold all)"})
lset("n", "fM", "zr", {desc = "Fold all", noremap = true})
lset("n", "fF", "zr", {desc = "Unfold all", noremap = true})
lset("n", "fo", "zo", {desc = "Unfold", noremap = true})
return lset("n", "fu", "zc", {desc = "Fold one", noremap = true})
