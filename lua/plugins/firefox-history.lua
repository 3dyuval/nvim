return {
  "dawsers/snacks-picker-firefox.nvim",
  dependencies = {
    "folke/snacks.nvim",
    "kkharji/sqlite.lua",
  },
  config = function()
    local firefox = require("firefox")
    firefox.setup({
      -- Configuration for Zen browser (Firefox-based)
      url_open_command = "xdg-open",
      firefox_profile_dir = "~/.zen",
      firefox_profile_glob = "*.Default*",
    })
  end,
}
