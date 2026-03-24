return {
  {
    "3dyuval/activity-heatmap.nvim",
    dir = "/home/yuv/proj/activity-heatmap.nvim",
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
