-- [nfnl] fnl/plugins/treesitter-hud.fnl
local function _1_()
  return require("textobject-hud").open()
end
local function _2_()
  local hud = require("textobject-hud")
  local tbobj = require("treesitter.textobjects")
  return {sources = {hud.sources.treesitter}, key_hints = tbobj["hud-hints"]()}
end
return {{"so1ve/textobject-hud.nvim", dependencies = {"nvim-mini/mini.nvim", "nvim-treesitter/nvim-treesitter-textobjects"}, keys = {{"<leader>o", _1_, desc = "Textobject HUD"}}, opts = _2_}}
