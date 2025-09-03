-- ============================================================================
-- UTILITY FUNCTIONS (from keymaps.maps)
-- ============================================================================

local lil = require("lil")
local func = lil.flags.func
local opts = lil.flags.opts

local function which(m, l, r, o, _next)
  -- Delete existing mapping first, then set new one (override behavior)
  pcall(vim.keymap.del, m, l)
  vim.keymap.set(m, l, r, { desc = o and o.desc or nil })
end

local function desc(d, value)
  return {
    value,
    [func] = which,
    [opts] = { desc = d },
  }
end

local function remap(mode, lhs, rhs, opts)
  pcall(vim.keymap.del, mode, lhs)
  vim.keymap.set(mode, lhs, rhs, opts)
end

local function cmd(command)
  return "<Cmd>" .. command .. "<Cr>"
end

-- ============================================================================
-- FUNCTION IMPORTS
-- ============================================================================

local clipboard = require("utils.clipboard")
local code = require("utils.code")
local editor = require("utils.editor")
local files = require("utils.files")
local git = require("utils.git")
local history = require("utils.history")
local navigation = require("utils.navigation")
local octo = require("utils.octo")
local search = require("utils.search")

-- ============================================================================
-- KEYMAPS FROM keymaps/ DIRECTORY
-- ============================================================================

-- Remove legacy imports
pcall(vim.keymap.del, "n", "<leader>gd")

-- ============================================================================
-- GIT AND DIFF OPERATIONS (from keymaps/diff.lua)
-- ============================================================================

lil.map({
  [func] = which,
  g = {
    o = desc("Get hunk from other buffer (native vim)", git.vim_diffget),
    p = desc("Put hunk to other buffer (native vim)", git.vim_diffput),
  },
  ["<leader>g"] = {
    -- Vim diff operations

    -- Conflict resolution (file-level - work everywhere)
    P = desc("Resolve file: ours (put)", git.resolve_file_ours),
    O = desc("Resolve file: pick theirs (get)", git.resolve_file_theirs),
    U = desc("Resolve file: union (both)", git.resolve_file_union),
    R = desc("Restore conflict markers", git.restore_conflict_markers),

    -- Neogit and diffview commands
    n = desc("Neogit in current dir", cmd(":Neogit cwd=%:p:h")),
    c = desc("Neogit commit", cmd(":Neogit commit")),
    d = desc("Diff view open", cmd("DiffviewOpen")),
    S = desc("Diff view stash", cmd("DiffviewFileHistory -g --range=stash")),
    h = desc("Current file history", ":DiffviewFileHistory %"),

    -- Git tools
    z = desc("Lazygit (Root Dir)", git.lazygit_root),
    Z = desc("Lazygit (cwd)", git.lazygit_cwd),
    b = desc("Git branches (all)", git.git_branches_picker),
  },

  -- Gitsigns toggle commands under <leader>ug
  ["<leader>ug"] = {
    g = desc("Toggle Git Signs", "<leader>uG"), -- Maps to default LazyVim toggle
    l = desc("Toggle line highlights", cmd("Gitsigns toggle_linehl")),
    n = desc("Toggle number highlights", cmd("Gitsigns toggle_numhl")),
    w = desc("Toggle word diff", cmd("Gitsigns toggle_word_diff")),
    b = desc("Toggle current line blame", cmd("Gitsigns toggle_current_line_blame")),
  },
})

-- ============================================================================
-- CODE OPERATIONS (from keymaps/g.lua and keymaps/c.lua)
-- ============================================================================

lil.map({
  [func] = which,
  g = {
    D = desc("Go to source definition", code.go_to_source_definition),
    R = desc("File references", code.file_references),
  },
})

lil.map({
  [func] = which,
  ["<leader>c"] = {
    o = desc("Organize + Remove Unused Imports", code.organize_imports),
    O = desc("Organize Imports + Fix All Diagnostics", code.organize_imports_and_fix),
    I = desc("Add missing imports", code.add_missing_imports),
    u = desc("Remove unused imports", code.remove_unused_imports),
    F = desc("Fix all diagnostics", code.fix_all),
    V = desc("Select TS workspace version", code.select_ts_version),
    t = desc("TypeScript type check", editor.typescript_check),
  },
})

