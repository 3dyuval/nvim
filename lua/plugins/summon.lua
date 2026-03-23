return {
  "salkhalil/summon.nvim",
  keys = {
    { "<leader>rs", "<cmd>Summon<cr>",                                 desc = "Summon" },
    { "<C-t>",      function() require("summon").open("terminal") end, desc = "Terminal (summon)", mode = { "n", "i", "t" } },
    { "<leader>ae", function() require("summon").open("terminal") end, desc = "Terminal (summon)", mode = { "n", "i", "t" } },
  },
  opts = {
    width = 0.85,
    height = 0.85,
    border = "rounded",
    commands = {
      terminal = { type = "terminal", command = "zsh", title = " Terminal ", keymap = "<C-t>", close_keymap = "<C-t>" },
      readme = { type = "project_file", command = "README.md", title = " README ", keymap = "<leader>rt", filetype = "markdown" },
      todo = { type = "project_file", command = "TODO.md", title = " Todo ", filetype = "markdown" },
    },
  },
}
