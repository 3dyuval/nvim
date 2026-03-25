return {
  {
    "3dyuval/heatsync.nvim",
    dir = "/home/yuv/proj/heatsync.nvim",
    dev = true,
    build = "make hooks server",
    dependencies = { "nvzone/volt", "nvzone/menu" },
    opts = {
      dashboard = true,
      actions = {
        {
          label  = "Copy date",
          key    = "y",
          action = function(item)
            vim.fn.setreg("+", item.date)
            vim.notify("Copied: " .. item.date)
          end,
        },
      },
    },
  },
}
