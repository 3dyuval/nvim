return {
  {
    "3dyuval/heatsync.nvim",
    dev = true,
    build = "make hooks server",
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
