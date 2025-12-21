-- Git operations utilities
local M = {}

-- Simple git operations
M.vim_diffget = function()
  vim.cmd("diffget")
end

M.vim_diffput = function()
  vim.cmd("diffput")
end

-- Git conflict resolution functions
M.resolve_file_ours = function()
  local file = vim.fn.expand("%")
  vim.cmd("update") -- Save any changes first
  vim.cmd("!git checkout --ours -- " .. vim.fn.shellescape(file))
  vim.cmd("edit!") -- Reload the file
end

M.resolve_file_theirs = function()
  local file = vim.fn.expand("%")
  vim.cmd("update") -- Save any changes first
  vim.cmd("!git checkout --theirs -- " .. vim.fn.shellescape(file))
  vim.cmd("edit!") -- Reload the file
end

M.resolve_file_union = function()
  require("git-resolve-conflict").resolve_union()
end

M.restore_conflict_markers = function()
  local file = vim.fn.expand("%")
  vim.cmd("update") -- Save any changes first
  vim.cmd("!git checkout --merge -- " .. vim.fn.shellescape(file))
  vim.cmd("edit!") -- Reload the file
end

-- Git picker operations
M.lazygit_root = function()
  Snacks.lazygit()
end

M.lazygit_cwd = function()
  Snacks.lazygit({ cwd = LazyVim.root.get() })
end

M.git_branches_picker = function()
  Snacks.picker.git_branches({ all = true })
end

-- GitHub repository detection
M.get_upstream_repo = function()
  local upstream_url = vim.fn.system("git config --get remote.upstream.url 2>/dev/null"):gsub("%s+", "")

  if vim.v.shell_error ~= 0 or upstream_url == "" then
    return nil
  end

  -- Extract owner/repo from URL
  -- Handles: https://github.com/owner/repo.git or git@github.com:owner/repo.git
  local owner_repo = upstream_url:match("github%.com[:/](.+/.+)%.git$") or upstream_url:match("github%.com[:/](.+/.+)$")

  return owner_repo
end

M.get_github_repo = function()
  -- Try upstream first, fallback to current repo (nil = auto-detect current)
  return M.get_upstream_repo()
end

return M
