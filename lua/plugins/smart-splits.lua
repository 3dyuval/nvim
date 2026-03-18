return {
  "mrjones2014/smart-splits.nvim",
  build = "$HOME/.local/share/nvim/lazy/smart-splits.nvim/kitty/install-kittens.bash",
  lazy = false,
  opts = {
    multiplexer_integration = 'kitty',
    at_edge = function(ctx)
      local dirs = { left = 'l', right = 'r', up = 'u', down = 'd' }
      vim.fn.jobstart({ 'hyprctl', 'dispatch', 'movefocus', dirs[ctx.direction] })
    end,
  },
  keys = {
    { '<C-h>', function() require('smart-splits').move_cursor_left() end,  desc = 'Move focus left' },
    { '<C-a>', function() require('smart-splits').move_cursor_down() end,  desc = 'Move focus down' },
    { '<C-e>', function() require('smart-splits').move_cursor_up() end,    desc = 'Move focus up' },
    { '<C-i>', function() require('smart-splits').move_cursor_right() end, desc = 'Move focus right' },
  },
  config = function()
    require("smart-splits").setup()
  end,
}
