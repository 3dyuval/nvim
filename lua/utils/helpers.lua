-- Helper functions for keymaps.lua
-- Consolidates inline functions and command builders used in keymap definitions

local M = {}


-- ============================================================================
-- GIT COMPARISON FUNCTIONS
-- ============================================================================

-- Compare current file with branch
function M.compare_current_file_with_branch()
  local target = vim.fn.input("Compare with: ", "HEAD~1")
  if target ~= "" then
    vim.cmd("DiffviewOpen " .. target .. " -- %")
  end
end

-- Compare current file with another file
function M.compare_current_file_with_file()
  local currentFile = vim.fn.expand("%:.")
  local targetFile = vim.fn.input("Compare with file: ", currentFile, "file")
  if targetFile == "" then
    return
  end

  local targetBranch = vim.fn.input("Compare with branch (empty for working tree): ", "")

  if targetBranch ~= "" then
    -- Use DiffviewOpen for branch comparison
    vim.cmd("DiffviewOpen " .. targetBranch .. " -- " .. targetFile)
  else
    -- Compare with file in working tree using vim diff
    if targetFile ~= currentFile then
      vim.cmd("vert diffsplit " .. vim.fn.fnameescape(targetFile))
    end
  end
end

-- ============================================================================
-- TREESITTER TEXT OBJECT FUNCTIONS
-- ============================================================================

-- Select treesitter text objects
function M.select_inner_function()
  require("nvim-treesitter.textobjects.select").select_textobject("@function.inner", "textobjects")
end

function M.select_outer_function()
  require("nvim-treesitter.textobjects.select").select_textobject("@function.outer", "textobjects")
end

function M.select_jsx_self_closing_element()
  require("nvim-treesitter.textobjects.select").select_textobject(
    "@jsx_self_closing_element",
    "textobjects"
  )
end

-- ============================================================================
-- NAVIGATION FUNCTIONS
-- ============================================================================

-- Count-aware delete function for 'x' key
function M.count_aware_delete()
  local count = vim.v.count1
  return count == 1 and "d" or (count .. "d")
end

-- Terminal toggle function
function M.toggle_terminal()
  Snacks.terminal()
end

-- ============================================================================
-- FOLD-AWARE YANK FUNCTION
-- ============================================================================

-- Fold-aware yanking (visual mode only)
function M.yank_visible()
  require("utils.fold-yank").yank_visible()
end

return M