-- [nfnl] fnl/config/keymaps/inspect.fnl
local _local_1_ = require("config.keymaps.register")
local register = _local_1_.register
local del_very_lazy = _local_1_["del-very-lazy"]
del_very_lazy("n", { "<leader>ui", "<leader>uI" })
local function aerial_toggle(expand_3f)
  local function _2_()
    local aerial = require("aerial")
    aerial.toggle()
    if expand_3f then
      return aerial.tree_open_all()
    else
      return aerial.tree_close_all()
    end
  end
  return _2_
end
local function _4_()
  return require("textobject-hud").open()
end
local function _5_()
  vim.treesitter.inspect_tree()
  return vim.api.nvim_input("I")
end
return register(
  "<leader>a",
  {
    group = "Inspect",
    o = { cmd = _4_, desc = "Textobject HUD" },
    p = { cmd = vim.show_pos, desc = "Inspect Pos" },
    t = { cmd = _5_, desc = "Inspect Tree" },
    a = { cmd = aerial_toggle(true), desc = "Aerial (Outline, expanded)" },
    h = { cmd = aerial_toggle(false), desc = "Aerial (Outline, collapsed)" },
    f = { cmd = "<Cmd>AerialFocus<CR>", desc = "Aerial (Focus)" },
    c = { cmd = "<Cmd>AerialClose<CR>", desc = "Aerial (Close)" },
  }
)
