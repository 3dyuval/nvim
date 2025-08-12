return {
  "dawsers/file-history.nvim",
  dependencies = {
    "folke/snacks.nvim",
    "va9iff/lil",
  },
  config = function()
    local file_history = require("file_history")

    file_history.setup({
      backup_dir = "~/.file-history-git",
      git_cmd = "git",
      hostname = nil,
      key_bindings = require("lil")._.file_history_key_bindings,
    })

    -- Note: Keymaps now handled by keymaps/history.lua for centralized management

    -- DIFFVIEW INTEGRATION EXTENSION
    -- Use centralized functions from keymaps/history.lua
    local original_actions = require("file_history.actions")
    local history_actions = require("lil").extern

    -- Override with centralized diffview integration functions
    original_actions.open_buffer_diff_tab = history_actions.diffview_open_buffer_diff
    original_actions.open_file_diff_tab = history_actions.diffview_open_file_diff
  end,
}
