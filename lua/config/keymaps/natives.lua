-- [nfnl] fnl/config/keymaps/natives.fnl
local lset = vim.keymap.set
lset({ "n", "x" }, "gX", "X", { desc = "Delete before cursor" })
lset({ "n", "x" }, "gK", "K", { desc = "Lookup keyword" })
lset({ "n", "x" }, "gh", "K", { desc = "Lookup keyword" })
lset({ "n", "x" }, "d", '"_d', { desc = "Delete (black hole)" })
lset("n", "dd", '"_dd', { desc = "Delete line (black hole)" })
lset({ "n", "x" }, "D", '"_D', { desc = "Delete to EOL (black hole)" })
lset({ "n", "x" }, "x", '"_x', { desc = "Delete char (black hole)" })
lset({ "n", "x" }, "c", '"_c', { desc = "Change (black hole)" })
lset("n", "cc", '"_cc', { desc = "Change line (black hole)" })
lset({ "n", "x" }, "C", '"_C', { desc = "Change to EOL (black hole)" })
lset("x", "p", '"_dP', { desc = "Paste over selection (keep yank)" })
return lset("x", "P", '"_dp', { desc = "Paste over selection (keep yank)" })
