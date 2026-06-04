return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    triggers = {
      { "<auto>", mode = "nxs" }, -- exclude operator-pending ("o") so cs([ etc. work
    },
    plugins = {
      spelling = false,
      presets = {
        operators = false,
        motions = false,
        text_objects = false,
        windows = false,
        nav = false,
        z = false,
        g = false,
      },
      registers = false, -- Disable register preview to avoid command-line interference
    },
  },
}
