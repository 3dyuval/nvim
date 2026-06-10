-- [nfnl] fnl/plugins/hover.fnl
local function _1_()
  require("hover").config({providers = {"hover.providers.diagnostic", "hover.providers.lsp", "hover.providers.fold_preview", "hover.providers.man", "hover.providers.highlight"}, preview_opts = {border = "single"}, title = true, preview_window = false})
  local function _2_()
    return require("hover").open()
  end
  vim.keymap.set("n", "K", _2_, {desc = "Hover"})
  local function _3_()
    return require("hover").select()
  end
  return vim.keymap.set("n", "gH", _3_, {desc = "Hover (pick provider)"})
end
return {"lewis6991/hover.nvim", event = "VeryLazy", config = _1_}
