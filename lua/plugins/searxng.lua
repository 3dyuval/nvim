-- [nfnl] fnl/plugins/searxng.fnl
return {
  "3dyuval/searxng.nvim",
  dir = "~/proj/searxng.nvim",
  dependencies = { "folke/snacks.nvim" },
  event = "VeryLazy",
  opts = { mapping = { engines = false, prompt = false, reload = false, visual = false, word = false } },
}
