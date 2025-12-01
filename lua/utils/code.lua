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

M.get_code_path = function()
  local navic = require("nvim-navic")
  -- NOTE current lsp must support documentSymbolProvider.
  if navic.is_available() then
    local location = navic.get_location()
    if location and location ~= "" then
      return location
    end
  end
  vim.notify("No code context available", vim.log.levels.WARN)
end

M.set_buffer_file_type_with_lsp = function(ft)
  vim.bo.filetype = ft
end

return M
