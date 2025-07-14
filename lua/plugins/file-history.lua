return {
  "dawsers/file-history.nvim",
  dependencies = {
    "folke/snacks.nvim",
  },
  config = function()
    local file_history = require("file_history")
    file_history.setup({
      -- Default values
      backup_dir = "~/.file-history-git",
      git_cmd = "git",
      -- Use default hostname detection
      hostname = nil,
    })
  end,
}