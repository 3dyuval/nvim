-- Import utility modules
local cli = require("utils.cli")
local clipboard = require("utils.clipboard")
local code = require("utils.code")
local editor = require("utils.editor")
local files = require("utils.files")
local git = require("utils.git")
local helpers = require("utils.helpers")
local history = require("utils.history")
local kmu = require("keymap-utils")
local search = require("utils.search")
local smart_diff = require("utils.smart-diff")

-- lil.nvim setup
local lil = require("lil")
local func = lil.flags.func
local opts = lil.flags.opts
local mode = lil.flags.mode
local x = lil.mod("x")
local n = lil.mod("n")

-- Use keymap-utils as unified toolkit
local map = kmu.map
local cmd = kmu.cmd
local remap = kmu.remap
local func_map = kmu.func_map
local safe_del = kmu.safe_del

-- Legacy lil.nvim compatibility (until full migration)
local function desc(d, value, expr)
  -- Simple desc function that works with lil.nvim structure
  return {
    value,
    [func] = func_map,
    [opts] = { desc = d, expr = expr },
  }
end

pcall(vim.keymap.del, "n", "<leader>gd")

-- Disable LazyVim default keymaps
pcall(vim.keymap.del, "n", "<leader> ")
pcall(vim.keymap.del, "n", "<leader><space>")

