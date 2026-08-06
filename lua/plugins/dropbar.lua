-- [nfnl] fnl/plugins/dropbar.fnl
local function _1_()
  local dropbar = require("dropbar")
  local function _2_(_, _0)
    local sources = require("dropbar.sources")
    local function _3_(buf, win, cursor)
      if next(vim.lsp.get_clients({bufnr = buf})) then
        return sources.lsp.get_symbols(buf, win, cursor)
      else
        return sources.treesitter.get_symbols(buf, win, cursor)
      end
    end
    return {sources.path, {get_symbols = _3_}}
  end
  dropbar.setup({sources = {}, bar = {sources = _2_}})
  return vim.keymap.set("n", "<leader>o.", require("dropbar.api").pick, {desc = "Breadcrumb pick (dropbar)"})
end
return {"Bekaboo/dropbar.nvim", event = "VeryLazy", config = _1_}
