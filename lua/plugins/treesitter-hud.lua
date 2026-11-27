-- [nfnl] fnl/plugins/treesitter-hud.fnl
local function _1_()
  local hud = require("textobject-hud")
  local tbobj = require("treesitter.textobjects")
  return { sources = { hud.sources.treesitter }, key_hints = tbobj["hud-hints"]() }
end
return {
  {
    "so1ve/textobject-hud.nvim",
    dependencies = { "nvim-mini/mini.nvim", "nvim-treesitter/nvim-treesitter-textobjects" },
    lazy = true,
    opts = _1_,
  },
}
