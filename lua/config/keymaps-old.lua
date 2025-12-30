-- Legacy keymaps - TODO: migrate these to map({}) style
-- These are older vim.keymap.set() style keymaps that should be refactored
-- to use the lil.nvim map({}) declarative style

local code = require("utils.code")
local editor = require("utils.editor")
local helpers = require("utils.helpers")
local kmu = require("keymap-utils")
local search = require("utils.search")

local cmd = kmu.cmd
local remap = kmu.remap

-- ============================================================================
-- GRAPHITE LAYOUT: Core Navigation (HAEI)
-- ============================================================================

kmu.safe_del({ "n", "x" }, "s")
-- Line operations and find
vim.keymap.set({ "n" }, "j", "o", { desc = "Open line below" })
vim.keymap.set({ "n" }, "J", "O", { desc = "Open line above" })

-- Beginning/end of line
vim.keymap.set({ "n", "o", "x" }, "0", "0", { desc = "Beginning of line" })
vim.keymap.set({ "n", "o", "x" }, "p", "^", { desc = "First non-blank character" })
vim.keymap.set({ "n", "o", "x" }, ".", "$", { desc = "End of line" })

-- Insert/append
vim.keymap.set({ "n" }, "r", "i", { desc = "Insert before cursor" })
vim.keymap.set({ "n" }, "R", "I", { desc = "Insert at start of line" })
vim.keymap.set({ "n" }, "t", "a", { desc = "Insert after cursor" })
vim.keymap.set({ "n" }, "T", "A", { desc = "Insert at end of line" })
vim.keymap.set({ "n" }, "b", "R", { desc = "Replace mode" })
vim.keymap.set({ "v" }, "B", "r", { desc = "Replace selected text" })

-- Jumplist navigation
vim.keymap.set({ "n" }, "o", "<C-o>", { desc = "Jumplist backward" })
vim.keymap.set({ "n" }, "O", "<C-i>", { desc = "Jumplist forward" })

-- PageUp/PageDown
-- vim.keymap.set({ "n", "x" }, "<C-.>", "<PageUp>", { desc = "Page Up" })
-- vim.keymap.set({ "n", "x" }, "<C-p>", "<PageDown>", { desc = "Page Down" })

-- Word left/right
vim.keymap.set({ "n", "o", "x" }, "l", "b", { desc = "Word back" })
vim.keymap.set({ "n", "o", "x" }, "d", "w", { desc = "Word forward" })
vim.keymap.set({ "n", "o", "x" }, "L", "B", { desc = "WORD back" })
vim.keymap.set({ "n", "o", "x" }, "D", "W", { desc = "WORD forward" })

-- Map semicolon to repeat last command (instead of dot)
vim.keymap.set({ "n" }, ";", ".", { desc = "Repeat last command" })
vim.keymap.set({ "n" }, "'", "gv", { desc = "Repeat last visual selection" })
vim.keymap.set({ "n", "o", "x" }, "%", "%", { desc = "Jump to matching bracket" })

-- Treewalker navigation
vim.keymap.set({ "n", "o", "x" }, "A", "<cmd>Treewalker Down<cr>", { desc = "Next code block" })
vim.keymap.set({ "n", "o", "x" }, "E", "<cmd>Treewalker Up<cr>", { desc = "Previous code block" })

-- End of word left/right
vim.keymap.set({ "n", "o", "x" }, "<M-h>", "gE", { desc = "End of WORD back" })
vim.keymap.set({ "n", "o", "x" }, "<M-o>", "E", { desc = "End of WORD forward" })

-- ============================================================================
-- FOLDS
-- ============================================================================

vim.keymap.set({ "n", "x" }, "fo", "zo", { desc = "Open fold (unfold)" })
vim.keymap.set({ "n", "x" }, "fu", "zc", { desc = "Close fold (fold one)" })
vim.keymap.set({ "n", "x" }, "ff", "zM", { desc = "Close all folds (fold all)" })
vim.keymap.set({ "n", "x" }, "fF", "zR", { desc = "Open all folds (unfold all)" })
vim.keymap.set({ "n", "x" }, "fe", "zk", { desc = "Move up to fold" })
vim.keymap.set({ "n", "x" }, "fa", "zj", { desc = "Move down to fold" })
vim.keymap.set({ "n", "x" }, "bb", "zb", { desc = "Scroll line and cursor to bottom" })

