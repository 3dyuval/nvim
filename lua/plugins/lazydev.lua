return {
  "folke/lazydev.nvim",
  ft = "lua",
  cmd = "LazyDev",
  opts = {
    library = {
      { path = "${3rd}/luv/library" },
      { path = vim.env.VIMRUNTIME .. "/lua" },
      { path = "snacks.nvim" },
      { path = "lazy.nvim" },
      { path = vim.fn.expand("~/proj/retro-fallout.nvim") },
      { path = vim.fn.expand("~/proj/colortweak.nvim") },
      { path = vim.fn.expand("~/proj/searxng") },
    },
    enabled = true,
  },
}
