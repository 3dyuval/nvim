return {
  "folke/noice.nvim",
  event = "VeryLazy",
  opts = {
    cmdline = {
      view = "cmdline_popup", -- Use floating cmdline but we'll position it at bottom
    },
    views = {
      cmdline_popup = {
        relative = "editor",
        position = {
          row = -2, -- 2 rows from bottom
          col = "50%",
        },
        size = {
          min_width = 60,
          width = "auto",
          height = "auto",
        },
        border = {
          style = "rounded",
          padding = { 0, 1 },
        },
      },
      cmdline_popupmenu = {
        relative = "editor",
        position = {
          row = -5, -- 5 rows from bottom (more space above cmdline)
          col = "50%",
        },
        size = {
          width = "auto",
          height = "auto",
          max_height = 10,
        },
        border = {
          style = "rounded",
          padding = { 0, 1 },
        },
      },
      mini = {
        relative = "editor",
        position = {
          row = -1,
          col = "100%",
        },
        align = "message-right",
      },
      popup = {
        relative = "editor",
        position = {
          row = -10, -- Messages popup at bottom
          col = "50%",
        },
      },
      confirm = {
        relative = "editor",
        position = {
          row = -8, -- Confirmation messages near bottom
          col = "50%",
        },
      },
      hover = {
        relative = "cursor", -- Keep hover at cursor
        position = { row = 1, col = 0 },
      },
    },
    presets = {
      bottom_search = true,
      command_palette = true,
      long_message_to_split = true,
    },
    routes = {
      {
        filter = {
          event = "msg_show",
          kind = "emsg",
          find = "E21",
        },
        opts = { skip = true },
      },
    },
  },
}
