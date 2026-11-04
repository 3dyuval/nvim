-- [nfnl] fnl/config/keymaps/movement.fnl
local lset = vim.keymap.set
lset("n", "H", "<cmd>Treewalker Left<cr>", { desc = "Treewalk out (parent)", silent = true })
lset("n", "I", "<cmd>Treewalker Right<cr>", { desc = "Treewalk in (child)", silent = true })
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
local function _5_()
  if goto_enclosing_node_start() then
    pcall(vim.cmd, "normal! zc")
  else
  end
  return require("treewalker").left()
end
lset("n", "<M-h>", _5_, { desc = "Close enclosing fold + treewalk out", silent = true })
local function _7_()
  if goto_enclosing_node_start() then
    pcall(vim.cmd, "normal! zo")
  else
  end
  return require("treewalker").right()
end
lset("n", "<M-i>", _7_, { desc = "Open enclosing fold + treewalk in", silent = true })
local function _9_()
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
lset("n", "E", _9_, { desc = "Treewalk prev sibling (else out)", silent = true })
lset("n", "A", "<cmd>Treewalker Down<cr>", { desc = "Treewalk next sibling", silent = true })
lset("n", "zh", "zc", { desc = "Close fold (one)", noremap = true })
lset("n", "zi", "zo", { desc = "Open fold (one)", noremap = true })
lset("n", "zH", "zM", { desc = "Close all folds", noremap = true })
lset("n", "zI", "zR", { desc = "Open all folds", noremap = true })
lset({ "n", "o", "x" }, "k", "t", { desc = "Till before" })
lset({ "n", "o", "x" }, "K", "T", { desc = "Till before backward" })
local gs = require("gitsigns")
local function _12_()
  if vim.wo.diff then
    return vim.cmd.normal({ "]c", bang = true })
  else
    return gs.nav_hunk("next", { target = "all" })
  end
end
lset("n", "<C-Down>", _12_, { desc = "Next git hunk" })
local function _14_()
  if vim.wo.diff then
    return vim.cmd.normal({ "[c", bang = true })
  else
    return gs.nav_hunk("prev", { target = "all" })
  end
end
lset("n", "<C-Up>", _14_, { desc = "Prev git hunk" })
local function _16_()
  return require("workspace.mcp-virtual-text").next()
end
lset("n", "]i", _16_, { desc = "Next MCP virtual text" })
local function _17_()
  return require("workspace.mcp-virtual-text").prev()
end
lset("n", "[i", _17_, { desc = "Prev MCP virtual text" })
lset("n", "<C-S-A>", "<C-e>", { desc = "Scroll line down" })
return lset("n", "<C-S-E>", "<C-y>", { desc = "Scroll line up" })
