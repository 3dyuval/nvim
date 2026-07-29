-- [nfnl] fnl/plugins/onoma.fnl
local function _1_()
  require("onoma").setup({picker = {"snacks"}})
  return vim.keymap.set({"n", "v", "x"}, "<M-f>", Snacks.picker.get_symbols, {desc = "Symbols", silent = true})
end
return {"ryanmab/onoma.nvim", enabled = true, version = "*", event = "VeryLazy", config = _1_}
