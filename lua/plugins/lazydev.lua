return {
  "folke/lazydev.nvim",
  ft = "lua",
  cmd = "LazyDev",
  opts = {
    library = {
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      { path = "snacks.nvim", words = { "Snacks" } },
      { path = "lazy.nvim", words = { "LazyVim" } },
      { path = vim.fn.expand("~/proj/retro-fallout.nvim"), words = { "retro%-fallout" } },
      { path = vim.fn.expand("~/proj/colortweak.nvim"), words = { "colortweak" } },
    },
  },
}
