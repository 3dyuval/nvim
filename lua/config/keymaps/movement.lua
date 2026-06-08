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
return lset("n", "UU", ufo.openAllFolds, {desc = "Open all folds"})
