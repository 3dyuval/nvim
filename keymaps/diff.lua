local lil = require("lil")
local extern = lil.extern

-- ============================================================================
-- SIMPLIFIED GIT DIFF SYSTEM (6 Essential Bindings)
-- ============================================================================
--
-- DESIGN PHILOSOPHY:
-- Reduced from 12+ scattered git/diff bindings to 6 essential operations
-- with clear semantic patterns for maximum efficiency and minimal cognitive load.
--
-- SEMANTIC PATTERNS:
-- • Lowercase (go/gp): Vim native diff operations - work in any diff buffer
-- • Uppercase (gO/gP/gU/gR): Git conflict resolution - work globally
--
-- KEY BENEFITS:
-- ✓ Consistent muscle memory across all git contexts
-- ✓ No mode-specific overrides or context switching required  
-- ✓ Single source of truth for all git diff operations
-- ✓ Simplified from complex plugin-specific bindings to 6 universal ones
--
-- USAGE CONTEXTS:
-- • diffview.nvim buffers (auto-wrapped with view_windo)
-- • Regular vim diff mode
-- • Merge conflict resolution
-- • File history browsing
--
-- ============================================================================
-- EXTERNAL ACTION DEFINITIONS (Single Source of Truth)
-- ============================================================================

-- Diff operations (vim native)
extern.diff_get = function()
  vim.cmd("diffget")
end

extern.diff_put = function()
  vim.cmd("diffput")
end

-- File-level conflict resolution (git-resolve-conflict plugin)
extern.resolve_file_ours = function()
  require("git-resolve-conflict").resolve_ours()
end

extern.resolve_file_theirs = function()
  require("git-resolve-conflict").resolve_theirs()
end

extern.resolve_file_union = function()
  require("git-resolve-conflict").resolve_union()
end

extern.restore_conflict_markers = function()
  require("git-resolve-conflict").restore_file_conflict()
end

-- ============================================================================
-- ADVANCED DIFF OPERATIONS (Currently Unused - Available for Future Use)
-- ============================================================================

-- Advanced hunk-level union operation
-- Combines current hunk with corresponding hunk from other diff buffer
-- Based on: https://vi.stackexchange.com/a/36854/38754
extern.pure_diff_union = function()
  if not vim.bo.modifiable then
    vim.notify("Current buffer is not modifiable", vim.log.levels.WARN)
    return
  end

  -- Helper function to check if line is part of diff
  local function is_diff_line(line_no)
    return vim.fn.diff_hlID(line_no, 1) > 0
  end

  -- Find start and end of current diff hunk
  local function get_hunk_range()
    local line = vim.fn.line(".")
    if not is_diff_line(line) then
      return nil, nil
    end

    local startline = line
    while is_diff_line(startline - 1) do
      startline = startline - 1
    end

    local endline = line
    while is_diff_line(endline + 1) do
      endline = endline + 1
    end

    return startline, endline
  end

  local startline, endline = get_hunk_range()
  if not startline then
    vim.notify("Cursor is not on a diff hunk", vim.log.levels.WARN)
    return
  end

  -- Find the other diff buffer
  local other_win = nil
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if buf ~= vim.api.nvim_get_current_buf() and vim.bo[buf].diff then
      other_win = win
      break
    end
  end

  if not other_win then
    vim.notify("No other diff buffer found", vim.log.levels.WARN)
    return
  end

  -- Get lines from current buffer
  local current_lines = vim.api.nvim_buf_get_lines(0, startline - 1, endline, false)

  -- Get corresponding lines from other buffer
  local other_buf = vim.api.nvim_win_get_buf(other_win)
  local other_lines = vim.api.nvim_buf_get_lines(other_buf, startline - 1, endline, false)

  -- Combine lines (current first, then other)
  local union_lines = {}
  for _, line in ipairs(current_lines) do
    table.insert(union_lines, line)
  end
  for _, line in ipairs(other_lines) do
    table.insert(union_lines, line)
  end

  -- Replace current hunk with union
  vim.api.nvim_buf_set_lines(0, startline - 1, endline, false, union_lines)
  vim.notify("Combined hunk from both buffers", vim.log.levels.INFO)
end

-- Smart get all hunks with file history support
-- Uses restore_entry in file history mode, %diffget otherwise
extern.smart_get_all = function()
  if not vim.bo.modifiable then
    -- In file history mode, use restore_entry
    local view = require("diffview.lib").get_current_view()
    if
      view
      and view:instanceof(
        require("diffview.scene.views.file_history.file_history_view").FileHistoryView
      )
    then
      require("diffview.actions").restore_entry()
      return
    end
  end
  -- Normal mode: get all hunks
  vim.cmd("%diffget")
end

-- ============================================================================
-- SIMPLIFIED KEYBINDING MAPPINGS (6 Essential Operations)
-- ============================================================================

lil.map {
  g = {
    -- Diff operations (vim native - work in any diff buffer)
    o = extern.diff_get,  -- Get hunk from other buffer
    p = extern.diff_put,  -- Put hunk to other buffer
    
    -- Conflict resolution (file-level - work everywhere)
    O = extern.resolve_file_ours,     -- Resolve file: ours
    P = extern.resolve_file_theirs,   -- Resolve file: pick theirs  
    U = extern.resolve_file_union,    -- Resolve file: union (both)
    R = extern.restore_conflict_markers, -- Restore conflict markers
  }
}