return {
  "karb94/neoscroll.nvim",
  config = function()
    local neoscroll = require("neoscroll")
    neoscroll.setup({
      mappings = {
        "<C-u>",
        "<C-d>",
        "<C-b>",
        "<C-f>",
        "<C-y>",
        "<C-e>",
      },
      hide_cursor = true,
      stop_eof = true,
      respect_scrolloff = false,
      cursor_scrolls_alone = true,
      duration_multiplier = 0.8,
      easing = "linear",
      pre_hook = nil,
      post_hook = nil,
      performance_mode = true,
      ignored_events = {
        "WinScrolled",
        "CursorMoved",
      },
    })

    local keymap = {
      ["ga"] = function()
        local bufname = vim.api.nvim_buf_get_name(0)
        return not bufname:match("^diffview://")
          and neoscroll.ctrl_d({ duration = 150, easing = "linear" })
      end,
      ["ge"] = function()
        local bufname = vim.api.nvim_buf_get_name(0)
        return not bufname:match("^diffview://")
          and neoscroll.ctrl_u({ duration = 150, easing = "linear" })
      end,
    }
    local modes = { "n", "v", "x" }
    for key, func in pairs(keymap) do
      vim.keymap.set(modes, key, func)
    end
  end,
}
