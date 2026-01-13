return {
  dir = "~/proj/searxng",
  dependencies = { "folke/snacks.nvim" },
  opts = {
    engines = {
      { id = "gh", name = "GitHub", url = "https://github.com/search?q=%s" },
      { id = "npm", name = "NPM", url = "https://npmjs.com/search?q=%s" },
    },
    lists = {
      code = { "gh", "npm" }, -- resolved from engines above + SearXNG engines
    },
  },
}
