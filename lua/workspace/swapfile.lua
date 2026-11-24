-- [nfnl] fnl/workspace/swapfile.fnl
local function _1_()
  vim.opt_local.swapfile = false
  return nil
end
vim.api.nvim_create_autocmd(
  "FileType",
  { pattern = { "snacks_win", "snacks_picker", "snacks_explorer" }, callback = _1_ }
)
local function _2_()
  vim.opt_local.swapfile = false
  vim.opt_local.undofile = false
  vim.opt_local.backup = false
  vim.opt_local.writebackup = false
  return nil
end
vim.api.nvim_create_autocmd(
  "BufReadPre",
  { pattern = { (vim.fn.expand("~") .. "/mnt/*"), (vim.fn.expand("~") .. "/.sshfs/*") }, callback = _2_ }
)
return {}
