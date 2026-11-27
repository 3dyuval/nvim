-- [nfnl] fnl/config/keymaps/inspect.fnl
local _local_1_ = require("config.keymaps.register")
local register = _local_1_.register
local del_very_lazy = _local_1_["del-very-lazy"]
del_very_lazy("n", { "<leader>ui", "<leader>uI" })
local function _2_()
  return require("textobject-hud").open()
end
local function _3_()
  vim.treesitter.inspect_tree()
  return vim.api.nvim_input("I")
end
return register(
  "<leader>i",
  {
    group = "Inspect",
    o = { cmd = _2_, desc = "Textobject HUD" },
    p = { cmd = vim.show_pos, desc = "Inspect Pos" },
    t = { cmd = _3_, desc = "Inspect Tree" },
  }
)
