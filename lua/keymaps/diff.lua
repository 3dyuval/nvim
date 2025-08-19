local git = require("keymaps.git-bundle")
local lil = require("lil")

-- ============================================================================
-- SIMPLIFIED GIT DIFF SYSTEM (10 Essential Bindings)
-- ============================================================================
--
-- DESIGN PHILOSOPHY:
-- Organized git/diff operations with clear semantic patterns for maximum
-- efficiency and minimal cognitive load.
--
-- SEMANTIC PATTERNS:
-- • <leader>go/gp: Vim native diff operations - work in any diff buffer
-- • <leader>gO/gP/gU/gR: Git conflict resolution - work globally
-- • <leader>gf: File navigation (goto file and edit)
-- • ghP/ghO/ghU: Conflict version selection (merge tool context)
--
-- KEY BENEFITS:
-- ✓ Consistent muscle memory across all git contexts
-- ✓ No mode-specific overrides or context switching required
-- ✓ Single source of truth for all git diff operations (git-bundle.lua)
-- ✓ Conflict version selection for merge tool scenarios
-- ✓ Context-aware functions (direct vs windo-wrapped)
--
-- USAGE CONTEXTS:
-- • diffview.nvim buffers (uses git.windo.* functions)
-- • Regular vim diff mode (uses git.* functions)
-- • Merge conflict resolution
-- • File history browsing
--
-- ============================================================================

local leader = lil.key("Leader")

lil.map({
  ["<leader>g"] = {

    p = git.vim_diffput, -- Put hunk to other buffer (native vim)
    o = git.vim_diffget, -- Get hunk from other buffer (native vim)

    -- Conflict resolution (file-level - work everywhere)
    P = git.resolve_file_ours, -- Resolve file: ours (put)
    O = git.resolve_file_theirs, -- Resolve file: pick theirs (get)
    U = git.resolve_file_union, -- Resolve file: union (both)
    R = git.restore_conflict_markers, -- Restore conflict markers

    -- Note: File navigation (f) handled by diffview directly
    -- f = actions.goto_file_edit, -- Only works in diffview context

    n = "<cmd>:Neogit cwd=%:p:h<CR>",
    c = "<cmd>:Neogit commit<CR>",
    d = "<Cmd>DiffviewOpen<Cr>", -- <leader>gd - Diff view open
    s = "<Cmd>DiffviewFileHistory -g --range=stash<Cr>", -- <leader>gs - Diff view stash
    h = ":DiffviewFileHistory %", -- <leader>gh - Current file history
  },
})
