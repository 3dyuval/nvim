-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set

-- Helper function to safely override existing keymaps
local function override_map(mode, lhs, rhs, opts)
	pcall(vim.keymap.del, mode, lhs)
	map(mode, lhs, rhs, opts)
end

map("n", "<leader>cp", function()
	local filepath = vim.fn.expand("%:.")
	vim.fn.setreg("+", filepath)
	vim.notify("Copied: " .. filepath)
end, { desc = "Copy file location" })

-- For just filename:
map("n", "<leader>cP", function()
	local filepath = vim.fn.expand("%:.") -- Relative path
	local line = vim.fn.line(".")
	local col = vim.fn.col(".")
	local location = string.format("%s:%d:%d", filepath, line, col)
	vim.fn.setreg("+", location)
	vim.notify("Copied: " .. location)
end, { desc = "Copy filename and line" })

require("which-key").add({
	{ "<leader>cp", desc = "Copy file location", icon = { icon = "", color = "cyan" } },
})

require("which-key").add({
	{ "<leader>cP", desc = "Copy file location and line", icon = { icon = "", color = "cyan" } },
})

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

-- E/A for End of WORD forward/backward
map({ "n", "o", "x" }, "E", "E", { desc = "End of WORD forward" })
map({ "n", "o", "x" }, "A", "gE", { desc = "End of WORD back (reverse of E)" })

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

-- Screen navigation - top/bottom
map({ "n", "o", "x" }, "H", "H", { desc = "Top of screen" })
map({ "n", "o", "x" }, "I", "L", { desc = "Bottom of screen" })

-- End of word left/right (moved to different keys)
map({ "n", "o", "x" }, "gh", "ge", { desc = "End of word back" })
map({ "n", "o", "x" }, "<M-h>", "gE", { desc = "End of WORD back" })
map({ "n", "o", "x" }, "<M-o>", "E", { desc = "End of WORD forward" })

-- Keep visual replace on a different key
map({ "v" }, "X", "r", { desc = "Replace selected text" })

-- Folds (f and F remain default vim find character forward/backward)
map({ "n", "x" }, "ff", "zo", { desc = "Open fold (unfold)" })
map({ "n", "x" }, "fF", "zR", { desc = "Open all folds (unfold all)" })
map({ "n", "x" }, "fu", "zc", { desc = "Close fold (fold one)" })
map({ "n", "x" }, "fU", "zM", { desc = "Close all folds (fold all)" })
map({ "n", "x" }, "fe", "zk", { desc = "Move up to fold" })
map({ "n", "x" }, "fa", "zj", { desc = "Move down to fold" })
map({ "n", "x" }, "bb", "zb", { desc = "Scroll line and cursor to bottom" })

-- Copy/paste
map({ "n", "o", "x" }, "c", "y", { desc = "Yank (copy)" })
map({ "n", "x" }, "v", "p", { desc = "Paste" })
map({ "n" }, "C", "y$", { desc = "Yank to end of line" })
map({ "x" }, "C", "y", { desc = "Yank selection" })
map({ "n", "x" }, "V", "P", { desc = "Paste before" })
map({ "v" }, "V", "P", { desc = "Paste without losing clipboard" })

-- Undo/redo (z for undo, Z for redo - Graphite layout)
-- Need to unmap built-in commands first
override_map("n", "u", "<Nop>", { desc = "Unmapped (now z)" })
override_map("n", "U", "<Nop>", { desc = "Unmapped (now gz)" })
override_map("n", "z", "u", { desc = "Undo" })
override_map("n", "Z", "<C-r>", { desc = "Redo" })
override_map("n", "gz", "U", { desc = "Undo line" })
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

map({ "n" }, "<leader>gn", "<cmd>Neogit cwd=%:p:h<cr>", { desc = "Open neogit" })
map({ "n" }, "<leader>gj", function()
	Snacks.terminal("gh dash", { win = { style = "terminal" } })
end, { desc = "Open GitHub dashboard" })

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

-- Gitsigns keymaps (moved from plugins/gitsigns.lua for better organization)
-- Navigation adapted for HAEI layout (]e = next, [e = prev)
map("n", "]e", function()
	require("gitsigns").next_hunk()
end, { desc = "Next Hunk" })
map("n", "[e", function()
	require("gitsigns").prev_hunk()
end, { desc = "Prev Hunk" })

-- Buffer operations
map("n", "<leader>gG", function()
	require("gitsigns").stage_buffer()
end, { desc = "Stage Buffer" })
map("n", "<leader>gu", function()
	require("gitsigns").undo_stage_hunk()
end, { desc = "Undo Stage Hunk" })
map("n", "<leader>gX", function()
	require("gitsigns").reset_buffer()
end, { desc = "Reset Buffer" })

-- Preview and blame
map("n", "<leader>gh", function()
	require("gitsigns").preview_hunk()
end, { desc = "Git hunks (preview)" })
map("n", "<leader>gp", function()
	require("gitsigns").preview_hunk()
end, { desc = "Preview Hunk" })
map("n", "<leader>gB", function()
	require("gitsigns").blame_line({ full = true })
end, { desc = "Blame Line" })

-- Text object for hunks
map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<cr>", { desc = "GitSigns Select Hunk" })

-- Add new git diff commands
map({ "n" }, "<leader>gdf", "<cmd>DiffviewFileHistory %<cr>", { desc = "Git file diff history" })

map({ "n" }, "<leader>gdd", function()
	Snacks.picker.git_diff()
end, { desc = "Git Diff picker (hunks)" })

