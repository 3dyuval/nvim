return {
  dir = "~/buffdoc.nvim",
  ft = "buffdoc",
  config = function()
    require("buffdoc").setup({
      autorun = true,
    })
  end,
}
