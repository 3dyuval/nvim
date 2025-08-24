local git = require("keymaps.git-bundle")
local lil = require("lil")

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
