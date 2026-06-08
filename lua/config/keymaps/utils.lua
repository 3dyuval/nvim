-- [nfnl] fnl/config/keymaps/utils.fnl
local lset = vim.keymap.set
return lset("n", "<leader>gs", ":DiffviewOpen %", {desc = "File DiffviewOpen history", noremap = true})
