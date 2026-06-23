-- [nfnl] fnl/plugins/hover.fnl
local function _1_()
  local tweak = require("colortweak.tweak")
  require("hover").config({providers = {"hover.providers.diagnostic", "hover.providers.lsp", "hover-mdn", "hover.providers.fold_preview", "hover.providers.man", "hover.providers.highlight"}, preview_opts = {border = "rounded"}, title = true, preview_window = false})
  tweak.hl({HoverWindow = {"Normal", {l = 0.9}}})
  return vim.api.nvim_set_hl(0, "HoverBorder", {fg = tweak.get("NormalFloat", {l = 0.5, s = 1.25}).fg, bg = vim.api.nvim_get_hl(0, {name = "Normal"}).bg})
end
return {"lewis6991/hover.nvim", event = "VeryLazy", dependencies = {"3dyuval/colortweak.nvim"}, config = _1_, dev = false}
