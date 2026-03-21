return {
  "salkhalil/summon.nvim",
  cmd = "Summon",
  keys = {
    { "<leader>rs", "<cmd>Summon<cr>", desc = "Summon" },
  },
  opts = {
    width = 0.85,
    height = 0.85,
    border = "rounded",
    commands = {
      terminal = { type = "terminal", command = "zsh", title = " Terminal ", keymap = "<C-t>" },
      readme = { type = "project_file", command = "README.md", title = " README ", keymap = "<leader>rt", filetype = "markdown" },
      todo = { type = "project_file", command = "TODO.md", title = " Todo ", filetype = "markdown" },
    },
  },
}
