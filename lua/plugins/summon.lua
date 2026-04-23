return {
  "salkhalil/summon.nvim",
  opts = {
    width = 0.65,
    height = 0.8,
    border = "rounded",

    commands = {
      terminal = {
   key = "<leader>tr",
        type = "terminal", command = "zsh", title = " Terminal ", terminal_passthrough_keys = { "\x17" } },
      readme = { type = "project_file", command = "README.md", title = " README ", filetype = "markdown" },
      todo = { type = "project_file", command = "TODO.md", title = " Todo ", filetype = "markdown" },
      ["package.json"] = {
        type = "project_file",
        command = "package.json",
        title = " package.json ",
        filetype = "json",
      },
      claude = {
        type = "terminal",
        command = "zsh -i -c claude",
        title = "Claude",
        terminal_passthrough_keys = { "\x1b[44;6u", "\x17" },
        keymap = "<leader>tc",
      },
      log = { type = "terminal", command = "tail -f ~/.local/state/nvim/run-ai-run.log", title = " run-ai-run log " },
      your_program = { type = "terminal", command = "zsh ./your_program.sh", title = "Codecrafters: run" },
      test = { type = "terminal", command = "zsh codecrafters test", title = "Codecrafters: test" },
    },
  },
}
