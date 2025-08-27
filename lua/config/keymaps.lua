pcall(vim.keymap.del, "n", "<leader>gd")
require("keymaps.f")
require("keymaps.diff")
local history_extern = require("keymaps.h")
require("keymaps.g")
require("keymaps.c")
local map = vim.keymap.set
local remap = require("keymaps.maps").remap

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

-- Lazygit
map({ "n" }, "<leader>gz", function()
  Snacks.lazygit()
end, { desc = "Lazygit (Root Dir)" })
map({ "n" }, "<leader>gZ", function()
  Snacks.lazygit({ cwd = LazyVim.root.get() })
end, { desc = "Lazygit (cwd)" })

-- Git branches picker
map({ "n" }, "<leader>gb", function()
  Snacks.picker.git_branches({ all = true })
end, { desc = "Git branches (all)" })

-- History keymap root

map({ "n" }, "<leader>hu", "<Cmd>undolist<Cr>", { desc = "View undo list" })

-- Git conflict navigation (override LazyVim's LSP reference navigation)
remap("n", "[[", "[x", { desc = "Previous git conflict" })
remap("n", "]]", "]x", { desc = "Next git conflict" })

-- Git conflict resolution keymaps
map({ "n" }, "go", "<Cmd>GitConflictChooseTheirs<Cr>", { desc = "Choose theirs (git conflict)" })
map({ "n" }, "gp", "<Cmd>GitConflictChooseOurs<Cr>", { desc = "Choose ours (git conflict)" })
map({ "n" }, "gu", "<Cmd>GitConflictChooseBoth<Cr>", { desc = "Choose both (git conflict)" })

-- <leader>gR moved to keymaps/diff.lua

map({ "n" }, "<leader>hB", function()
  Snacks.picker.firefox_bookmarks()
end, { desc = "Firefox bookmarks" })

-- <leader>hf moved to keymaps/history.lua

-- File history keymaps (main keymaps are in plugin config file)
-- Additional keymaps that extend the plugin functionality
map({ "n" }, "<leader>hA", function()
  require("file_history").query()
end, { desc = "Query file history by time range" })

map({ "n" }, "<leader>hT", function()
  require("file_history").backup()
end, { desc = "Manual backup with tag" })

map({ "n" }, "<leader>hp", function()
  require("file_history").project_files()
end, { desc = "Project files history" })
-- 'til
map({ "n", "o", "x" }, "k", "t", { desc = "Till before" })
map({ "n", "o", "x" }, "K", "T", { desc = "Till before backward" })

map({ "n" }, "<leader>cpp", function()
  local file_path = vim.fn.fnamemodify(vim.fn.expand("%"), ":.")
  vim.fn.setreg("+", file_path)
  vim.notify("Copied path: " .. file_path)
end, { desc = "Copy file path (relative to cwd)" })

map({ "n" }, "<leader>cpc", function()
  local file_path = vim.fn.expand("%:p")
  if vim.fn.filereadable(file_path) == 0 then
    vim.notify("File not readable: " .. file_path, vim.log.levels.ERROR)
    return
  end
  local content = vim.fn.readfile(file_path)
  local content_str = table.concat(content, "\n")
  vim.fn.setreg("+", content_str)
  vim.notify("Copied file contents (" .. #content .. " lines)")
end, { desc = "Copy file contents" })

map({ "n" }, "<leader>cpl", function()
  local file_path = vim.fn.expand("%:p")
  local line_number = vim.fn.line(".")
  local path_with_line = file_path .. ":" .. line_number
  vim.fn.setreg("+", path_with_line)
  vim.notify("Copied: " .. path_with_line)
end, { desc = "Copy file path with line number" })

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
    local bufs = vim.tbl_filter(function(buf)
      return vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted
    end, vim.api.nvim_list_bufs())

    if #bufs == 0 then
      vim.schedule(function()
        require("snacks").dashboard()
      end)
    end
  end,
})

--- Helper to produce a lambda for smart-splits movement with default opts
---@param dir "left"|"down"|"up"|"right"
---@para op "move" | "resize"
local function move_split(dir, op)
  return function()
    if op == "move" then
      -- Check if we're currently in a snacks explorer buffer
      local buf_name = vim.api.nvim_buf_get_name(0)
      local is_snacks_explorer = buf_name:match("snacks://") or vim.bo.filetype == "snacks_picker"

      require("smart-splits")["move_cursor_" .. dir]({
        same_row = false,
        at_edge = "stop",
      })
    end
    if op == "resize" then
      require("smart-splits")["resize_" .. dir](5)
    end
  end
end

map({ "n" }, "<C-h>", move_split("left", "move"), { noremap = true, desc = "Left window" })
map({ "n" }, "<C-a>", move_split("down", "move"), { noremap = true, desc = "Window down" })
map({ "n" }, "<C-e>", move_split("up", "move"), { noremap = true, desc = "Window up" })
map({ "n" }, "<C-i>", move_split("right", "move"), { noremap = true, desc = "Right window" })

