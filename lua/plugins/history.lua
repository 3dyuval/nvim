return {
  {
    "3dyuval/history-api.nvim",
    dependencies = {
      "folke/snacks.nvim",
      "kkharji/sqlite.lua",
    },
    config = function()
      local api = require("history-api")

      api.setup({
        create_commands = true,
        enabled_browsers = { "chromium", "brave", "firefox", "zen" },
      })
    end,
  },
  {
    "gbprod/yanky.nvim",
    dependencies = { "folke/snacks.nvim", "kkharji/sqlite.lua" },
    event = "VeryLazy",
    opts = {
      ring = {
        history_length = 100,
        storage = "sqlite",
        sync_with_numbered_registers = true,
        cancel_event = "update",
      },
      system_clipboard = {
        sync_with_ring = true,
      },
      highlight = {
        on_put = true,
        on_yank = true,
        timer = 500,
      },
      preserve_cursor_position = {
        enabled = true,
      },
    },
    keys = {
      { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank text" },
      { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put after cursor" },
      { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put before cursor" },
      { "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" }, desc = "Put after and leave cursor" },
      {
        "gP",
        "<Plug>(YankyGPutBefore)",
        mode = { "n", "x" },
        desc = "Put before and leave cursor",
      },
      { "[p", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put indented before" },
      { "]p", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put indented after" },
      { "[P", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put indented before" },
      { "]P", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put indented after" },
      { ">p", "<Plug>(YankyPutIndentAfterShiftRight)", desc = "Put and indent right" },
      { "<p", "<Plug>(YankyPutIndentAfterShiftLeft)", desc = "Put and indent left" },
      { ">P", "<Plug>(YankyPutIndentBeforeShiftRight)", desc = "Put before and indent right" },
      { "<P", "<Plug>(YankyPutIndentBeforeShiftLeft)", desc = "Put before and indent left" },
      { "=p", "<Plug>(YankyPutAfterFilter)", desc = "Put after with filter" },
      { "=P", "<Plug>(YankyPutBeforeFilter)", desc = "Put before with filter" },
    },
  },
}
