return {
  "nvim-mini/mini.animate",
  event = "VeryLazy",
  opts = function()
    -- Don't use animate when in operator mode (fixes ggvG issue)
    local animate = require("mini.animate")
    return {
      scroll = {
        enable = true,
        timing = animate.gen_timing.linear({ duration = 150, unit = "total" }),
        subscroll = animate.gen_subscroll.equal({ max_output_steps = 120 }),
      },
      resize = { enable = false },
      open = { enable = false },
      close = { enable = false },
      cursor = { enable = false },
    }
  end,
  config = function(_, opts)
    require("mini.animate").setup(opts)

    -- Graphite layout scroll keymaps
    vim.keymap.set({ "n", "v", "x" }, "ga", "<C-d>zz", { desc = "Scroll down (Graphite)" })
    vim.keymap.set({ "n", "v", "x" }, "ge", "<C-u>zz", { desc = "Scroll up (Graphite)" })
    vim.keymap.set({ "n", "v", "x" }, "gs", "zz", { desc = "Center screen (Graphite)" })
  end,
}
