-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set

-- Helper function to safely override existing keymaps
local function override_map(mode, lhs, rhs, opts)
  pcall(vim.keymap.del, mode, lhs)
  map(mode, lhs, rhs, opts)
end

-- Delete on 'x' (Graphite layout) - but allow surround plugin to handle 'xs'
-- Note: surround plugin will handle 'xs' directly, this handles other 'x' operations
map({ "n", "x" }, "x", "d", { desc = "Delete" })
-- Skip operator-pending mode to let surround plugin handle 'xs' directly

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
map({ "n" }, "T", "I", { desc = "Insert at start of line" })
map({ "n" }, "t", "a", { desc = "Insert after cursor" })
map({ "n" }, "S", "A", { desc = "Insert at end of line" })

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

-- Repeat find
map({ "n", "o", "x" }, ";", ";", { desc = "Repeat find forward" })
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

-- Folds
map({ "n", "x" }, "b", "z", { desc = "Fold commands" })
map({ "n", "x" }, "bb", "zb", { desc = "Scroll line and cursor to bottom" })
map({ "n", "x" }, "be", "zk", { desc = "Move up to fold" })
map({ "n", "x" }, "ba", "zj", { desc = "Move down to fold" })
map({ "n", "x" }, "bf", "zc", { desc = "Close fold" })
map({ "n", "x" }, "bF", "zM", { desc = "Fold entire buffer" })
map({ "n", "x" }, "bO", "zR", { desc = "Open all folds" })

-- Copy/paste
map({ "n", "o", "x" }, "c", "y", { desc = "Yank (copy)" })
map({ "n", "x" }, "v", "p", { desc = "Paste" })
map({ "n" }, "C", "y$", { desc = "Yank to end of line" })
map({ "x" }, "C", "y", { desc = "Yank selection" })
map({ "n", "x" }, "V", "P", { desc = "Paste before" })
map({ "v" }, "V", "P", { desc = "Paste without losing clipboard" })

-- Undo/redo
map({ "n" }, "z", "u", { desc = "Undo" })
map({ "n" }, "<S-u>", "U", { desc = "Undo line" })
map({ "n" }, "<C-u>", "<C-r>", { desc = "Redo" })
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

map({ "n" }, "<leader>gn", "<cmd>:Neogit cwd=%:p:h<CR>", { desc = "Open neogit" })
map({ "n" }, "<leader>gh", function()
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
  Snacks.picker.git_branches()
end, { desc = "Git branches" })
-- 'til
map({ "n", "o", "x" }, "k", "t", { desc = "Till before" })
map({ "n", "o", "x" }, "K", "T", { desc = "Till before backward" })

-- Fix diffput (t for 'transfer')
-- map({ "n" }, "dt", "dp", { desc = "diffput (t for 'transfer')" })

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
-- Directional window navigation (commented out due to buffer nav conflicts)
-- map({ "n" }, "<C-a>", "<C-w>j", { desc = "Window down" })
-- map({ "n" }, "<C-e>", "<C-w>k", { desc = "Window up" })

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

map("n", "<leader>gD", function()
  vim.cmd("DiffviewOpen -- " .. vim.fn.expand("%:p"))
end, { desc = "Diffview this file" })

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

-- Grug-far search within range
