return {
  dir = vim.fn.expand('~/.local/share/omarchy/plugins/omarkitty.nvim'),
  lazy = false,
  config = function()
    require('omarkitty').setup()
  end,
}
