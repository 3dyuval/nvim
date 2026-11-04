-- [nfnl] fnl/config/keymaps/movement.fnl
local lset = vim.keymap.set
local ufo = require("ufo")
lset("n", "H", "<cmd>Treewalker Left<cr>", {desc = "Treewalk out (parent)", silent = true})
lset("n", "I", "<cmd>Treewalker Right<cr>", {desc = "Treewalk in (child)", silent = true})
local function _1_()
  pcall(vim.cmd, "normal! zc")
  return require("treewalker").left()
end
lset("n", "<M-h>", _1_, {desc = "Close fold + treewalk out", silent = true})
local function _2_()
  require("treewalker").right()
  return pcall(vim.cmd, "normal! zo")
end
lset("n", "<M-i>", _2_, {desc = "Treewalk in + open fold", silent = true})
local function _3_()
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
lset("n", "E", _3_, {desc = "Treewalk prev sibling (else out)", silent = true})
lset("n", "A", "<cmd>Treewalker Down<cr>", {desc = "Treewalk next sibling", silent = true})
lset("n", "zh", "zc", {desc = "Close fold (one)", noremap = true})
lset("n", "zi", "zo", {desc = "Open fold (one)", noremap = true})
lset("n", "zH", ufo.closeAllFolds, {desc = "Close all folds"})
lset("n", "zI", ufo.openAllFolds, {desc = "Open all folds"})
lset({"n", "o", "x"}, "k", "t", {desc = "Till before"})
lset({"n", "o", "x"}, "K", "T", {desc = "Till before backward"})
local gs = require("gitsigns")
local function _6_()
  if vim.wo.diff then
    return vim.cmd.normal({"]c", bang = true})
  else
    return gs.nav_hunk("next", {target = "all"})
  end
end
lset("n", "<C-Down>", _6_, {desc = "Next git hunk"})
local function _8_()
  if vim.wo.diff then
    return vim.cmd.normal({"[c", bang = true})
  else
    return gs.nav_hunk("prev", {target = "all"})
  end
end
lset("n", "<C-Up>", _8_, {desc = "Prev git hunk"})
local function _10_()
  return require("workspace.mcp-virtual-text").next()
end
lset("n", "]i", _10_, {desc = "Next MCP virtual text"})
local function _11_()
  return require("workspace.mcp-virtual-text").prev()
end
lset("n", "[i", _11_, {desc = "Prev MCP virtual text"})
lset("n", "<C-S-A>", "<C-e>", {desc = "Scroll line down"})
return lset("n", "<C-S-E>", "<C-y>", {desc = "Scroll line up"})