-- ============================================================================
-- FILE OPERATIONS (from keymaps/f.lua)
-- ============================================================================

lil.map({
  [func] = which,
  ["<leader>"] = {
    [" "] = desc("Find files (fff.nvim)", files.find_files),
    f = {
      f = desc("Find files (snacks + fff)", files.find_files_snacks),
      s = desc("Save file", files.save_file),
      S = desc("Save and stage file", files.save_and_stage_file),
    },
  },
})

-- Override the default <leader><space> mapping after lil.map
remap("n", "<leader><space>", files.find_files, { desc = "Find files (fff.nvim)" })

-- ============================================================================
-- HISTORY OPERATIONS (from keymaps/h.lua)
-- ============================================================================

local map = vim.keymap.set

lil.map({
  [func] = which,
  ["<leader>h"] = {
    h = desc("Local file history", history.local_file_history),
    a = desc("All files in backup", history.all_files_in_backup),
    s = desc("Smart history picker", history.smart_file_history),
    l = desc("Git log", history.git_log_picker),
    f = desc("File git log", history.file_git_log_picker),
    u = desc("View undo list", cmd("undolist")),
    B = desc("Firefox bookmarks", history.firefox_bookmarks_picker),
    A = desc("Query file history by time range", history.query_file_history_by_time),
    T = desc("Manual backup with tag", history.manual_backup_with_tag),
    p = desc("Project files history", history.project_files_history),
  },
})

-- ============================================================================
-- ORIGINAL KEYMAPS (existing configuration)
-- ============================================================================

-- Delete on 'x' (Graphite layout) - but allow surround plugin to handle 'xs'
-- Note: surround plugin will handle 'xs' directly, this handles other 'x' operations
-- Use function to ensure xx behaves like dd (delete line and yank)
map({ "n" }, "x", function()
  local count = vim.v.count1
  if count == 1 then
    return "d"
  else
    return count .. "d"
  end
end, { desc = "Delete", expr = true })

-- Special case: xx should behave like dd (delete line and yank)
map({ "n" }, "xx", "dd", { desc = "Delete line (and yank)" })

-- Visual mode: x still maps to d
map({ "x" }, "x", "d", { desc = "Delete" })

-- Up/down/left/right
map({ "n", "o", "x" }, "h", "h", { desc = "Left (h)" })
map({ "n", "o", "x" }, "e", "k", { desc = "Up (k)" })
map({ "n", "o", "x" }, "a", "j", { desc = "Down (j)" })
map({ "n", "o", "x" }, "i", "l", { desc = "Right (l)" })

-- E/A moved to smart context-aware functions below (lines 124-125)

-- Override HAEI navigation in visual modes (including visual line mode)
-- Use noremap to fully override default vim behavior including text objects
map("x", "e", "k", { noremap = true, desc = "Up in visual modes" })
map("x", "a", "j", { noremap = true, desc = "Down in visual modes" })
map("x", "h", "h", { noremap = true, desc = "Left in visual modes" })
map("x", "i", "l", { noremap = true, desc = "Right in visual modes" })

-- Line operations and find
map({ "n" }, "j", "o", { desc = "Open line below" })
map({ "n" }, "J", "O", { desc = "Open line above" })
-- f is now default (find character forward)
-- F is default (find character backward)

-- Beginning/end of line
map({ "n", "o", "x" }, "0", "0", { desc = "Beginning of line" })
map({ "n", "o", "x" }, "p", "^", { desc = "First non-blank character" })
map({ "n", "o", "x" }, ".", "$", { desc = "End of line" })

-- Insert/append
-- map({ "v" }, "S", "I", { desc = "Insert at start of selection" })
map({ "n" }, "r", "i", { desc = "Insert before cursor" })
map({ "n" }, "R", "I", { desc = "Insert at start of line" })
map({ "n" }, "t", "a", { desc = "Insert after cursor" })
map({ "n" }, "T", "A", { desc = "Insert at end of line" })
map({ "n" }, "S", "R", { desc = "Replace mode" })

