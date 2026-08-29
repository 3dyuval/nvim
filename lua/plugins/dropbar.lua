-- [nfnl] fnl/plugins/dropbar.fnl
local function _1_()
  local dropbar = require("dropbar")
  local default_enable = require("dropbar.configs").opts.bar.enable
  local excluded_ft = {kulala_ui = true, kulala_openapi = true}
  local function _2_(buf, win, extra)
    return (not excluded_ft[vim.bo[buf].filetype] and default_enable(buf, win, extra))
  end
  local function _3_(_, _0)
    local sources = require("dropbar.sources")
    local function _4_(buf, win, cursor)
      if next(vim.lsp.get_clients({bufnr = buf})) then
        return sources.lsp.get_symbols(buf, win, cursor)
      else
        return sources.treesitter.get_symbols(buf, win, cursor)
      end
    end
    return {sources.path, {get_symbols = _4_}}
  end
  dropbar.setup({sources = {}, bar = {enable = _2_, sources = _3_}})
  return vim.keymap.set("n", "<leader>o.", require("dropbar.api").pick, {desc = "Breadcrumb pick (dropbar)"})
end
return {"Bekaboo/dropbar.nvim", event = "VeryLazy", config = _1_}
