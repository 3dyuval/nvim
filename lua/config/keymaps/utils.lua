-- [nfnl] fnl/config/keymaps/utils.fnl
local lset = vim.keymap.set
lset("n", "<leader>gg", ":Git", {desc = "Git prefill"})
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
  return require("utils.session-picker").open()
end
lset("n", "<leader>qs", _6_, {desc = "Session picker"})
local function _7_()
  return vim.api.nvim_feedkeys(":terminal ", "t", false)
end
lset("n", "<leader>tt", _7_, {desc = "Terminal prefill"})
local function _8_()
  return require("utils.picker-extensions").open_explorer({layout = {preset = "default"}, focus = "list"})
end
lset("n", "<leader>fo", _8_, {desc = "Explorer (float)"})
local function _9_()
  return require("utils.picker-extensions").open_explorer({layout = {preset = "default"}, focus = "input"})
end
lset("n", "<leader>fO", _9_, {desc = "Explorer (float, focus input)"})
local function _10_()
  return require("utils.picker-extensions").open_explorer({layout = {preset = "sidebar"}, focus = "list"})
end
lset("n", "<leader>of", _10_, {desc = "Explorer (sidebar)"})
local function _11_()
  return require("utils.picker-extensions").open_explorer({layout = {preset = "sidebar"}, focus = "input"})
end
lset("n", "<leader>oF", _11_, {desc = "Explorer (sidebar, focus input)"})
local function _12_()
  return require("picker.grep")["grep-current-buffer-dir"]()
end
lset("n", "<C-/>", _12_, {desc = "Grep in current file's directory"})
lset("n", "<leader>rg", ":GrugFar<CR>", {desc = "Find and replace (GrugFar)"})
local function _13_()
  return require("grug-far").open({pollyfills = {paths = vim.fn.expand("%")}})
end
lset("n", "<leader>rG", _13_)
local function _14_()
  return require("grug-far").with_visual_selection({pollyfills = {paths = vim.fn.expand("%")}})
end
return lset("v", "<leader>rG", _14_)
