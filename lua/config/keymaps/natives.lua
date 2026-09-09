-- [nfnl] fnl/config/keymaps/natives.fnl
local lset = vim.keymap.set
lset({"n", "x"}, "gX", "X", {desc = "Delete before cursor"})
lset({"n", "x"}, "gU", "U", {desc = "Uppercase"})
lset({"n", "x"}, "gK", "K", {desc = "Lookup keyword"})
return lset({"n", "x"}, "gh", "K", {desc = "Lookup keyword"})
