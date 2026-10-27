-- [nfnl] fnl/plugins/git.fnl
local function _1_()
  return require("conflict").setup()
end
return {"niekdomi/conflict.nvim", config = _1_}
