return {
  "salkhalil/summon.nvim",
  opts = {
    width = 0.65,
    height = 0.8,
    border = "rounded",

    commands = {
      terminal = { type = "terminal", command = "zsh", title = " Terminal ", terminal_passthrough_keys = { "\x17" } },
      readme = { type = "project_file", command = "README.md", title = " README ", filetype = "markdown" },
      todo = { type = "project_file", command = "TODO.md", title = " Todo ", filetype = "markdown" },
      ["package.json"] = { type = "project_file", command = "package.json", title = " package.json ", filetype = "json" },
      claude = { type = "terminal", command = "zsh -i -c kitty_session", title = "Claude Kitty Instance", terminal_passthrough_keys = { "\x1b[44;6u" }, keymap = "<leader>tc" },
      log = { type = "terminal", command = "tail -f ~/.local/state/nvim/run-ai-run.log", title = " run-ai-run log " }
    },
  },
}
