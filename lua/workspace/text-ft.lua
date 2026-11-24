-- [nfnl] fnl/workspace/text-ft.fnl
local function _1_()
  vim.opt_local.wrap = true
  vim.opt_local.spell = false
  return nil
end
vim.api.nvim_create_autocmd(
  "FileType",
  { pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" }, callback = _1_ }
)
return {}
