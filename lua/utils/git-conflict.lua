-- Git conflict detection and handling utilities
-- Shared utilities for conflict detection across diffview, neogit, and other git plugins

local M = {}

--- Check if the cursor is currently positioned within a merge conflict marker
--- Uses Tree-sitter to detect conflict markers in the current buffer
--- @return boolean true if cursor is in a conflict block
function M.is_in_conflict()
  local ok, parser = pcall(vim.treesitter.get_parser, 0)
  if not ok then
    return false
  end

  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local query = vim.treesitter.query.get(parser:lang(), "conflict")

  if query then
    local tree = parser:parse()[1]
    for _, node in query:iter_captures(tree:root(), 0, row, row + 1) do
      return true
    end
  end
  return false
end

--- Check if the repository currently has merge conflicts
--- Uses git status to detect conflict state
--- @return boolean true if repository has unresolved conflicts
function M.has_merge_conflicts()
  local result = vim.fn.systemlist("git status --porcelain")
  if vim.v.shell_error ~= 0 then
    return false
  end

  for _, line in ipairs(result) do
    -- Check for conflict status codes: UU, AA, DD, AU, UA, DU, UD
    local status = line:sub(1, 2)
    if status:match("^[UAD][UAD]$") then
      return true
    end
  end
  return false
end

--- Get list of files with merge conflicts
--- @return string[] list of conflicted file paths
function M.get_conflicted_files()
  local result = vim.fn.systemlist("git status --porcelain")
  local conflicted_files = {}

  if vim.v.shell_error ~= 0 then
    return conflicted_files
  end

  for _, line in ipairs(result) do
    local status = line:sub(1, 2)
    if status:match("^[UAD][UAD]$") then
      local filepath = line:sub(4) -- Remove status codes and space
      table.insert(conflicted_files, filepath)
    end
  end

  return conflicted_files
end

--- Check if a specific file has conflicts
--- @param filepath string path to the file to check
--- @return boolean true if file has conflicts
function M.file_has_conflicts(filepath)
  local conflicted_files = M.get_conflicted_files()
  for _, file in ipairs(conflicted_files) do
    if file == filepath then
      return true
    end
  end
  return false
end

--- Get the current merge state of the repository
--- @return string|nil "merge", "rebase", "cherry-pick", or nil if not in merge state
function M.get_merge_state()
  local git_dir = vim.fn.systemlist("git rev-parse --git-dir")[1]
  if vim.v.shell_error ~= 0 then
    return nil
  end

  -- Check for various merge states
  if vim.fn.filereadable(git_dir .. "/MERGE_HEAD") == 1 then
    return "merge"
  elseif
    vim.fn.filereadable(git_dir .. "/rebase-merge") == 1
    or vim.fn.filereadable(git_dir .. "/rebase-apply") == 1
  then
    return "rebase"
  elseif vim.fn.filereadable(git_dir .. "/CHERRY_PICK_HEAD") == 1 then
    return "cherry-pick"
  end

  return nil
end

--- Smart diffview opener that detects conflict state and opens appropriate view
--- @param args string|nil additional arguments for DiffviewOpen
function M.smart_diffview_open(args)
  if M.has_merge_conflicts() then
    -- Open diffview in merge mode (auto-detects 3-way merge)
    vim.cmd("DiffviewOpen" .. (args and " " .. args or ""))
  else
    -- Regular diff view
    vim.cmd("DiffviewOpen" .. (args and " " .. args or ""))
  end
end

return M