map({ "n" }, "<leader>gdr", "<cmd>DiffviewOpen<cr>", { desc = "Git diffview" })
map({ "n" }, "<leader>gdl", "<cmd>DiffviewFileHistory<cr>", { desc = "Git file history (all files)" })
map({ "n" }, "<leader>gdh", "<cmd>DiffviewOpen origin/main...HEAD<cr>", { desc = "Diff with main branch" })
map({ "n" }, "<leader>gdm", "<cmd>DiffviewOpen --merge-tool<cr>", { desc = "Open Diffview merge tool" })

map({ "n" }, "<leader>hB", function()
	Snacks.picker.firefox_bookmarks()
end, { desc = "Firefox bookmarks" })

map({ "n" }, "<leader>hf", function()
	Snacks.picker.firefox_history()
end, { desc = "Firefox history" })

-- File history keymaps
map({ "n" }, "<leader>hh", function()
	require("file_history").history()
end, { desc = "Current file history" })

map({ "n" }, "<leader>ha", function()
	require("file_history").files()
end, { desc = "All files in backup repository" })

map({ "n" }, "<leader>hA", function()
	require("file_history").query()
end, { desc = "Query file history by time range" })

map({ "n" }, "<leader>hT", function()
	require("file_history").backup()
end, { desc = "Manual backup with tag" })
-- 'til
map({ "n", "o", "x" }, "k", "t", { desc = "Till before" })
map({ "n", "o", "x" }, "K", "T", { desc = "Till before backward" })

-- Force override any plugin mappings for Q
vim.keymap.set("n", "Q", "@q", { desc = "replay the 'q' macro", silent = true, noremap = true })

-- Screen navigation - H/I for top/bottom (replaces B mapping)
map({ "n", "o", "x" }, "I", "L", { desc = "Bottom of screen" })

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

-- Window navigation - using leader+w prefix
map({ "n" }, "<leader>wh", "<C-w>h", { desc = "Left window" })
map({ "n" }, "<leader>wi", "<C-w>l", { desc = "Right window" })
map({ "n" }, "<leader>wa", "<C-w>j", { desc = "Window down" })
map({ "n" }, "<leader>we", "<C-w>k", { desc = "Window up" })
-- Cycle through windows with Alt+Tab
map({ "n" }, "<M-Tab>", "<C-w>w", { desc = "Cycle windows" })

-- Buffer navigation - using Tab keys
map({ "n" }, "<S-Tab>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map({ "n" }, "<Tab>", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- Add some commonly used editor operations
map({ "n" }, "<leader>fs", ":w<CR>", { desc = "Save file" })
map({ "n" }, "<leader>q", ":q<CR>", { desc = "Quit" })
map({ "n" }, "<leader>Q", ":qa<CR>", { desc = "Quit all" })
map({ "n" }, "<leader>rr", function()
	vim.cmd("source " .. vim.fn.stdpath("config") .. "/lua/config/keymaps.lua")
	vim.notify("Keymaps reloaded")
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

map({ "x", "o" }, "Re", function()
	require("nvim-treesitter.textobjects.select").select_textobject("@element.inner", "textobjects")
end, { desc = "Select inner JSX element" })

map({ "x", "o" }, "Te", function()
	require("nvim-treesitter.textobjects.select").select_textobject("@element.outer", "textobjects")
end, { desc = "Select around JSX element" })

map({ "x", "o" }, "Rh", function()
	require("nvim-treesitter.textobjects.select").select_textobject("@tag.inner", "textobjects")
end, { desc = "Select inner HTML tag" })

map({ "x", "o" }, "Th", function()
	require("nvim-treesitter.textobjects.select").select_textobject("@tag.outer", "textobjects")
end, { desc = "Select around HTML tag" })
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

-- Treewalker keymaps (will override LazyVim defaults)
-- Movement keymaps using Ctrl+HAEI (Graphite layout) - "walk" with ctrl
vim.keymap.set({ "n", "v" }, "<C-e>", "<cmd>Treewalker Up<cr>", { silent = true, desc = "Treewalker Up" })
vim.keymap.set({ "n", "v" }, "<C-a>", "<cmd>Treewalker Down<cr>", { silent = true, desc = "Treewalker Down" })
vim.keymap.set({ "n", "v" }, "<C-i>", "<cmd>Treewalker Right<cr>", { silent = true, desc = "Treewalker Right" })
-- Use C-h for parent (move left then parent)
vim.keymap.set("n", "<C-h>", function()
	vim.cmd("normal! h")
	vim.cmd("Treewalker Parent")
end, { desc = "Move left then Treewalker Parent", silent = true })
vim.keymap.set("v", "<C-h>", function()
	vim.cmd("normal! h")
	vim.cmd("Treewalker Parent")
end, { desc = "Move left then Treewalker Parent", silent = true })

-- Swapping keymaps using Alt+HAEI - "swap" with alt
vim.keymap.set("n", "<M-e>", "<cmd>Treewalker SwapUp<cr>", { silent = true, desc = "Treewalker SwapUp" })
vim.keymap.set("n", "<M-a>", "<cmd>Treewalker SwapDown<cr>", { silent = true, desc = "Treewalker SwapDown" })
vim.keymap.set("n", "<M-h>", "<cmd>Treewalker SwapLeft<cr>", { silent = true, desc = "Treewalker SwapLeft" })
vim.keymap.set("n", "<M-i>", "<cmd>Treewalker SwapRight<cr>", { silent = true, desc = "Treewalker SwapRight" })

-- Project-wide diagnostics keymap
override_map("n", "<leader>sD", "<cmd>ProjectDiagnostics<cr>", { desc = "Project Diagnostics" })

-- Grug-far search within range
