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
  api.register_expand_key("<C-;>")
  api.register_last_buffer_key("<C-;>")
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
  {
    "serhez/bento.nvim",
    enabled = true,
    opts = {
      lock_char = "\240\159\148\146",
      max_open_buffers = nil,
      buffer_deletion_metric = "frecency_access",
      buffer_notify_on_delete = true,
      ordering_metric = "access",
      ui = {
        mode = "floating",
        floating = {
          position = "middle-left",
          offset_x = 0,
          offset_y = 0,
          dash_char = "\226\148\128",
          border = "none",
          label_padding = 1,
          minimal_menu = nil,
          max_rendered_buffers = nil,
        },
        tabline = {
          left_page_symbol = "\226\157\174",
          right_page_symbol = "\226\157\175",
          separator_symbol = "\226\148\130",
        },
      },
      highlights = {
        current = "Bold",
        active = "Normal",
        inactive = "Comment",
        modified = "DiagnosticWarn",
        inactive_dash = "Comment",
        previous = "Search",
        label = "DiagnosticVirtualTextHint",
        label_minimal = "Visual",
        window_bg = "BentoNormal",
        page_indicator = "Comment",
        separator = "Normal",
      },
      locked_first = false,
      map_last_accessed = false,
    },
    config = _1_,
    dev = false,
    lazy = false,
  },
}
