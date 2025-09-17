return {
  "dawsers/snacks-picker-firefox.nvim",
  dependencies = {
    "folke/snacks.nvim",
    "kkharji/sqlite.lua",
  },
  config = function()
    local firefox = require("firefox")
    -- Let the plugin auto-detect OS and browser paths
    firefox.setup()
  end,
}
