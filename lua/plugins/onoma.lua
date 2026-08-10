-- [nfnl] fnl/plugins/onoma.fnl
local function _1_()
  return Snacks.picker.get_symbols()
end
local function _2_()
  require("onoma").setup({picker = {"snacks"}})
  local function _3_()
    return Snacks.picker.get_symbols()
  end
  return vim.api.nvim_create_user_command("Onoma", _3_, {desc = "Onoma symbols picker"})
end
return {"ryanmab/onoma.nvim", enabled = true, version = "*", cmd = "Onoma", keys = {{"<leader>fo", _1_, mode = {"n", "v", "x"}, desc = "Symbols", silent = true}}, config = _2_}
