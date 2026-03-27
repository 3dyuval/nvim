return {
  "salkhalil/summon.nvim",
  keys = {
    { "<leader>rt", "<cmd>Summon<cr>", desc = "Summon" },
    { "<leader>rs", function() require("summon").pick() end, desc = "Summon menu" },
  },
  opts = {
    width = 0.65,
    height = 0.8,
    border = "rounded",
    commands = {
      terminal = { type = "terminal", command = "zsh", title = " Terminal ", },
      readme = { type = "project_file", command = "README.md", title = " README ", filetype = "markdown" },
      todo = { type = "project_file", command = "TODO.md", title = " Todo ", filetype = "markdown" },
      ["package.json"] = { type = "project_file", command = "package.json", title = " package.json ", filetype = "json" },
    },
  },
}