-- ============================================================================
-- COPY/PASTE/YANK
-- ============================================================================

vim.keymap.set({ "n", "o", "x" }, "c", "y", { desc = "Yank (copy)" })
vim.keymap.set({ "n", "x" }, "v", "p", { desc = "Paste" })
vim.keymap.set({ "n" }, "C", "y$", { desc = "Yank to end of line" })
vim.keymap.set({ "x" }, "C", "y", { desc = "Yank selection" })
-- vim.keymap.set("x", "cc", helpers.yank_visible, { desc = "Yank visible lines (exclude folded)" })
vim.keymap.set({ "n", "x" }, "V", "P", { desc = "Paste before" })
vim.keymap.set({ "v" }, "V", "P", { desc = "Paste without losing clipboard" })

-- ============================================================================
-- UNDO/REDO
-- ============================================================================

remap("n", "u", "<Nop>", { desc = "Unmapped (now z)" })
remap("n", "U", "<Nop>", { desc = "Unmapped (now gz)" })
remap("n", "z", "u", { desc = "Undo" })
remap("n", "Z", "<C-r>", { desc = "Redo" })
remap("n", "gz", "U", { desc = "Undo line" })

-- ============================================================================
-- CHANGE
-- ============================================================================

vim.keymap.set({ "n", "x" }, "w", "c", { desc = "Change" })
vim.keymap.set({ "n", "x" }, "W", "C", { desc = "Change to end of line" })

-- ============================================================================
-- VISUAL MODE
-- ============================================================================

vim.keymap.set({ "n", "x" }, "n", "v", { desc = "Visual mode" })
vim.keymap.set({ "n", "x" }, "N", "V", { desc = "Visual line mode" })
vim.keymap.set({ "n" }, "<C-n>", "<C-v>", { desc = "Visual block mode" })

-- ============================================================================
-- SEARCH
-- ============================================================================

vim.keymap.set({ "n", "o", "x" }, "m", "n", { desc = "Next search match" })
vim.keymap.set({ "n", "o", "x" }, "M", "N", { desc = "Previous search match" })

-- Git conflict navigation
remap("n", "[[", "[x", { desc = "Previous git conflict" })
remap("n", "]]", "]x", { desc = "Next git conflict" })

-- ============================================================================
-- TILL/FIND
-- ============================================================================

vim.keymap.set({ "n", "o", "x" }, "k", "t", { desc = "Till before" })
vim.keymap.set({ "n", "o", "x" }, "K", "T", { desc = "Till before backward" })

-- ============================================================================
-- MACROS
-- ============================================================================

vim.keymap.set("n", "Q", "@q", { desc = "replay the 'q' macro", silent = true, noremap = true })

-- ============================================================================
-- MISC OVERRIDES (prefixed with g)
-- ============================================================================

vim.keymap.set({ "n", "x" }, "gX", "X", { desc = "Delete before cursor" })
vim.keymap.set({ "n", "x" }, "gU", "U", { desc = "Uppercase" })
vim.keymap.set({ "n", "x" }, "gQ", "Q", { desc = "Ex mode" })
vim.keymap.set({ "n", "x" }, "gK", "K", { desc = "Lookup keyword" })
vim.keymap.set({ "n", "x" }, "gh", "K", { desc = "Lookup keyword" })

-- ============================================================================
-- AUTOCMDS
-- ============================================================================

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

-- ============================================================================
-- SMART-SPLITS WINDOW NAVIGATION
-- ============================================================================

vim.keymap.set({ "n" }, "<C-h>", function()
  require("smart-splits").move_cursor_left({ same_row = false, at_edge = "stop" })
end, { noremap = true, desc = "Left window" })
vim.keymap.set({ "n" }, "<C-a>", function()
  require("smart-splits").move_cursor_down({ same_row = false, at_edge = "stop" })
end, { noremap = true, desc = "Window down" })
vim.keymap.set({ "n" }, "<C-e>", function()
  require("smart-splits").move_cursor_up({ same_row = false, at_edge = "stop" })
end, { noremap = true, desc = "Window up" })
vim.keymap.set({ "n" }, "<C-i>", function()
  require("smart-splits").move_cursor_right({ same_row = false, at_edge = "stop" })
end, { noremap = true, desc = "Right window" })

