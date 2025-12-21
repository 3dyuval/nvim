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

return M
