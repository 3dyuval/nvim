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
lset("n", "<leader>gs", ":DiffviewOpen %", {desc = "File DiffviewOpen history"})
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
lset("n", "<leader>rs", _6_, {desc = "Session picker"})
local function _7_()
  return vim.api.nvim_feedkeys(":terminal ", "t", false)
end
return lset("n", "<leader>tt", _7_, {desc = "Terminal prefill"})
