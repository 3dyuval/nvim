-- [nfnl] fnl/config/keymaps/delete.fnl
local lset = vim.keymap.set
return lset(("n")("xX", "V%x", {desc = "Delete object macro"}))
