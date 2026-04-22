return {
  {
    "hernandez/dotdot.nvim",
    url = "https://codeberg.org/hernandez/dotdot.nvim",
    dependencies = { "folke/snacks.nvim" },
    opts = function()
      local px = require("utils.picker-extensions")
      return {
        insert_trigger = "..",
        adapter = "snacks",
        commands = {
          {
            id = "explorer",
            title = "Open Explorer",
            run = function()
              px.open_explorer()
            end,
          },
          {
            id = "git_conflicts",
            title = "Git Conflicts",
            run = function()
              px.git_conflicts()
            end,
          },
        },
      }
    end,
  },
}
