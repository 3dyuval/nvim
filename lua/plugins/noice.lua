return {
  "folke/noice.nvim",
  event = "VeryLazy",
  keys = {
    { "<leader>sn", false }, -- +noice group prefix
    -- { "<S-Enter>", false }, -- Redirect cmdline output to split
    { "<leader>snl", false }, -- Noice Last Message
    { "<leader>snh", false }, -- Noice History
    { "<leader>sna", false }, -- Noice All messages
    { "<leader>snd", false }, -- Dismiss All notifications
    { "<leader>snt", false }, -- Noice Picker (Telescope/FzfLua)
    -- { "<c-f>", false }, -- Scroll forward in LSP docs/signature
    -- { "<c-b>", false }, -- Scroll backward in LSP docs/signature
  },
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
      input = {
        relative = "editor",
        position = {
          row = -2, -- Same position as cmdline
          col = "50%",
        },
        size = {
          min_width = 60, -- Same min_width as cmdline
          width = "auto",
          height = "auto",
        },
        border = {
          style = "rounded", -- Same border style as cmdline
          padding = { 0, 1 }, -- Same padding as cmdline
        },
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
    lsp = {
      -- Disable default Noice LSP config to avoid conflicts
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = false,
        ["vim.lsp.util.stylize_markdown"] = false,
        ["cmp.entry.get_documentation"] = false,
      },
    },
    commands = {
      all = {
        view = "split",
        opts = { enter = true, format = "details" },
        filter = {},
        filter_opts = { reverse = true },
      },
    },
  },
}
