-- [nfnl] fnl/config/keymaps/utils.fnl
local lset = vim.keymap.set
lset("n", "<leader>rk", require("utils.editor").reload_keymaps, {desc = "Reload keymaps"})
lset("n", "<leader>as", "ScratchIssues <CR>", {desc = "Scratch: All Issues"})
local function _1_()
  return require("which-key").show({global = false})
end
lset("n", "<leader>?", _1_, {desc = "Which-key: this buffer's keymaps"})
lset("n", "<leader>gG", ":DiffviewGraph<CR>", {desc = "Diffview graph"})
local function _2_()
  return vim.cmd(("Neogit kind=vsplit cwd=" .. vim.fn.expand("%:p:h")))
end
lset("n", "<leader>gn", _2_, {desc = "Neogit (side)"})
lset("n", "<leader>gc", ":Neogit commit<CR>", {desc = "Neogit commit"})
local function _3_()
  return vim.cmd("Neogit log a")
end
lset("n", "<leader>gl", _3_, {desc = "Neogit log"})
lset("n", "<leader>gs", ":Gitsigns stage_hunk<CR>", {desc = "Stage hunk (Gitsigns)"})
local function _4_()
  return vim.cmd("DiffviewFileHistory .")
end
lset("n", "<leader>gh", _4_, {desc = "Diffview repo log"})
local function _5_()
  return require("hover").open()
end
lset("n", "P", _5_, {desc = "Hover"})
local function _6_()
  return require("conform").format({lsp_format = "fallback"})
end
return lset({"n", "x"}, "<leader>cf", _6_, {desc = "Format"})
