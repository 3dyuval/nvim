return {
  url = "https://gitlab.com/yuvddd/buffdoc.nvim",
  name = "buffdoc.nvim",
  ft = "buffdoc",
  config = function()
    require("buffdoc").setup({
      autorun = true,
    })
  end,
}
