local lil = require("lil")
local extern = lil.extern

-- ============================================================================
-- CODE OPERATIONS KEYMAPS
-- ============================================================================

lil.map({
  -- Navigation
  gD = "<cmd>TSToolsGoToSourceDefinition<cr>",
  gR = "<cmd>TSToolsFileReferences<cr>",
  
  -- Leader-based operations
  ["<leader>"] = {
    c = {
      o = extern.organize_imports, -- Organize + Remove Unused Imports
      I = "<cmd>TSToolsAddMissingImports<cr>", -- Add missing imports
      u = "<cmd>TSToolsRemoveUnusedImports<cr>", -- Remove unused imports
      F = "<cmd>TSToolsFixAll<cr>", -- Fix all diagnostics
      V = "<cmd>TSToolsSelectTsVersion<cr>", -- Select TS workspace version
    },
    g = {
      o = extern.organize_imports, -- Organize + Remove Unused Imports (git-style)
      O = extern.organize_imports_and_fix, -- Organize Imports + Fix All Diagnostics
    },
  },
})