map({ "n" }, "<M-C-h>", move_split("left", "resize"), { noremap = true, desc = "Left window" })
map({ "n" }, "<M-C-a>", move_split("down", "resize"), { noremap = true, desc = "Window down" })
map({ "n" }, "<M-C-e>", move_split("up", "resize"), { noremap = true, desc = "Window up" })
map({ "n" }, "<M-C-i>", move_split("right", "resize"), { noremap = true, desc = "Right window" })

-- Cycle through windows with Alt+Tab
-- map({ "n" }, "<M-Tab>", "<C-w>w", { desc = "Cycle windows" })

-- Buffer navigation - using Tab keys
map({ "n" }, "<C-p>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map({ "n" }, "<C-.>", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- Add some commonly used editor operations
map({ "n" }, "<leader>q", ":q<CR>", { desc = "Quit" })
map({ "n" }, "<leader>Q", ":qa<CR>", { desc = "Quit all" })
map({ "n" }, "<leader>rc", function()
  vim.cmd(":source $MYVIMRC")
  vim.notify("Config reloaded")
end, { desc = "Reload config" })

map({ "n" }, "<leader>rr", function()
  vim.cmd("source " .. vim.fn.stdpath("config") .. "/lua/config/keymaps.lua")
  vim.notify("keymaps reloaded")
end, { desc = "Reload keymaps" })

map({ "n" }, "<leader>rl", "<cmd>Lazy sync<cr>", { desc = "Lazy sync plugins" })
map({ "n" }, "<leader>ct", function()
  vim.cmd("split | terminal tsc --noEmit")
end, { desc = "TypeScript type check" })

map({ "n", "i", "v" }, "<F1>", "<nop>", { desc = "Disabled" })
map({ "n" }, "<F2>", "ggVG", { desc = "Select all" })

map({ "n", "o", "x" }, "<C-/>", function()
  Snacks.terminal()
end, { desc = "Toggle Terminal" })

-- Inline paste (avoids creating new lines)
local function paste_inline()
  local reg_type = vim.fn.getregtype('"')
  if reg_type == "V" then -- line-wise register
    vim.cmd("normal! gp")
  else
    vim.cmd("normal! p")
  end
end

map({ "n", "x" }, "-", paste_inline, { desc = "Paste inline" })
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
--   vim.cmd("normal! h")
--   vim.cmd("Treewalker Parent")
-- end, { desc = "Move left then Treewalker Parent", silent = true })
-- vim.keymap.set("v", "<C-h>", function()
--   vim.cmd("normal! h")
--   vim.cmd("Treewalker Parent")
-- end, { desc = "Move left then Treewalker Parent", silent = true })
--
-- Swapping keymaps using Alt+HAEI - "swap" with alt
vim.keymap.set(
  "n",
  "<M-e>",
  "<cmd>Treewalker SwapUp<cr>",
  { silent = true, desc = "Treewalker SwapUp" }
)
vim.keymap.set(
  "n",
  "<M-a>",
  "<cmd>Treewalker SwapDown<cr>",
  { silent = true, desc = "Treewalker SwapDown" }
)
vim.keymap.set(
  "n",
  "<M-h>",
  "<cmd>Treewalker SwapLeft<cr>",
  { silent = true, desc = "Treewalker SwapLeft" }
)
vim.keymap.set(
  "n",
  "<M-i>",
  "<cmd>Treewalker SwapRight<cr>",
  { silent = true, desc = "Treewalker SwapRight" }
)

-- Project-wide diagnostics keymap
remap("n", "<leader>sD", "<cmd>ProjectDiagnostics<cr>", { desc = "Project Diagnostics" })

-- Grug-far search within range
map({ "v" }, "<leader>sr", function()
  require("grug-far").open({ visualSelectionUsage = "operate-within-range" })
end, { desc = "Search/Replace within range (Grug-far)" })

-- Grug-far search in current file only
map("n", "<leader>sF", function()
  require("grug-far").open({
    prefills = {
      paths = vim.fn.expand("%"), -- Current file path
    },
  })
end, { desc = "Search/Replace in current file (Grug-far)" })

-- Grug-far search selected text in current file
map("v", "<leader>sF", function()
  require("grug-far").with_visual_selection({
    prefills = {
      paths = vim.fn.expand("%"), -- Current file path
    },
  })
end, { desc = "Search/Replace selection in current file (Grug-far)" })

-- Grug-far search in current directory
map("n", "<leader>sR", function()
  require("grug-far").open({
    prefills = {
      paths = vim.fn.expand("%:h"), -- Current file's directory
    },
  })
end, { desc = "Search/Replace in current directory (Grug-far)" })
