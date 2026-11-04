-- [nfnl] fnl/config/keymaps/movement.fnl
local lset = vim.keymap.set
local function treewalk_skip_folded(dir)
  local function _1_()
    local tw = require("treewalker")
    local origin = vim.api.nvim_win_get_cursor(0)
    tw[dir]()
    local guard = 50
    local stuck = false
    while not stuck and (guard > 0) and (vim.fn.foldclosed(vim.fn.line(".")) ~= -1) do
      guard = (guard - 1)
      local fold_start = vim.fn.foldclosed(vim.fn.line("."))
      tw.down()
      if vim.fn.foldclosed(vim.fn.line(".")) == fold_start then
        stuck = true
      else
      end
    end
    if stuck or (guard == 0) then
      return vim.api.nvim_win_set_cursor(0, origin)
    else
      return nil
    end
  end
  return _1_
end
lset("n", "H", treewalk_skip_folded("left"), { desc = "Treewalk out (skip folded)", silent = true })
lset("n", "I", treewalk_skip_folded("right"), { desc = "Treewalk in (skip folded)", silent = true })
local function goto_enclosing_node_start()
  if not pcall(vim.treesitter.get_parser, 0) then
    return false
  else
    local node = vim.treesitter.get_node()
    if not node then
      return false
    else
      local block = nil
      local iter = node
      while iter and not block do
        local sr, _, er, _0 = iter:range()
        if er > sr then
          block = iter
        else
          iter = iter:parent()
        end
      end
      if block then
        local sr, sc = block:range()
        vim.api.nvim_win_set_cursor(0, { (sr + 1), sc })
      else
      end
      return (block ~= nil)
    end
  end
end
local function _8_()
  if goto_enclosing_node_start() then
    pcall(vim.cmd, "normal! zc")
  else
  end
  return require("treewalker").left()
end
lset("n", "<M-h>", _8_, { desc = "Close enclosing fold + treewalk out", silent = true })
local function _10_()
  if goto_enclosing_node_start() then
    pcall(vim.cmd, "normal! zo")
  else
  end
  return require("treewalker").right()
end
lset("n", "<M-i>", _10_, { desc = "Open enclosing fold + treewalk in", silent = true })
local function _12_()
  if pcall(vim.treesitter.get_parser, 0) then
    local tw = require("treewalker")
    local row = vim.fn.line(".")
    tw.move_up()
    if row == vim.fn.line(".") then
      return tw.move_out()
    else
      return nil
    end
  else
    return nil
  end
end
lset("n", "E", _12_, { desc = "Treewalk prev sibling (else out)", silent = true })
lset("n", "A", "<cmd>Treewalker Down<cr>", { desc = "Treewalk next sibling", silent = true })
lset("n", "zh", "zc", { desc = "Close fold (one)", noremap = true })
lset("n", "zi", "zo", { desc = "Open fold (one)", noremap = true })
lset("n", "zH", "zM", { desc = "Close all folds", noremap = true })
lset("n", "zI", "zR", { desc = "Open all folds", noremap = true })
lset({ "n", "o", "x" }, "k", "t", { desc = "Till before" })
lset({ "n", "o", "x" }, "K", "T", { desc = "Till before backward" })
local gs = require("gitsigns")
local function _15_()
  if vim.wo.diff then
    return vim.cmd.normal({ "]c", bang = true })
  else
    return gs.nav_hunk("next", { target = "all" })
  end
end
lset("n", "<C-Down>", _15_, { desc = "Next git hunk" })
local function _17_()
  if vim.wo.diff then
    return vim.cmd.normal({ "[c", bang = true })
  else
    return gs.nav_hunk("prev", { target = "all" })
  end
end
lset("n", "<C-Up>", _17_, { desc = "Prev git hunk" })
local function _19_()
  return require("workspace.mcp-virtual-text").next()
end
lset("n", "]i", _19_, { desc = "Next MCP virtual text" })
local function _20_()
  return require("workspace.mcp-virtual-text").prev()
end
lset("n", "[i", _20_, { desc = "Prev MCP virtual text" })
lset("n", "<C-S-A>", "<C-e>", { desc = "Scroll line down" })
return lset("n", "<C-S-E>", "<C-y>", { desc = "Scroll line up" })
