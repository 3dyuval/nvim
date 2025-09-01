local maps = require("keymaps.maps")
local map = maps.map
local func = maps.func
local desc = maps.desc
local which = maps.which

-- Implementations
local organize_imports = function()
  vim.cmd("TSToolsOrganizeImports")
  vim.cmd("TSToolsRemoveUnusedImports")
end

local organize_imports_and_fix = function()
  vim.cmd("TSToolsOrganizeImports")
  vim.cmd("TSToolsRemoveUnusedImports")
  vim.cmd("TSToolsFixAll")
end

local add_missing_imports = "<cmd>TSToolsAddMissingImports<cr>"
local remove_unused_imports = "<cmd>TSToolsRemoveUnusedImports<cr>"
local fix_all = "<cmd>TSToolsFixAll<cr>"
local select_ts_version = "<cmd>TSToolsSelectTsVersion<cr>"

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