vim.keymap.set({ "n" }, "<M-C-h>", function()
  require("smart-splits").resize_left(5)
end, { noremap = true, desc = "Left window" })
vim.keymap.set({ "n" }, "<M-C-a>", function()
  require("smart-splits").resize_down(5)
end, { noremap = true, desc = "Window down" })
vim.keymap.set({ "n" }, "<M-C-e>", function()
  require("smart-splits").resize_up(5)
end, { noremap = true, desc = "Window up" })
vim.keymap.set({ "n" }, "<M-C-i>", function()
  require("smart-splits").resize_right(5)
end, { noremap = true, desc = "Right window" })

-- ============================================================================
-- FUNCTION KEYS
-- ============================================================================

vim.keymap.set({ "n", "i", "v" }, "<F1>", "<nop>", { desc = "Disabled" })
vim.keymap.set({ "n" }, "<F2>", "ggVG", { desc = "Select all" })

-- ============================================================================
-- TERMINAL
-- ============================================================================

-- vim.keymap.set({ "n", "o", "x" }, "<C-/>", helpers.toggle_terminal, { desc = "Toggle Terminal" })

-- ============================================================================
-- PASTE INLINE
-- ============================================================================

vim.keymap.set({ "n", "x" }, "-", editor.paste_inline, { desc = "Paste inline" })

-- ============================================================================
-- TEXT OBJECTS
-- ============================================================================

-- vim.keymap.set(
--   { "x", "o" },
--   "rf",
--   helpers.select_inner_function,
--   { desc = "Select inner function" }
-- )
-- vim.keymap.set(
--   { "x", "o" },
--   "tf",
--   helpers.select_outer_function,
--   { desc = "Select outer function" }
-- )

vim.keymap.set({ "n", "o", "v" }, "r", "i", { desc = "O/V mode: inner (i)" })
vim.keymap.set({ "n", "o", "v" }, "t", "a", { desc = "O/V mode: a/an (a)" })

vim.keymap.set({ "o", "v" }, "X", "r", { desc = "Replace" })
vim.keymap.set({ "o", "v" }, "rd", "iw", { desc = "Inner word" })
vim.keymap.set({ "o", "v" }, "td", "aw", { desc = "Around word" })
vim.keymap.set({ "o", "v" }, "rD", "iW", { desc = "Inner WORD" })
vim.keymap.set({ "o", "v" }, "tD", "aW", { desc = "Around WORD" })
vim.keymap.set({ "v" }, "rd", "iw", { desc = "Inner word (visual)" })
vim.keymap.set({ "v" }, "td", "aw", { desc = "Around word (visual)" })
vim.keymap.set({ "v" }, "rD", "iW", { desc = "Inner WORD (visual)" })
vim.keymap.set({ "v" }, "tD", "aW", { desc = "Around WORD (visual)" })

-- ============================================================================
-- TREEWALKER SWAP
-- ============================================================================
--
-- vim.keymap.set(
--   "n",
--   "<M-e>",
--   cmd("Treewalker SwapUp"),
--   { silent = true, desc = "Treewalker SwapUp" }
-- )
-- vim.keymap.set(
--   "n",
--   "<M-a>",
--   cmd("Treewalker SwapDown"),
--   { silent = true, desc = "Treewalker SwapDown" }
-- )
-- vim.keymap.set(
--   "n",
--   "<M-h>",
--   cmd("Treewalker SwapLeft"),
--   { silent = true, desc = "Treewalker SwapLeft" }
-- )
-- vim.keymap.set(
--   "n",
--   "<M-i>",
--   cmd("Treewalker SwapRight"),
--   { silent = true, desc = "Treewalker SwapRight" }
-- )

-- ============================================================================
-- GRUG-FAR VISUAL MODE
-- ============================================================================

vim.keymap.set(
  "v",
  "<leader>sF",
  search.grug_far_selection_current_file,
  { desc = "Search/Replace selection in current file (Grug-far)" }
)