-- Jumplist navigation
map({ "n" }, "o", "<C-o>", { desc = "Jumplist backward" })
map({ "n" }, "O", "<C-i>", { desc = "Jumplist forward" })

-- PageUp/PageDown
map({ "n", "x" }, "<C-.>", "<PageUp>", { desc = "Page Up" })
map({ "n", "x" }, "<C-p>", "<PageDown>", { desc = "Page Down" })
-- Word left/right
map({ "n", "o", "x" }, "l", "b", { desc = "Word back" })
map({ "n", "o", "x" }, "d", "w", { desc = "Word forward" })
map({ "n", "o", "x" }, "L", "B", { desc = "WORD back" })
map({ "n", "o", "x" }, "D", "W", { desc = "WORD forward" })

-- Move lines with Alt+A/E (COMMENTED OUT - conflicts with treewalker swap)
-- map({ "n" }, "<M-C-a>", "<cmd>move .+1<cr>==", { desc = "Move line down" })
-- map({ "n" }, "<M-C-e>", "<cmd>move .-2<cr>==", { desc = "Move line up" })

-- Search navigation (moved from <C-f> due to jumplist conflict)
map({ "n", "o", "x" }, "<C-s>", "n", { desc = "Next search match" })
map({ "n", "o", "x" }, "<C-S>", "N", { desc = "Previous search match" })

-- Map semicolon to repeat last command (instead of dot)
map({ "n" }, ";", ".", { desc = "Repeat last command" })
-- Move repeat find to different keys
map({ "n", "o", "x" }, "g;", ";", { desc = "Repeat find forward" })
map({ "n", "o", "x" }, "-", ",", { desc = "Repeat find backward" })
map({ "n", "o", "x" }, "%", "%", { desc = "Jump to matching bracket" })

-- Smart context-aware navigation - diff navigation baseline (Graphite layout)
map({ "n", "o", "x" }, "A", "]c", { desc = "Next diff hunk" })
map({ "n", "o", "x" }, "E", "[c", { desc = "Previous diff hunk" })

-- End of word left/right (moved to different keys)
-- map({ "n", "o", "x" }, "gh", "ge", { desc = "End of word back" })
map({ "n", "o", "x" }, "<M-h>", "gE", { desc = "End of WORD back" })
map({ "n", "o", "x" }, "<M-o>", "E", { desc = "End of WORD forward" })

-- Keep visual replace on a different key
map({ "v" }, "X", "r", { desc = "Replace selected text" })

-- Folds (f and F remain default vim find character forward/backward)
map({ "n", "x" }, "fo", "zo", { desc = "Open fold (unfold)" })
map({ "n", "x" }, "fu", "zc", { desc = "Close fold (fold one)" })
map({ "n", "x" }, "ff", "zM", { desc = "Close all folds (fold all)" })
map({ "n", "x" }, "fF", "zR", { desc = "Open all folds (unfold all)" })
map({ "n", "x" }, "fe", "zk", { desc = "Move up to fold" })
map({ "n", "x" }, "fa", "zj", { desc = "Move down to fold" })
map({ "n", "x" }, "bb", "zb", { desc = "Scroll line and cursor to bottom" })

-- Copy/paste
map({ "n", "o", "x" }, "c", "y", { desc = "Yank (copy)" })
map({ "n", "x" }, "v", "p", { desc = "Paste" })
map({ "n" }, "C", "y$", { desc = "Yank to end of line" })
map({ "x" }, "C", "y", { desc = "Yank selection" })

-- Fold-aware yanking (visual mode only)
map("x", "cc", function()
  require("utils.fold-yank").yank_visible()
end, { desc = "Yank visible lines (exclude folded)" })
map({ "n", "x" }, "V", "P", { desc = "Paste before" })
map({ "v" }, "V", "P", { desc = "Paste without losing clipboard" })

-- Undo/redo (z for undo, Z for redo - Graphite layout)
-- Need to unmap built-in commands first
remap("n", "u", "<Nop>", { desc = "Unmapped (now z)" })
remap("n", "U", "<Nop>", { desc = "Unmapped (now gz)" })
remap("n", "z", "u", { desc = "Undo" })
remap("n", "Z", "<C-r>", { desc = "Redo" })
remap("n", "gz", "U", { desc = "Undo line" })
-- Change
map({ "n", "o", "x" }, "w", "c", { desc = "Change" })
map({ "n", "x" }, "W", "C", { desc = "Change to end of line" })

