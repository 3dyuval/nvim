-- [nfnl] fnl/config/keymaps/utils.fnl
local lset = vim.keymap.set
lset("n", "<leader>gG", ":DiffviewGraph<CR>", {desc = "Diffview graph"})
local function _1_()
  return vim.cmd(("Neogit kind=vsplit cwd=" .. vim.fn.expand("%:p:h")))
end
lset("n", "<leader>gn", _1_, {desc = "Neogit (side)"})
lset("n", "<leader>gc", ":Neogit commit<CR>", {desc = "Neogit commit"})
local function _2_()
  return vim.cmd("Neogit log a")
end
lset("n", "<leader>gl", _2_, {desc = "Neogit log"})
lset("n", "<leader>gs", ":Gitsigns stage_hunk<CR>", {desc = "Stage hunk (Gitsigns)"})
local function _3_()
  return vim.cmd("DiffviewFileHistory .")
end
lset("n", "<leader>gh", _3_, {desc = "Diffview repo log"})
local function _4_()
  return require("hover").open()
end
lset("n", "P", _4_, {desc = "Hover"})
local function _5_()
  return require("conform").format({lsp_format = "fallback"})
end
lset({"n", "x"}, "<leader>cf", _5_, {desc = "Format"})
local function _6_()
  return require("workspace.session").open()
end
lset("n", "<leader>qs", _6_, {desc = "Session picker"})
local function _7_()
  return vim.api.nvim_feedkeys(":terminal ", "t", false)
end
lset("n", "<leader>tt", _7_, {desc = "Terminal prefill"})
local function _8_()
  return require("workspace.kitty-send").send()
end
lset({"n", "x"}, "<leader>rs", _8_, {desc = "Kitty: send line/selection"})
local function _9_()
  return require("workspace.kitty-send").open("hsplit")
end
lset("n", "<leader>rr", _9_, {desc = "Kitty: open runner (bottom)"})
local function _10_()
  return require("workspace.kitty-send").open("vsplit")
end
lset("n", "<leader>rR", _10_, {desc = "Kitty: open runner (right)"})
local function _11_()
  local grug_far = require("grug-far")
  local entry = grug_far.get_last_history_entry()
  return grug_far.open({prefills = entry})
end
lset("n", "<leader>rg", _11_, {desc = "Find and replace - last search (GrugFar)"})
local function _12_()
  return require("grug-far").open({prefills = {paths = vim.fn.expand("%")}})
end
lset("n", "<leader>rG", _12_, {desc = "Find and replace - current file (GrugFar)"})
local function _13_()
  return require("workspace.grug-history").pick()
end
lset("n", "<leader>rt", _13_, {desc = "Find and replace - history picker (GrugFar)"})
local function _14_()
  return require("grug-far").with_visual_selection({visualSelectionUsage = "prefill-search"})
end
lset("v", "<leader>rg", _14_, {desc = "Find and replace - selection as search (GrugFar)"})
local function _15_()
  return require("grug-far").with_visual_selection({visualSelectionUsage = "operate-within-range"})
end
return lset("v", "<leader>rG", _15_, {desc = "Find and replace - within selection (GrugFar)"})
