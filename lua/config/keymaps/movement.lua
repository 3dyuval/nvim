-- [nfnl] fnl/config/keymaps/movement.fnl
local lset = vim.keymap.set
local ufo = require("ufo")
lset("n", "H", "<cmd>Treewalker Left<cr>", {desc = "Treewalk out (parent)", silent = true})
lset("n", "I", "<cmd>Treewalker Right<cr>", {desc = "Treewalk in (child)", silent = true})
local function _1_()
  if pcall(vim.treesitter.get_parser, 0) then
    local tw = require("treewalker")
    local row = vim.fn.line(".")
    tw.move_up()
    if (row == vim.fn.line(".")) then
      return tw.move_out()
    else
      return nil
    end
  else
    return nil
  end
end
lset("n", "E", _1_, {desc = "Treewalk prev sibling (else out)", silent = true})
lset("n", "A", "<cmd>Treewalker Down<cr>", {desc = "Treewalk next sibling", silent = true})
lset("n", "zh", "zc", {desc = "Close fold (one)", noremap = true})
lset("n", "zi", "zo", {desc = "Open fold (one)", noremap = true})
lset("n", "zH", ufo.closeAllFolds, {desc = "Close all folds"})
lset("n", "zI", ufo.openAllFolds, {desc = "Open all folds"})
lset({"n", "o", "x"}, "k", "t", {desc = "Till before"})
lset({"n", "o", "x"}, "K", "T", {desc = "Till before backward"})
local gs = require("gitsigns")
local function _4_()
  if vim.wo.diff then
    return vim.cmd.normal({"]c", bang = true})
  else
    return gs.nav_hunk("next", {target = "all"})
  end
end
lset("n", "<C-S-A>", _4_, {desc = "Next git hunk"})
local function _6_()
  if vim.wo.diff then
    return vim.cmd.normal({"[c", bang = true})
  else
    return gs.nav_hunk("prev", {target = "all"})
  end
end
return lset("n", "<C-S-E>", _6_, {desc = "Prev git hunk"})
