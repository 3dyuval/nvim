return {
  {
    "3dyuval/heatsync.nvim",
    dir = "/home/yuv/proj/heatsync.nvim",
    dev = true,
    dependencies = { "nvzone/volt", "nvzone/menu" },
    opts = {
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
