return {
  "SmiteshP/nvim-navic",
  lazy = true,
  init = function()
    vim.g.navic_silence = true
  end,
  opts = {
    separator = "",
    highlight = true,
    depth_limit = 0,
    depth_limit_indicator = "󰘨",
    safe_output = true,
    lazy_update_context = false,
    click = false,
    format_text = function(text)
      return text
    end,
  },
}
