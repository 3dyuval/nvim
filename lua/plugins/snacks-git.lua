return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        git_branches = {
          auto_close = false,
          focus = "list",
          actions = {
            branch_actions_menu = function(picker)
              -- Use the centralized picker-extensions for branch actions
              local picker_extensions = require("utils.picker-extensions")
              picker_extensions.show_context_menu(picker)
            end,
          },
          win = {
            list = {
              keys = {
                ["p"] = "branch_actions_menu",
              },
            },
          },
        },
      },
    },
  },
}
