return {
  "dawsers/snacks-picker-firefox.nvim",
  dependencies = {
    "folke/snacks.nvim",
    "kkharji/sqlite.lua",
  },
  config = function()
    local firefox = require("firefox")

    -- Check for Zen browser first (highest priority)
    local zen_profile_dir = "~/.var/app/app.zen_browser.zen/.zen"
    if vim.fn.isdirectory(vim.fn.expand(zen_profile_dir)) == 1 then
      firefox.setup({
        -- Configuration for Zen browser (Firefox-based)
        url_open_command = "xdg-open",
        firefox_profile_dir = zen_profile_dir,
        firefox_profile_glob = "*.Default*",
      })
    else
      -- Fall back to auto-detection for other browsers/OS
      firefox.setup()
    end
  end,
}
