-- [nfnl] fnl/config/keymaps/config.fnl
local lset = vim.keymap.set
local editor = require("utils.editor")
return lset("n", "<leader>rk", editor.reload_keymaps, {desc = "Reload keymaps"})
