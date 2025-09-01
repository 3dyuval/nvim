local lil = require("lil")
local git = lil.bundle({})

-- Simple git operations
git.vim_diffget = function()
  vim.cmd("diffget")
end

git.vim_diffput = function()
  vim.cmd("diffput")
end

-- Git conflict resolution functions
git.resolve_file_ours = function()
  local file = vim.fn.expand("%")
  vim.cmd("update") -- Save any changes first
  vim.cmd("!git checkout --ours -- " .. vim.fn.shellescape(file))
  vim.cmd("edit!") -- Reload the file
end

git.resolve_file_theirs = function()
  local file = vim.fn.expand("%")
  vim.cmd("update") -- Save any changes first
  vim.cmd("!git checkout --theirs -- " .. vim.fn.shellescape(file))
  vim.cmd("edit!") -- Reload the file
end

git.resolve_file_union = function()
  require("git-resolve-conflict").resolve_union()
end

git.restore_conflict_markers = function()
  local file = vim.fn.expand("%")
  vim.cmd("update") -- Save any changes first
  vim.cmd("!git checkout --merge -- " .. vim.fn.shellescape(file))
  vim.cmd("edit!") -- Reload the file
end

return git
