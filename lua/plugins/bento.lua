-- [nfnl] fnl/plugins/bento.fnl
local menu_actions = {
  { "open", "<CR>", "DiagnosticVirtualTextHint" },
  { "delete", "<BS>", "DiagnosticVirtualTextError" },
  { "vsplit", "|", "DiagnosticVirtualTextInfo" },
  { "split", "_", "DiagnosticVirtualTextInfo" },
  { "lock", "*", "DiagnosticVirtualTextWarn" },
}
local function _1_(_, opts)
  require("bento").setup(opts)
  local api = require("bento.api")
  api.register_expand_key(";")
  api.register_last_buffer_key(";")
  api.register_collapse_key("<Esc>")
  api.register_prev_page_key("[")
  api.register_next_page_key("]")
  for _0, _2_ in ipairs(menu_actions) do
    local name = _2_[1]
    local key = _2_[2]
    local hl = _2_[3]
    api.register_action(name, { key = key, action = api.actions[name], hl = hl })
  end
  return api.set_default_action("open")
end
return {
  { "akinsho/bufferline.nvim", enabled = false },
  {
    "serhez/bento.nvim",
    enabled = true,
    opts = {
      ui = { mode = "tabline", tabline = { separator_symbol = " " } },
      highlights = {
        current = "Bold",
        active = "Normal",
        inactive = "Comment",
        modified = "DiagnosticWarn",
        label_minimal = "Comment",
        window_bg = "Normal",
        separator = "Comment",
      },
    },
    config = _1_,
    lazy = false,
  },
}