-- Visual mode
map({ "n", "x" }, "n", "v", { desc = "Visual mode" })
map({ "n", "x" }, "N", "V", { desc = "Visual line mode" })
-- Add Visual block mode
map({ "n" }, "<C-n>", "<C-v>", { desc = "Visual block mode" })

map({ "n", "o", "x" }, "m", "n", { desc = "Next search match" })
map({ "n", "o", "x" }, "M", "N", { desc = "Previous search match" })

-- <leader>gh moved to keymaps/diff.lua

-- Git conflict navigation (override LazyVim's LSP reference navigation)
remap("n", "[[", "[x", { desc = "Previous git conflict" })
remap("n", "]]", "]x", { desc = "Next git conflict" })
-- 'til
map({ "n", "o", "x" }, "k", "t", { desc = "Till before" })
map({ "n", "o", "x" }, "K", "T", { desc = "Till before backward" })

lil.map({
  [func] = which,
  ["<leader>cp"] = {
    P = desc("Copy file path (relative to cwd)", clipboard.copy_file_path),
    p = desc("Copy file path (from home)", clipboard.copy_file_path_from_home),
    c = desc("Copy file contents", clipboard.copy_file_contents),
    l = desc("Copy file path with line number", clipboard.copy_file_path_with_line),
  },
})

-- map(
--   "n",
--   "<leader>gnc",
--   require("neogit").action("commit", "commit", { "--verbose", "--all" }),
--   { desc = "commit in neogit" }
-- )

-- Force override any plugin mappings for Q
map("n", "Q", "@q", { desc = "replay the 'q' macro", silent = true, noremap = true })

-- Misc overridden keys must be prefixed with g
map({ "n", "x" }, "gX", "X", { desc = "Delete before cursor" })
map({ "n", "x" }, "gU", "U", { desc = "Uppercase" })
map({ "n", "x" }, "gQ", "Q", { desc = "Ex mode" })
map({ "n", "x" }, "gK", "K", { desc = "Lookup keyword" })
-- extra alias (now main since K is remapped)
map({ "n", "x" }, "gh", "K", { desc = "Lookup keyword" })

-- Disable spawning empty buffer when closing last buffer
vim.api.nvim_create_autocmd("User", {
  pattern = "BufferClose",
  callback = function()
    navigation.buffer_close_callback()
  end,
})

map(
  { "n" },
  "<C-h>",
  navigation.move_split("left", "move"),
  { noremap = true, desc = "Left window" }
)
map(
  { "n" },
  "<C-a>",
  navigation.move_split("down", "move"),
  { noremap = true, desc = "Window down" }
)
map({ "n" }, "<C-e>", navigation.move_split("up", "move"), { noremap = true, desc = "Window up" })
map(
  { "n" },
  "<C-i>",
  navigation.move_split("right", "move"),
  { noremap = true, desc = "Right window" }
)

map(
  { "n" },
  "<M-C-h>",
  navigation.move_split("left", "resize"),
  { noremap = true, desc = "Left window" }
)
map(
  { "n" },
  "<M-C-a>",
  navigation.move_split("down", "resize"),
  { noremap = true, desc = "Window down" }
)
map(
  { "n" },
  "<M-C-e>",
  navigation.move_split("up", "resize"),
  { noremap = true, desc = "Window up" }
)
map(
  { "n" },
  "<M-C-i>",
  navigation.move_split("right", "resize"),
  { noremap = true, desc = "Right window" }
)

-- Cycle through windows with Alt+Tab
-- map({ "n" }, "<M-Tab>", "<C-w>w", { desc = "Cycle windows" })

-- Buffer navigation - using Tab keys
map({ "n" }, "<C-p>", cmd("bprevious"), { desc = "Previous buffer" })
map({ "n" }, "<C-.>", cmd("bnext"), { desc = "Next buffer" })

-- Add some commonly used editor operations
map({ "n" }, "<leader>q", ":q<CR>", { desc = "Quit" })
map({ "n" }, "<leader>Q", ":qa<CR>", { desc = "Quit all" })
lil.map({
  [func] = which,
  ["<leader>r"] = {
    c = desc("Reload config", editor.reload_config),
    r = desc("Reload keymaps", editor.reload_keymaps),
    l = desc("Lazy sync plugins", cmd("Lazy sync")),
  },
})

map({ "n", "i", "v" }, "<F1>", "<nop>", { desc = "Disabled" })
map({ "n" }, "<F2>", "ggVG", { desc = "Select all" })

map({ "n", "o", "x" }, "<C-/>", function()
  Snacks.terminal()
end, { desc = "Toggle Terminal" })

-- Inline paste (avoids creating new lines)
map({ "n", "x" }, "-", editor.paste_inline, { desc = "Paste inline" })
-- Visual mode treesitter text objects (explicit mappings)
map({ "x", "o" }, "rf", function()
  require("nvim-treesitter.textobjects.select").select_textobject("@function.inner", "textobjects")
end, { desc = "Select inner function" })

map({ "x", "o" }, "tf", function()
  require("nvim-treesitter.textobjects.select").select_textobject("@function.outer", "textobjects")
end, { desc = "Select outer function" })

map({ "x", "o" }, "rc", function()
  require("nvim-treesitter.textobjects.select").select_textobject("@class.inner", "textobjects")
end, { desc = "Select inner class" })

map({ "x", "o" }, "tc", function()
  require("nvim-treesitter.textobjects.select").select_textobject("@class.outer", "textobjects")
end, { desc = "Select outer class" })

map({ "n", "o", "v" }, "r", "i", { desc = "O/V mode: inner (i)" })
map({ "n", "o", "v" }, "t", "a", { desc = "O/V mode: a/an (a)" })

-- Removed redundant visual surround mapping - handled by plugin config
map({ "o", "v" }, "X", "r", { desc = "Replace" })
map({ "o", "v" }, "rd", "iw", { desc = "Inner word" })
map({ "o", "v" }, "td", "aw", { desc = "Around word" })
map({ "o", "v" }, "rD", "iW", { desc = "Inner WORD" })
map({ "o", "v" }, "tD", "aW", { desc = "Around WORD" })
-- Operator-pending mode mappings to help with nvim-surround
-- These allow your r/t mappings to work in operator-pending mode
map({ "v" }, "rd", "iw", { desc = "Inner word (visual)" })
map({ "v" }, "td", "aw", { desc = "Around word (visual)" })
map({ "v" }, "rD", "iW", { desc = "Inner WORD (visual)" })
map({ "v" }, "tD", "aW", { desc = "Around WORD (visual)" })
-- rf and tf handled by treesitter-textobjects
map({ "o" }, "r(", "i(", { desc = "Inner parentheses (for nvim-surround)" })
map({ "o" }, "r)", "i)", { desc = "Inner parentheses (for nvim-surround)" })
map({ "o" }, "r[", "i[", { desc = "Inner brackets (for nvim-surround)" })
map({ "o" }, "r]", "i]", { desc = "Inner brackets (for nvim-surround)" })
map({ "o" }, "r{", "i{", { desc = "Inner braces (for nvim-surround)" })
map({ "o" }, "r}", "i}", { desc = "Inner braces (for nvim-surround)" })
map({ "o" }, 'r"', 'i"', { desc = "Inner quotes (for nvim-surround)" })
map({ "o" }, "r'", "i'", { desc = "Inner single quotes (for nvim-surround)" })
map({ "o" }, "t(", "a(", { desc = "Around parentheses (for nvim-surround)" })
map({ "o" }, "t)", "a)", { desc = "Around parentheses (for nvim-surround)" })
map({ "o" }, "t[", "a[", { desc = "Around brackets (for nvim-surround)" })
map({ "o" }, "t]", "a]", { desc = "Around brackets (for nvim-surround)" })
map({ "o" }, "t{", "a{", { desc = "Around braces (for nvim-surround)" })
map({ "o" }, "t}", "a}", { desc = "Around braces (for nvim-surround)" })
map({ "o" }, 't"', 'a"', { desc = "Around quotes (for nvim-surround)" })
map({ "o" }, "t'", "a'", { desc = "Around single quotes (for nvim-surround)" })

map({ "n", "o", "v" }, "te", function()
  require("nvim-treesitter.textobjects.select").select_textobject(
    "@jsx_self_closing_element",
    "textobjects"
  )
end, { desc = "Select JSX self-closing element" })

-- Treewalker keymaps (will override LazyVim defaults)
-- Movement keymaps using Ctrl+HAEI (Graphite layout) - "walk" with ctrl
-- vim.keymap.set(
--   { "n", "v" },
--   "<C-e>",
--   "<cmd>Treewalker Up<cr>",
--   { silent = true, desc = "Treewalker Up" }
-- )
-- vim.keymap.set(
--   { "n", "v" },
--   "<C-a>",
--   "<cmd>Treewalker Down<cr>",
--   { silent = true, desc = "Treewalker Down" }
-- )
-- vim.keymap.set(
--   { "n", "v" },
--   "<C-i>",
--   "<cmd>Treewalker Right<cr>",
--   { silent = true, desc = "Treewalker Right" }
-- )
-- -- Use C-h for parent (move left then parent)
-- vim.keymap.set("n", "<C-h>", function()
--   vim.cmd "normal! h"
--   vim.cmd "Treewalker Parent"
-- end, { desc = "Move left then Treewalker Parent", silent = true })
-- vim.keymap.set("v", "<C-h>", function()
--   vim.cmd "normal! h"
--   vim.cmd "Treewalker Parent"
-- end, { desc = "Move left then Treewalker Parent", silent = true })
--
-- Swapping keymaps using Alt+HAEI - "swap" with alt
vim.keymap.set(
  "n",
  "<M-e>",
  cmd("Treewalker SwapUp"),
  { silent = true, desc = "Treewalker SwapUp" }
)
vim.keymap.set(
  "n",
  "<M-a>",
  cmd("Treewalker SwapDown"),
  { silent = true, desc = "Treewalker SwapDown" }
)
vim.keymap.set(
  "n",
  "<M-h>",
  cmd("Treewalker SwapLeft"),
  { silent = true, desc = "Treewalker SwapLeft" }
)
vim.keymap.set(
  "n",
  "<M-i>",
  cmd("Treewalker SwapRight"),
  { silent = true, desc = "Treewalker SwapRight" }
)

lil.map({
  [func] = which,
  ["<leader>s"] = {
    D = desc("Project Diagnostics", cmd("ProjectDiagnostics")),
    r = desc("Search/Replace within range (Grug-far)", search.grug_far_range),
    F = desc("Search/Replace in current file (Grug-far)", search.grug_far_current_file),
    R = desc("Search/Replace in current directory (Grug-far)", search.grug_far_current_directory),
  },
})

-- Visual mode override for sF
map(
  "v",
  "<leader>sF",
  search.grug_far_selection_current_file,
  { desc = "Search/Replace selection in current file (Grug-far)" }
)

-- ============================================================================
-- OCTO KEYMAPS (GitHub operations)
-- ============================================================================

lil.map({
  [func] = which,
  ["<leader>o"] = {
    r = desc(octo.menu_items[1].desc, cmd(octo.menu_items[1].action)),
    p = desc(octo.menu_items[2].desc, cmd(octo.menu_items[2].action)),
    n = desc(octo.menu_items[3].desc, cmd(octo.menu_items[3].action)),
    I = desc(octo.menu_items[4].desc, cmd(octo.menu_items[4].action)),
    i = desc(octo.menu_items[5].desc, cmd(octo.menu_items[5].action)),
    P = desc(octo.menu_items[6].desc, cmd(octo.search_all_prs())),
    c = desc(octo.menu_items[7].desc, cmd(octo.menu_items[7].action)),
    C = desc(octo.menu_items[8].desc, cmd(octo.menu_items[8].action)),
    l = desc(octo.menu_items[9].desc, cmd(octo.menu_items[9].action)),
    s = desc(octo.menu_items[10].desc, cmd(octo.menu_items[10].action)),
    R = desc(octo.menu_items[11].desc, cmd(octo.menu_items[11].action)),
  },
})
