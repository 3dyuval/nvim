-- History and diff utilities
local M = {}

-- Open diffview comparison between buffer and selected commit
M.diffview_open_buffer_diff = function(item, data)
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
M.diffview_open_file_diff = function(item)
  local success, err = pcall(function()
    local cmd = string.format("DiffviewOpen HEAD..%s -- %s", item.hash, item.file)
    vim.cmd(cmd)
  end)

  if not success then
    vim.notify("DiffView command failed: " .. tostring(err), vim.log.levels.ERROR)
    require("file_history.actions").open_file_diff_tab(item)
  end
end

-- Smart history browser with picker integration
M.smart_file_history = function()
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
M.compare_with_commit = function(commit_hash)
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

-- Centralized key bindings table for file-history.nvim integration
M.file_history_key_bindings = {
  revert_to_selected = "<C-Enter>", -- Revert: Ctrl+Enter for destructive action
  open_file_diff_tab = "<M-f>", -- File diff: Alt+f (file focus)
  open_buffer_diff_tab = "<M-b>", -- Buffer diff: Alt+b (buffer focus)
  toggle_incremental = "<M-i>", -- Incremental: Alt+i (incremental)
  delete_history = "<M-x>", -- Delete: Alt+x (delete/remove)
  purge_history = "<M-p>", -- Purge: Alt+p (purge/permanent)
}

-- Simple history operations
M.local_file_history = function()
  require("file_history").history()
end

M.all_files_in_backup = function()
  require("file_history").files()
end

M.git_log_picker = function()
  require("snacks").picker.git_log()
end

M.file_git_log_picker = function()
  require("snacks").picker.git_log({ current = true })
end

M.firefox_bookmarks_picker = function()
  Snacks.picker.firefox_bookmarks()
end

M.query_file_history_by_time = function()
  require("file_history").query()
end

M.manual_backup_with_tag = function()
  require("file_history").backup()
end

M.project_files_history = function()
  require("file_history").project_files()
end

return M
