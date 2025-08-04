return {
  "folke/noice.nvim",
  event = "VeryLazy",
  opts = {
    presets = {
      bottom_search = true,
      command_palette = true,
      long_message_to_split = true,
    },
    cmdline = {
      view = "cmdline", -- Use classic cmdline at bottom
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
