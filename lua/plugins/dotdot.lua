return {
  {
    "hernandez/dotdot.nvim",
    url = "https://codeberg.org/hernandez/dotdot.nvim",
    dependencies = {"folke/snacks.nvim"},
    event = "InsertEnter",
    keys = {
      {
        "<C-,>",
        function()
          require("dotdot").show()
        end,
        mode = "i",
        desc = "dotdot commands"
      }
    },
    opts = {
      adapter = "snacks",
      insert_trigger = "..",
      commands = {
        {
          id = "explorer",
          title = "Open Explorer",
          category = "FILES",
          run = function(ctx)
            require("utils.picker-extensions").open_explorer()
          end
        },
        {
          id = "git_conflicts",
          title = "Git Conflicts",
          category = "GIT",
          run = function(ctx)
            require("utils.picker-extensions").git_conflicts()
          end
        }
      }
    }
  }
}
