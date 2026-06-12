-- [nfnl] fnl/config/keymaps/utils.fnl
local lset = vim.keymap.set
local function _1_()
  return vim.cmd(("Neogit kind=vsplit cwd=" .. vim.fn.expand("%:p:h")))
end
lset("n", "<leader>gg", _1_, {desc = "Neogit (side)", noremap = true})
lset("n", "<leader>gs", ":DiffviewOpen %", {desc = "File DiffviewOpen history", noremap = true})
local function _2_()
  return require("hover").open()
end
return lset("n", "P", _2_, {desc = "Hover"})
