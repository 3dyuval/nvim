-- [nfnl] fnl/config/keymaps/surround.fnl
local lset = vim.keymap.set
lset("x", "s", "<Plug>(nvim-surround-visual)", {desc = "Surround visual selection"})
lset("x", "gS", "<Plug>(nvim-surround-visual-line)", {desc = "Surround visual selection (newlines)"})
return require("which-key").add({{"ys", "group", "Add surround"}, {"yS", "group", "Add surround (newlines)"}, {"ds", "group", "Delete surround"}, {"cs", "group", "Change surround"}, {"cS", "group", "Change surround (newlines)"}, {"s", "mode", "x", "group", "Surround"}, {"gS", "mode", "x", "group", "Surround (newlines)"}})
