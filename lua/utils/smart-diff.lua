-- ============================================================================
-- SMART CONTEXT-AWARE DIFF SYSTEM
-- ============================================================================
-- Automatically detects context and uses appropriate diff system:
-- • Regular vim diff buffers → Use native vim commands
-- • Diffview buffers → Use diffview actions
-- • Normal buffers with conflicts → Use git commands

local M = {}

-- ============================================================================
-- CONTEXT DETECTION
-- ============================================================================

-- Check if currently in a diffview-managed buffer
local function in_diffview()
  -- Check if diffview is loaded and has an active view
  local ok, diffview_lib = pcall(require, "diffview.lib")
  if not ok then
    return false
  end

  local view = diffview_lib.get_current_view()
  return view ~= nil
end

-- Check if current buffer is a vim diff buffer
local function is_diff_buffer()
  return vim.opt_local.diff:get()
end

-- Check if current file has git conflict markers
local function has_conflict_markers()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  for _, line in ipairs(lines) do
    if line:match("^<<<<<<<") or line:match("^=======") or line:match("^>>>>>>>") then
      return true
    end
  end
  return false
end

-- ============================================================================
-- SMART DIFF OPERATIONS
-- ============================================================================

-- Smart diffget - Get hunk from other buffer (context-aware)
function M.smart_diffget()
  if in_diffview() then
    -- In diffview, use diffview actions
    local actions = require("diffview.actions")
    return actions.diffget("local")
  elseif is_diff_buffer() then
    -- In regular vim diff, use native diffget
    return vim.cmd("diffget")
  else
    vim.notify("Not in diff context - use conflict resolution instead", vim.log.levels.WARN)
  end
end

-- Smart diffput - Put hunk to other buffer (context-aware)
function M.smart_diffput()
  if in_diffview() then
    -- In diffview, use diffview actions (rarely works - target usually read-only)
    vim.notify("diffput rarely works in diffview (target read-only)", vim.log.levels.INFO)
    return vim.cmd("diffput")
  elseif is_diff_buffer() then
    -- In regular vim diff, use native diffput
    return vim.cmd("diffput")
  else
    vim.notify("Not in diff context", vim.log.levels.WARN)
  end
end

-- ============================================================================
-- UNIVERSAL CONFLICT RESOLUTION (works everywhere)
-- ============================================================================

-- Resolve entire file as OURS (current branch)
function M.smart_resolve_ours()
  local file = vim.fn.expand("%")
  if file == "" then
    vim.notify("No file to resolve", vim.log.levels.ERROR)
    return
  end

  vim.cmd("update") -- Save changes first
  vim.cmd("!git checkout --ours -- " .. vim.fn.shellescape(file))
  vim.cmd("edit!") -- Reload file
  vim.notify("Resolved as OURS: " .. file, vim.log.levels.INFO)
end

-- Resolve entire file as THEIRS (incoming branch)
function M.smart_resolve_theirs()
  local file = vim.fn.expand("%")
  if file == "" then
    vim.notify("No file to resolve", vim.log.levels.ERROR)
    return
  end

  vim.cmd("update") -- Save changes first
  vim.cmd("!git checkout --theirs -- " .. vim.fn.shellescape(file))
  vim.cmd("edit!") -- Reload file
  vim.notify("Resolved as THEIRS: " .. file, vim.log.levels.INFO)
end

-- Resolve entire file as UNION (both versions)
function M.smart_resolve_union()
  local file = vim.fn.expand("%")
  if file == "" then
    vim.notify("No file to resolve", vim.log.levels.ERROR)
    return
  end

  if not has_conflict_markers() then
    vim.notify("No conflict markers found in file", vim.log.levels.WARN)
    return
  end

  vim.cmd("update") -- Save changes first

  -- Use git merge-file with union strategy
  local temp_base = vim.fn.tempname()
  local temp_ours = vim.fn.tempname()
  local temp_theirs = vim.fn.tempname()

  -- Create temporary files for merge-file command
  vim.cmd(
    "!git show :1:"
      .. vim.fn.shellescape(file)
      .. " > "
      .. temp_base
      .. " 2>/dev/null || echo '' > "
      .. temp_base
  )
  vim.cmd(
    "!git show :2:"
      .. vim.fn.shellescape(file)
      .. " > "
      .. temp_ours
      .. " 2>/dev/null || echo '' > "
      .. temp_ours
  )
  vim.cmd(
    "!git show :3:"
      .. vim.fn.shellescape(file)
      .. " > "
      .. temp_theirs
      .. " 2>/dev/null || echo '' > "
      .. temp_theirs
  )

  -- Perform union merge
  vim.cmd(
    "!git merge-file --union " .. vim.fn.shellescape(file) .. " " .. temp_base .. " " .. temp_theirs
  )

  -- Clean up temporary files
  vim.fn.delete(temp_base)
  vim.fn.delete(temp_ours)
  vim.fn.delete(temp_theirs)

  vim.cmd("edit!") -- Reload file
  vim.notify("Resolved as UNION: " .. file, vim.log.levels.INFO)
end

-- Restore git conflict markers
function M.smart_restore_conflicts()
  local file = vim.fn.expand("%")
  if file == "" then
    vim.notify("No file to restore", vim.log.levels.ERROR)
    return
  end

  vim.cmd("update") -- Save changes first
  vim.cmd("!git checkout --merge -- " .. vim.fn.shellescape(file))
  vim.cmd("edit!") -- Reload file
  vim.notify("Restored conflict markers: " .. file, vim.log.levels.INFO)
end

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

-- Get context information (for debugging)
function M.get_context_info()
  local info = {
    in_diffview = in_diffview(),
    is_diff_buffer = is_diff_buffer(),
    has_conflict_markers = has_conflict_markers(),
    file = vim.fn.expand("%"),
    buffer_type = vim.bo.buftype,
  }

  print("Diff Context Info:")
  for k, v in pairs(info) do
    print("  " .. k .. ": " .. tostring(v))
  end

  return info
end

return M
