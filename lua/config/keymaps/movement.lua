-- [nfnl] fnl/config/keymaps/movement.fnl
local lset = vim.keymap.set
local ufo = require("ufo")
lset("n", "of", "<cmd>Treewalker Left<cr>", {desc = "Treewalk out (up a level)", silent = true})
lset("n", "ou", "<cmd>Treewalker Right<cr>", {desc = "Treewalk in (into level)", silent = true})
lset("n", "H", "<cmd>Treewalker Up<cr>", {desc = "Treewalk prev (same level)", silent = true})
lset("n", "I", "<cmd>Treewalker Down<cr>", {desc = "Treewalk next (same level)", silent = true})
lset("n", "OF", "zc", {desc = "Close fold (one)", noremap = true})
lset("n", "OU", "zo", {desc = "Open fold (one)", noremap = true})
lset("n", "FF", ufo.closeAllFolds, {desc = "Close all folds"})
lset("n", "UU", ufo.openAllFolds, {desc = "Open all folds"})
lset({"n", "o", "x"}, "k", "t", {desc = "Till before"})
lset({"n", "o", "x"}, "K", "T", {desc = "Till before backward"})
local gs = require("gitsigns")
local function _1_()
  if vim.wo.diff then
    return vim.cmd.normal({"]c", bang = true})
  else
    return gs.next_hunk()
  end
end
lset("n", "<C-PageDown>", _1_, {desc = "Next git hunk"})
local function _3_()
  if vim.wo.diff then
    return vim.cmd.normal({"[c", bang = true})
  else
    return gs.prev_hunk()
  end
end
return lset("n", "<C-PageUp>", _3_, {desc = "Prev git hunk"})
