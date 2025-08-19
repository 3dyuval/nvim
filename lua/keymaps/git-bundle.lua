local lil = require("lil")
local git = lil.bundle({})

-- ============================================================================
-- GIT DIFF BUNDLE - Context-Aware Functions
-- ============================================================================
--
-- Provides both direct and windo-wrapped versions of git diff functions
-- for use in global keymaps (diff.lua) and diffview panels (diffview.lua)
--
-- Usage:
--   git.diff_get          - Direct version for global keymaps
--   git.windo.diff_get()  - Windo-wrapped version for diffview panels
--
-- ============================================================================

-- Base function implementations (private)
-- Native vim commands (need windo wrapper in panels)
local function _vim_diffget()
  vim.cmd("diffget")
end

local function _vim_diffput()
  vim.cmd("diffput")
end

-- Note: Diffview actions (actions.diffget, actions.goto_file_edit) are called
-- directly in diffview.lua - they don't belong in this git bundle

local function _resolve_file_ours()
  require("git-resolve-conflict").resolve_ours()
end

local function _resolve_file_theirs()
  require("git-resolve-conflict").resolve_theirs()
end

local function _resolve_file_union()
  require("git-resolve-conflict").resolve_union()
end

local function _restore_conflict_markers()
  require("git-resolve-conflict").restore_file_conflict()
end

-- ============================================================================
-- DIRECT VERSIONS (for global keymaps)
-- ============================================================================

-- Native vim commands (work everywhere)
git.vim_diffget = _vim_diffget
git.vim_diffput = _vim_diffput

-- Git resolve conflict functions (need windo wrapper in panels)
git.resolve_file_ours = _resolve_file_ours
git.resolve_file_theirs = _resolve_file_theirs
git.resolve_file_union = _resolve_file_union
git.restore_conflict_markers = _restore_conflict_markers

-- ============================================================================
-- WINDO-WRAPPED VERSIONS (for diffview panels)
-- Only native vim commands and git-resolve functions need windo wrapper
-- Diffview actions are already context-aware!
-- ============================================================================

git.windo = {}

-- Native vim commands (need windo wrapper in panels)
git.windo.vim_diffget = function()
  local actions = require("diffview.actions")
  return actions.view_windo(_vim_diffget)
end

git.windo.vim_diffput = function()
  local actions = require("diffview.actions")
  return actions.view_windo(_vim_diffput)
end

-- Git resolve conflict functions (need windo wrapper in panels)
git.windo.resolve_file_ours = function()
  local actions = require("diffview.actions")
  return actions.view_windo(_resolve_file_ours)
end

git.windo.resolve_file_theirs = function()
  local actions = require("diffview.actions")
  return actions.view_windo(_resolve_file_theirs)
end

git.windo.resolve_file_union = function()
  local actions = require("diffview.actions")
  return actions.view_windo(_resolve_file_union)
end

git.windo.restore_conflict_markers = function()
  local actions = require("diffview.actions")
  return actions.view_windo(_restore_conflict_markers)
end

-- Note: Diffview actions DON'T need windo wrapper - they're context-aware!
-- git.dv_get_local, git.dv_get_ours, git.dv_get_theirs, git.dv_goto_file

return git