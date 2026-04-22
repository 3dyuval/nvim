return {
  dir = vim.fn.expand("~/omarkit.nvim"),
  lazy = false,
  config = function()
    require("omarkit").setup()
  end,
}
