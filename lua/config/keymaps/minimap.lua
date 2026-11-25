-- [nfnl] fnl/config/keymaps/minimap.fnl
local _local_1_ = require("config.keymaps.register")
local register = _local_1_.register
return register(
  "<leader>M",
  {
    group = "Minimap",
    m = { cmd = ":Neominimap Toggle<CR>", desc = "Toggle minimap" },
    o = { cmd = ":Neominimap Enable<CR>", desc = "Enable minimap" },
    c = { cmd = ":Neominimap Disable<CR>", desc = "Disable minimap" },
    f = { cmd = ":Neominimap ToggleFocus<CR>", desc = "Toggle focus" },
    r = { cmd = ":Neominimap Refresh<CR>", desc = "Refresh minimap" },
  }
)
