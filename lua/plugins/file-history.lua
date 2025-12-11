return {
  "dawsers/file-history.nvim",
  dependencies = {
    "folke/snacks.nvim",
  },
  config = function()
    local file_history = require("file_history")
    local history_utils = require("utils.history")

    file_history.setup({
      backup_dir = "~/.file-history-git",
      git_cmd = "git",
      hostname = nil,
      key_bindings = history_utils.file_history_key_bindings,
    })

    -- DIFFVIEW INTEGRATION EXTENSION
    -- Override file_history actions with diffview integration functions
    local original_actions = require("file_history.actions")
    original_actions.open_buffer_diff_tab = history_utils.diffview_open_buffer_diff
    original_actions.open_file_diff_tab = history_utils.diffview_open_file_diff
  end,
}
