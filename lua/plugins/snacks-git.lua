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
              local item = picker_extensions.get_current_item(picker)
              picker_extensions.context_menu(picker, item)
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
