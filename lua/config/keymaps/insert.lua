-- [nfnl] fnl/config/keymaps/insert.fnl
local lset = vim.keymap.set
lset("n", "s", "i", {desc = "Insert after cursor"})
lset("n", "L", "I", {desc = "Insert at the start of line"})
lset("n", "W", "A", {desc = "Insert at end of line"})
lset("n", "S", "A", {desc = "Insert at end of line"})
lset("n", "t", "<Del>", {desc = "Delete char under cursor"})
return lset("n", "X", "<Del>", {desc = "Delete char under cursor"})
