local maps = require("keymaps.maps")
local map = maps.map
local func = maps.func
local desc = maps.desc
local which = maps.which

-- Forward declarations
local organize_imports
local organize_imports_and_fix
local add_missing_imports
local remove_unused_imports
local fix_all
local select_ts_version

-- Keymaps
map({
  [func] = which,
  ["<leader>c"] = {
    o = desc("Organize + Remove Unused Imports", organize_imports),
    O = desc("Organize Imports + Fix All Diagnostics", organize_imports_and_fix),
    I = desc("Add missing imports", add_missing_imports),
    u = desc("Remove unused imports", remove_unused_imports),
    F = desc("Fix all diagnostics", fix_all),
    V = desc("Select TS workspace version", select_ts_version),
  },
})

-- Implementations
organize_imports = function()
  vim.cmd("TSToolsOrganizeImports")
  vim.cmd("TSToolsRemoveUnusedImports")
end

organize_imports_and_fix = function()
  vim.cmd("TSToolsOrganizeImports")
  vim.cmd("TSToolsRemoveUnusedImports")
  vim.cmd("TSToolsFixAll")
end

add_missing_imports = "<cmd>TSToolsAddMissingImports<cr>"
remove_unused_imports = "<cmd>TSToolsRemoveUnusedImports<cr>"
fix_all = "<cmd>TSToolsFixAll<cr>"
select_ts_version = "<cmd>TSToolsSelectTsVersion<cr>"
