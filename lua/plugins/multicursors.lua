-- vim-visual-multi plugin configuration for GitHub issue #38
--
-- ATTEMPTS MADE:
-- 1. Complex config function with all VM settings - FAILED: Timing issues, variables set too late
-- 2. Used init function instead of config - FAILED: Still had timing problems
-- 3. Moved all VM variables to options.lua - SUCCESS: Variables now load properly
-- 4. Simplified to minimal plugin spec - CURRENT: Only lazy loading hints remain
-- 5. Tried different VM leaders: <leader>m, <leader>v, <leader>k
-- 6. Removed event = "VeryLazy" to avoid lazy loading conflicts
--
-- CURRENT ISSUE: Plugin loads, keymaps show in which-key, but don't execute
-- All VM configuration now in lua/config/options.lua
-- This file only provides lazy loading hints via keys table

return {
  "mg979/vim-visual-multi",
  -- Remove event loading to avoid timing issues
  keys = {
    { "<leader>kk", desc = "Multi-cursor word" },
    { "<leader>ka", desc = "Add cursor below" },
    { "<leader>ke", desc = "Add cursor above" },
    { "<leader>kA", desc = "Select all occurrences" },
  },
}
