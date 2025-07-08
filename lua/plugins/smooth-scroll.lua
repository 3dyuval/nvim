return {
  "karb94/neoscroll.nvim",
  config = function()
    local neoscroll = require("neoscroll")
    neoscroll.setup({
      mappings = {},
      hide_cursor = false, -- Hide cursor while scrolling
      stop_eof = true, -- Stop at <EOF> when scrolling downwards
      respect_scrolloff = false, -- Stop scrolling when the cursor reaches the scrolloff margin of the file
      cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
      duration_multiplier = 1.0, -- Global duration multiplier
      easing = "quadratic", -- Default easing function
      pre_hook = nil, -- Function to run before the scrolling animation starts
      post_hook = nil, -- Function to run after the scrolling animation ends
      performance_mode = false, -- Disable "Performance Mode" on all buffers.
      ignored_events = { -- Events ignored while scrolling
        "WinScrolled",
        "CursorMoved",
      },
    })

    local keymap = {
      ["ga"] = function()
        neoscroll.zt({ half_win_duration = 250 })
      end,
      ["ge"] = function()
        neoscroll.zb({ half_win_duration = 250 })
      end,
      ["gs"] = function()
        neoscroll.zz({ half_win_duration = 250 })
      end,
    }
    local modes = { "n", "v", "x" }
    for key, func in pairs(keymap) do
      vim.keymap.set(modes, key, func)
    end
  end,
}
