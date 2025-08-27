local map = vim.keymap.set

-- Create a table to hold our external functions (replacing lil.extern)
local extern = {}

-- ============================================================================
-- CENTRALIZED HISTORY INTEGRATION FUNCTIONS
-- ============================================================================
--
-- DESIGN PHILOSOPHY:
-- Centralized diffview integration functions that can be reused across
-- multiple plugins (file-history.nvim, diffview.nvim, etc.) to avoid
-- code duplication and maintain consistent behavior.
--
-- KEY BENEFITS:
-- ✓ Single source of truth for diffview integration logic
-- ✓ Reusable across different history plugins
-- ✓ Graceful fallback to vim native diff when diffview fails
-- ✓ Consistent error handling and user feedback
--
-- USAGE:
-- Import these functions in plugins that need diffview integration:
-- local history_actions = require("lil").extern
-- history_actions.diffview_open_buffer_diff(item, data)
--
-- ============================================================================
-- EXTERNAL ACTION DEFINITIONS (Single Source of Truth)
-- ============================================================================

-- Open diffview comparison between buffer and selected commit
extern.diffview_open_buffer_diff = function(item, data)
  if not data.buf then
    return
  end

  local current_file = vim.api.nvim_buf_get_name(data.buf)

  if current_file == "" then
    vim.notify("No file currently open", vim.log.levels.ERROR)
    return
  end

  -- Trust that DiffView is available and handle errors gracefully
  local success, err = pcall(function()
    local cmd =
      string.format("DiffviewOpen %s -- %s", item.hash, vim.fn.fnamemodify(current_file, ":."))
    vim.cmd(cmd)
  end)

  if not success then
    vim.notify("DiffView command failed: " .. tostring(err), vim.log.levels.ERROR)
    -- Fallback to original vim diff method
    require("file_history.actions").open_buffer_diff_tab(item, data)
  end
end

-- Open diffview comparison between HEAD and selected commit for specific file
extern.diffview_open_file_diff = function(item)
  local success, err = pcall(function()
    local cmd = string.format("DiffviewOpen HEAD..%s -- %s", item.hash, item.file)
    vim.cmd(cmd)
  end)

  if not success then
    vim.notify("DiffView command failed: " .. tostring(err), vim.log.levels.ERROR)
    require("file_history.actions").open_file_diff_tab(item)
  end
end

-- ============================================================================
-- ADVANCED HISTORY OPERATIONS (Available for Future Use)
-- ============================================================================

-- Smart history browser with picker integration
extern.smart_file_history = function()
  -- Check if file is under git control
  local current_file = vim.fn.expand("%:p")
  if current_file == "" then
    vim.notify("No file currently open", vim.log.levels.WARN)
    return
  end

  -- Try git log first, fallback to file-history.nvim
  local success = pcall(function()
    require("snacks").picker.git_log({ current = true })
  end)

  if not success then
    -- Fallback to file-history plugin
    require("file_history").history()
  end
end

-- Enhanced file comparison with context
extern.compare_with_commit = function(commit_hash)
  local current_file = vim.fn.expand("%:.")
  if current_file == "" then
    vim.notify("No file currently open", vim.log.levels.WARN)
    return
  end

  local success, err = pcall(function()
    local cmd = string.format("DiffviewOpen %s~1..%s -- %s", commit_hash, commit_hash, current_file)
    vim.cmd(cmd)
  end)

  if not success then
    vim.notify("Failed to compare with commit: " .. tostring(err), vim.log.levels.ERROR)
  end
end

-- ============================================================================
-- CENTRALIZED KEY BINDINGS TABLE (file-history.nvim integration)
-- ============================================================================
--
-- Semantic, conflict-free key assignments for file-history plugin
extern.file_history_key_bindings = {
  revert_to_selected = "<C-Enter>", -- Revert: Ctrl+Enter for destructive action
  open_file_diff_tab = "<M-f>", -- File diff: Alt+f (file focus)
  open_buffer_diff_tab = "<M-b>", -- Buffer diff: Alt+b (buffer focus)
  toggle_incremental = "<M-i>", -- Incremental: Alt+i (incremental)
  delete_history = "<M-x>", -- Delete: Alt+x (delete/remove)
  purge_history = "<M-p>", -- Purge: Alt+p (purge/permanent)
}

-- ============================================================================
-- KEYBINDING MAPPINGS (History-specific operations)
-- ============================================================================

map("n", "<leader>hh", function()
  require("file_history").history()
end, { desc = "Local file history" })

map("n", "<leader>ha", function()
  require("file_history").files()
end, { desc = "All files in backup" })

map("n", "<leader>hs", extern.smart_file_history, { desc = "Smart history picker" })

map("n", "<leader>hl", function()
  require("snacks").picker.git_log()
end, { desc = "Git log" })

map("n", "<leader>hf", function()
  require("snacks").picker.git_log({ current = true })
end, { desc = "File git log" })

-- Export the extern table for use by other modules if needed
return extern