lil.map({
  [func] = func_map,
  -- Smart context-aware diff operations (lowercase)
  g = {
    o = desc("Get hunk (smart)", smart_diff.smart_diffget),
    p = desc("Put hunk (smart)", smart_diff.smart_diffput),
    i = desc("Go to top", "gg"),
    h = desc("Go to bottom", "G"),
  },
  ["<leader>g"] = {
    -- Vim diff operations

    -- Git conflict resolution (uppercase - file-level operations)
    P = desc("Resolve file: ours", smart_diff.smart_resolve_ours),
    O = desc("Resolve file: theirs", smart_diff.smart_resolve_theirs),
    U = desc("Resolve file: union (both)", smart_diff.smart_resolve_union),
    R = desc("Restore conflict markers", smart_diff.smart_restore_conflicts),

    -- Neogit and diffview commands
    n = desc("Neogit in current dir", cmd(":Neogit cwd=%:p:h")),
    c = desc("Neogit commit", cmd(":Neogit commit")),
    d = desc("Diff view open", cmd("DiffviewOpen")),
    S = desc("Diff view stash", cmd("DiffviewFileHistory -g --range=stash")),
    h = desc("Current file history", ":DiffviewFileHistory %"),
    D = desc("Compare current file with branch", helpers.compare_current_file_with_branch),
    f = desc("Compare current file with file", helpers.compare_current_file_with_file),

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
-- COPY FILE TO CLIPBOARD
-- ============================================================================

lil.map({
  [func] = func_map,
  ["<leader>p"] = {
    P = desc("Copy file path (relative to cwd)", clipboard.copy_file_path),
    p = desc("Copy file path (from home)", clipboard.copy_file_path_from_home),
    a = desc("Copy text directy to Claude Code", function()
      local text_in_selction = range.text()
      os.execute("kitten @ send-text --match 'CLD=1' " .. text_in_selction)
    end),
    c = desc("Copy file contents", clipboard.copy_file_contents),
    w = desc("Open file in web browser", cmd("OpenFileInRepo")),
    l = desc("Copy file path to clipboard", clipboard.copy_file_path_with_line),
    L = desc("Copy file URL with line to clipboard", cmd("YankLineUrl +")),
  },
})

-- ============================================================================
-- CODE OPERATIONS (from keymaps/g.lua and keymaps/c.lua)
-- ============================================================================

lil.map({
  [func] = func_map,
  g = {
    D = desc("Go to source definition", code.go_to_source_definition),
    R = desc("File references", code.file_references),
  },
})

lil.map({
  [func] = func_map,
  ["<leader>c"] = {
    -- TypeScript/Import operations
    o = desc("Organize + Remove Unused Imports", code.organize_imports),
    O = desc("Organize Imports + Fix All Diagnostics", code.organize_imports_and_fix),
    I = desc("Add missing imports", code.add_missing_imports),
    u = desc("Remove unused imports", code.remove_unused_imports),
    F = desc("Fix all diagnostics", code.fix_all),
    V = desc("Select TS workspace version", code.select_ts_version),
    t = desc("TypeScript type check", editor.typescript_check),

    -- AI/Claude Code operations
    -- C = desc("Claude Code", cmd("ClaudeCode")),
    -- B = desc("Claude Code (verbose)", cmd("ClaudeCodeVerbose")),
  },
})

-- ============================================================================
-- FILE OPERATIONS (from keymaps/f.lua)
-- ============================================================================

lil.map({
  [func] = func_map,
  ["<leader>f"] = {
    f = desc("Find files (snacks + fff)", files.find_files_snacks),
    s = desc("Save file", files.save_file),
    S = desc("Save and stage file", files.save_and_stage_file),
  },
})

-- ============================================================================
-- HISTORY OPERATIONS (from keymaps/h.lua)
-- ============================================================================

local map = vim.keymap.set

lil.map({
  [func] = func_map,
  ["<leader>h"] = {
    h = desc("Local file history", history.local_file_history),
    H = desc("All files in backup", history.all_files_in_backup),
    F = desc("Firefox bookmarks", history.firefox_bookmarks_picker),
    f = desc("Firefox bookmarks", history.firefox_search),
    s = desc("Smart history picker", history.smart_file_history),
    l = desc("Git log", history.git_log_picker),
    u = desc("View undo list", cmd("undolist")),
    T = desc("Manual backup with tag", history.manual_backup_with_tag),
    p = desc("Project files history", history.project_files_history),
  },
})

lil.map({
  [func] = func_map,
  x = {
    x = desc("Delete line", "dd"), -- xx → dd
  },
  [x] = {
    x = desc("Delete", "d"), -- Visual mode x → d
  },
})

-- Handle count-aware 'x' separately (needs different logic than nested xx)
remap({ "n" }, "x", helpers.count_aware_delete, { desc = "Delete", expr = true })

lil.map({
  [func] = func_map,
  [mode] = { "n", "o", "x" },
  h = desc("Left", "h"),
  e = desc("Up", "k"),
  a = desc("Down", "j"),
  i = desc("Right", "l"),
  p = desc("First non-blank character", "^"),
  ["0"] = desc("Beginning of line", "0"),
  ["."] = desc("End of line", "$"),
})

-- map({ "n", "o", "x" }, "h", "h", { desc = "Left (h)" })
-- map({ "n", "o", "x" }, "e", "k", { desc = "Up (k)" })
-- map({ "n", "o", "x" }, "a", "j", { desc = "Down (j)" })
-- map({ "n", "o", "x" }, "i", "l", { desc = "Right (l)" })

-- E/A moved to smart context-aware functions below (lines 124-125)

-- Override HAEI navigation in visual modes (including visual line mode)
-- Use noremap to fully override default vim behavior including text objects
-- map("x", "e", "k", { noremap = true, desc = "Up in visual modes" })
-- map("x", "a", "j", { noremap = true, desc = "Down in visual modes" })
-- map("x", "h", "h", { noremap = true, desc = "Left in visual modes" })
-- map("x", "i", "l", { noremap = true, desc = "Right in visual modes" })

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
map({ "n" }, "b", "R", { desc = "Replace mode" })
-- Keep visual replace on a different key
map({ "v" }, "B", "r", { desc = "Replace selected text" })
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

-- Smooth scrolling (Graphite layout) - works with snacks.scroll
lil.map({
  [func] = func_map,
  [mode] = { "n", "v", "x" },
  ga = desc("Scroll down (Graphite)", "<C-d>zz"),
  ge = desc("Scroll up (Graphite)", "<C-u>zz"),
  gs = desc("Center screen (Graphite)", "zz"),
})

-- End of word left/right (moved to different keys)
-- map({ "n", "o", "x" }, "gh", "ge", { desc = "End of word back" })
map({ "n", "o", "x" }, "<M-h>", "gE", { desc = "End of WORD back" })
map({ "n", "o", "x" }, "<M-o>", "E", { desc = "End of WORD forward" })

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
map("x", "cc", helpers.yank_visible, { desc = "Yank visible lines (exclude folded)" })
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

-- Git conflict navigation (override LazyVim's LSP reference navigation)
remap("n", "[[", "[x", { desc = "Previous git conflict" })
remap("n", "]]", "]x", { desc = "Next git conflict" })
-- 'til (changed to y/Y to free up k for surround)
map({ "n", "o", "x" }, "y", "t", { desc = "Till before" })
map({ "n", "o", "x" }, "Y", "T", { desc = "Till before backward" })

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
    local bufs = vim.tbl_filter(function(b)
      return vim.api.nvim_buf_is_loaded(b) and vim.bo[b].buflisted
    end, vim.api.nvim_list_bufs())
    if #bufs == 0 then
      vim.schedule(function()
        require("snacks").dashboard()
      end)
    end
  end,
})

map(
  { "n" },
  "<C-h>",
  function()
    require("smart-splits").move_cursor_left({ same_row = false, at_edge = "stop" })
  end,
  { noremap = true, desc = "Left window" }
)
map(
  { "n" },
  "<C-a>",
  function()
    require("smart-splits").move_cursor_down({ same_row = false, at_edge = "stop" })
  end,
  { noremap = true, desc = "Window down" }
)
map(
  { "n" },
  "<C-e>",
  function()
    require("smart-splits").move_cursor_up({ same_row = false, at_edge = "stop" })
  end,
  { noremap = true, desc = "Window up" }
)
map(
  { "n" },
  "<C-i>",
  function()
    require("smart-splits").move_cursor_right({ same_row = false, at_edge = "stop" })
  end,
  { noremap = true, desc = "Right window" }
)

map(
  { "n" },
  "<M-C-h>",
  function()
    require("smart-splits").resize_left(5)
  end,
  { noremap = true, desc = "Left window" }
)
map(
  { "n" },
  "<M-C-a>",
  function()
    require("smart-splits").resize_down(5)
  end,
  { noremap = true, desc = "Window down" }
)
map(
  { "n" },
  "<M-C-e>",
  function()
    require("smart-splits").resize_up(5)
  end,
  { noremap = true, desc = "Window up" }
)
map(
  { "n" },
  "<M-C-i>",
  function()
    require("smart-splits").resize_right(5)
  end,
  { noremap = true, desc = "Right window" }
)

-- Cycle through windows with Alt+Tab
-- map({ "n" }, "<M-Tab>", "<C-w>w", { desc = "Cycle windows" })

-- Buffer navigation - using Tab keys
map({ "n" }, "<C-p>", cmd("bprevious"), { desc = "Previous buffer" })
map({ "n" }, "<C-.>", cmd("bnext"), { desc = "Next buffer" })

lil.map({
  [func] = func_map,
  ["<leader>r"] = {
    c = desc("Reload config", editor.reload_config),
    r = desc("Reload keymaps", editor.reload_keymaps),
    l = desc("Lazy sync plugins", cmd("Lazy sync")),
  },
})

map({ "n", "i", "v" }, "<F1>", "<nop>", { desc = "Disabled" })
map({ "n" }, "<F2>", "ggVG", { desc = "Select all" })

-- TODO find a keymap closer to v, use - for something like repeat?
map({ "n", "o", "x" }, "<C-/>", helpers.toggle_terminal, { desc = "Toggle Terminal" })

-- Inline paste (avoids creating new lines)
map({ "n", "x" }, "-", editor.paste_inline, { desc = "Paste inline" })
-- Visual mode treesitter text objects (explicit mappings)
map({ "x", "o" }, "rf", helpers.select_inner_function, { desc = "Select inner function" })
map({ "x", "o" }, "tf", helpers.select_outer_function, { desc = "Select outer function" })

map({ "n", "o", "v" }, "r", "i", { desc = "O/V mode: inner (i)" })
map({ "n", "o", "v" }, "t", "a", { desc = "O/V mode: a/an (a)" })

-- Removed redundant visual surround mapping - handled by plugin config
map({ "o", "v" }, "X", "r", { desc = "Replace" })
map({ "o", "v" }, "rd", "iw", { desc = "Inner word" })
map({ "o", "v" }, "td", "aw", { desc = "Around word" })
map({ "o", "v" }, "rD", "iW", { desc = "Inner WORD" })
map({ "o", "v" }, "tD", "aW", { desc = "Around WORD" })
-- Operator-pending mode mappings to help with nvim-surround
-- These translate Graphite layout (r=inner, t=around) to nvim-surround defaults (i=inner, a=around)
-- Configuration layer: ~/.config/nvim/lua/utils/surround.lua defines the actual surround behaviors
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

map(
  { "n", "o", "v" },
  "te",
  helpers.select_jsx_self_closing_element,
  { desc = "Select JSX self-closing element" }
)

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
  [func] = func_map,
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
-- DATABASE KEYMAPS (vim-dadbod operations)
-- ============================================================================

lil.map({
  [func] = func_map,
  ["<leader>db"] = {
    u = desc("Toggle DBUI", cmd("DBUIToggle")),
    f = desc("Find buffer", cmd("DBUIFindBuffer")),
    r = desc("Rename buffer", cmd("DBUIRenameTab")),
    q = desc("Last query info", cmd("DBUILastQueryInfo")),
  },
})

-- ============================================================================
-- OCTO KEYMAPS (GitHub operations - following gh-alias structure)
-- ============================================================================

lil.map({
  [func] = func_map,
  ["<leader>o"] = {
    r = {
      w = desc("Browse repo", cmd("Octo repo browser")),
      i = desc("My repositories", cmd("Octo repo list")),
      l = desc("Copy url", cmd("Octo repo url")),
    },
    -- First level: category selection
    i = {
      -- Issues submenu
      v = desc("View issue", cmd("Octo issue edit ", false)),
      c = desc("Create issue", cmd("Octo issue create")),
      x = desc("Close issue", cmd("Octo issue close")),
      b = desc("List issues by author", cmd("Octo issue search state:open author:", false)),
      l = desc("List issues", cmd("Octo issue list")),
      i = desc("My issues", cmd("Octo issue search state:open involves:@me")),
      w = desc("My issues", cmd("Octo issue browser")),
    },
    p = {
      -- Pull Requests submenu
      v = desc("View PR", cmd("Octo pr ", false)),
      c = desc("Create PR", cmd("Octo pr create")),
      l = desc("List PRs", cmd("Octo pr list")),
      s = desc("Search PRs", cmd("Octo pr search")),
      r = desc("Start review", cmd("Octo review start")),
      R = desc("Resume review", cmd("Octo review resume")),
    },
    -- Direct actions (no submenu)
    n = desc("Notifications", cmd("Octo notifications")),
  },
})

-- ============================================================================
-- TODO/CHECKMATE KEYMAPS
-- ============================================================================

lil.map({
  [func] = func_map,
  ["<leader>t"] = {
    -- Core todo operations (following snacks explorer pattern)
    r = desc("Todo: Create new", cmd("Checkmate create")),
    n = desc("Todo: Toggle state", cmd("Checkmate toggle")),
    c = desc("Todo: Check (mark done)", cmd("Checkmate check")),
    u = desc("Todo: Uncheck", cmd("Checkmate uncheck")),
    a = desc("Todo: Archive completed", cmd("Checkmate archive")),

    -- Cycle through states
    ["="] = desc("Todo: Next state", cmd("Checkmate cycle_next")),
    ["-"] = desc("Todo: Previous state", cmd("Checkmate cycle_previous")),

    -- Linting
    l = desc("Todo: Lint buffer", cmd("Checkmate lint")),

    -- Metadata navigation
    ["]"] = desc("Todo: Jump to next metadata", cmd("Checkmate metadata jump_next")),
    ["["] = desc("Todo: Jump to previous metadata", cmd("Checkmate metadata jump_previous")),
    v = desc("Todo: Select metadata value", cmd("Checkmate metadata select_value")),

    -- Nested metadata operations under 't' (consistent with top-level pattern)
    t = {
      -- Create/add metadata (r pattern)
      r = {
        s = desc("Todo Metadata: Add @started", cmd("Checkmate metadata add started")),
        d = desc("Todo Metadata: Add @done", cmd("Checkmate metadata add done")),
        p = desc("Todo Metadata: Add @priority", cmd("Checkmate metadata add priority")),
      },

      -- Toggle/cycle metadata (n pattern)
      n = {
        s = desc("Todo Metadata: Toggle @started", cmd("Checkmate metadata toggle started")),
        d = desc("Todo Metadata: Toggle @done", cmd("Checkmate metadata toggle done")),
        p = desc("Todo Metadata: Toggle @priority", cmd("Checkmate metadata toggle priority")),
      },

      -- Remove operations (x pattern for delete)
      x = {
        a = desc("Todo Metadata: Remove all", cmd("Checkmate remove_all_metadata")),
        s = desc("Todo Metadata: Remove @started", cmd("Checkmate metadata remove started")),
        d = desc("Todo Metadata: Remove @done", cmd("Checkmate metadata remove done")),
        p = desc("Todo Metadata: Remove @priority", cmd("Checkmate metadata remove priority")),
      },

      -- Direct shortcuts for common metadata
      s = desc("Todo Metadata: Add @started", cmd("Checkmate metadata add started")),
      d = desc("Todo Metadata: Add @done", cmd("Checkmate metadata add done")),
      p = desc("Todo Metadata: Add @priority", cmd("Checkmate metadata add priority")),
    },
  },
})

-- ============================================================================
-- NOTES MANAGEMENT (Marksman + obsidian.nvim)
-- ============================================================================

local notes = require("utils.notes")

lil.map({
  [func] = func_map,
  ["<leader>n"] = {
    -- Note creation
    n = desc("New note", cmd("ObsidianNew")),
    t = desc("Today's note", cmd("ObsidianToday")),
    y = desc("Yesterday's note", cmd("ObsidianYesterday")),
    T = desc("Tomorrow's note", cmd("ObsidianTomorrow")),

    -- Search and navigation
    s = desc("Search notes", cmd("ObsidianSearch")),
    f = desc("Find note", cmd("ObsidianQuickSwitch")),
    b = desc("Backlinks", cmd("ObsidianBacklinks")),
    l = desc("Links in note", cmd("ObsidianLinks")),
    g = desc("Search tags", cmd("ObsidianTags")),

    -- Templates (nested under 't')
    te = desc("Insert template", cmd("ObsidianTemplate")),
    to = desc("Table of contents", cmd("ObsidianTOC")),

    -- Management
    r = desc("Rename note", cmd("ObsidianRename")),
    p = desc("Paste image", cmd("ObsidianPasteImg")),
    o = desc("Open in Obsidian app", cmd("ObsidianOpen")),
    w = desc("Switch workspace", cmd("ObsidianWorkspace")),
    d = desc("Open notes directory", notes.open_notes_directory),

    -- Visual mode link operations
    L = { [x] = desc("Link to new note", cmd("ObsidianLinkNew")) },
    k = { [x] = desc("Link to existing note", cmd("ObsidianLink")) },
  },
  -- Smart gf - follow link or file
  gf = desc("Follow link or file", notes.smart_follow_link, true), -- expr = true
  -- Quick inbox note creation
  ["<leader>N"] = desc("New note in inbox", notes.create_inbox_note),
})
