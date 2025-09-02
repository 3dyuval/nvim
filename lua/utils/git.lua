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

return M
