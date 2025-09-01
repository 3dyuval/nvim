-- Code utilities (TypeScript/JavaScript)
local M = {}

M.organize_imports = function()
  vim.cmd("TSToolsOrganizeImports")
  vim.cmd("TSToolsRemoveUnusedImports")
end

M.organize_imports_and_fix = function()
  vim.cmd("TSToolsOrganizeImports")
  vim.cmd("TSToolsRemoveUnusedImports")
  vim.cmd("TSToolsFixAll")
end

M.add_missing_imports = "<cmd>TSToolsAddMissingImports<cr>"
M.remove_unused_imports = "<cmd>TSToolsRemoveUnusedImports<cr>"
M.fix_all = "<cmd>TSToolsFixAll<cr>"
M.select_ts_version = "<cmd>TSToolsSelectTsVersion<cr>"

-- Go to source definition functions
M.go_to_source_definition = "<cmd>TSToolsGoToSourceDefinition<cr>"
M.file_references = "<cmd>TSToolsFileReferences<cr>"

return M
