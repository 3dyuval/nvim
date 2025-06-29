return {
  "mikesmithgh/kitty-scrollback.nvim",
  enabled = true,
  lazy = true,
  cmd = { "KittyScrollbackGenerateKittens", "KittyScrollbackCheckHealth", "KittyScrollbackGenerateCommandLineEditing" },
  event = { "User KittyScrollbackLaunch" },
  -- version = '*', -- latest stable version, may have breaking changes if major version changed
  -- version = '^6.0.0', -- pin major version, include fixes and features that do not have breaking changes
  config = function()
    require("kitty-scrollback").setup({
      myconf = {
        status_window = {
          enabled = false,
          autoclose = false,
        },
        paste_window = {
          enabled = false,
          yank_register_enabled = false,
        },
        keymaps_enabled = false,
        kitty_get_text = {
          ansi = true,
        },
      },
    })
  end,
}
