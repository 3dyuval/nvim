local maps = require("keymaps.maps")
local git = require("keymaps.git-bundle")
local map = maps.map
local func = maps.func
local desc = maps.desc
local which = maps.which

map({
  [func] = which,
  ["<leader>g"] = {
    -- Vim diff operations
    p = desc("Put hunk to other buffer (native vim)", git.vim_diffput),
    o = desc("Get hunk from other buffer (native vim)", git.vim_diffget),

    -- Conflict resolution (file-level - work everywhere)
    P = desc("Resolve file: ours (put)", git.resolve_file_ours),
    O = desc("Resolve file: pick theirs (get)", git.resolve_file_theirs),
    U = desc("Resolve file: union (both)", git.resolve_file_union),
    R = desc("Restore conflict markers", git.restore_conflict_markers),

    -- Neogit and diffview commands
    n = desc("Neogit in current dir", "<cmd>:Neogit cwd=%:p:h<CR>"),
    c = desc("Neogit commit", "<cmd>:Neogit commit<CR>"),
    d = desc("Diff view open", "<Cmd>DiffviewOpen<Cr>"),
    S = desc("Diff view stash", "<Cmd>DiffviewFileHistory -g --range=stash<Cr>"),
    h = desc("Current file history", ":DiffviewFileHistory %"),
  },
  
  -- Gitsigns toggle commands under <leader>ug
  ["<leader>ug"] = {
    g = desc("Toggle Git Signs", "<leader>uG"), -- Maps to default LazyVim toggle
    l = desc("Toggle line highlights", "<cmd>Gitsigns toggle_linehl<cr>"),
    n = desc("Toggle number highlights", "<cmd>Gitsigns toggle_numhl<cr>"),
    w = desc("Toggle word diff", "<cmd>Gitsigns toggle_word_diff<cr>"),
    b = desc("Toggle current line blame", "<cmd>Gitsigns toggle_current_line_blame<cr>"),
  },
})