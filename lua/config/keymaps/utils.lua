-- [nfnl] fnl/config/keymaps/utils.fnl
local lset = vim.keymap.set
lset("n", "<leader>gG", ":Gitsigns", {desc = "Gitsigns prefill"})
lset("n", "<leader>gg", ":DiffviewGraphCDiffView<CR>", {desc = "Open gitgraph as diff view"})
local function _1_()
  return vim.cmd(("Neogit kind=vsplit cwd=" .. vim.fn.expand("%:p:h")))
end
lset("n", "<leader>gn", _1_, {desc = "Neogit (side)"})
lset("n", "<leader>gc", ":Neogit commit<CR>", {desc = "Neogit commit"})
lset("n", "<leader>gs", ":DiffviewOpen %", {desc = "File DiffviewOpen history"})
local function _2_()
  return vim.cmd("DiffviewFileHistory .")
end
lset("n", "<leader>gh", _2_, {desc = "Diffview repo log"})
local function _3_()
  return require("hover").open()
end
return lset("n", "P", _3_, {desc = "Hover"})
