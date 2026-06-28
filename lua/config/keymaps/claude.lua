-- [nfnl] fnl/config/keymaps/claude.fnl
local _local_1_ = require("config.keymaps.register")
local register = _local_1_.register
local tree = {["<C-r>"] = ":ClaudeCode<CR>", ["<leader>a"] = {group = "AI/Claude", c = ":ClaudeCode<CR>", f = ":ClaudeCodeFocus<CR>", r = ":ClaudeCode --resume<CR>", C = ":ClaudeCode --continue<CR>", m = ":ClaudeCodeSelectModel<CR>", p = ":ClaudeCodeAdd %<CR>", s = ":ClaudeCodeSend<CR>", a = ":ClaudeCodeDiffAccept<CR>", d = ":ClaudeCodeDiffDeny<CR>"}}
return register("", tree)
