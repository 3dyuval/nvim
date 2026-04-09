return {
  {
    "3dyuval/history-api.nvim",
    dependencies = {
      "folke/snacks.nvim",
      "kkharji/sqlite.lua",
    },
    config = function()
      require("history-api").setup({
        create_commands = true,
        enabled_browsers = { "chromium", "brave" },
        browser_paths = {
          chromium = "/home/yuv/.config/chromium/Default/History",
          brave = "/home/yuv/.config/BraveSoftware/Brave-Browser/Default/History",
          firefox = "~/.mozilla/firefox/*.default-release/places.sqlite",
        },
      })
    end,
  },
}

--[[[
 To find your actual paths, run these commands in your terminal:
 ```bash
 # Firefox
 ls ~/.mozilla/firefox/*/places.sqlite
 # Zen
 ls ~/.zen/*/places.sqlite
 # Chromium
 ls ~/.config/chromium/Default/History
 # Brave
 ls ~/.config/BraveSoftware/Brave-Browser/Default/History
 ```
 Then update the `browser_paths` with the exact paths found.,
              ]]
--
