-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Folding settings (prevent everything from folding)
vim.opt.foldlevel = 99 -- High fold level = most folds open
vim.opt.foldlevelstart = 99 -- Start with most folds open
vim.opt.foldenable = true -- Enable folding
vim.opt.foldcolumn = "1" -- Show fold column
vim.opt.fillchars = {
  foldopen = "▼",
  foldclose = "▶",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}

-- vim-visual-multi configuration (must be set before plugin loads)
-- Implementation attempts for GitHub issue #38: Implement multi-cursor support
--
-- ATTEMPTS MADE:
-- 1. Initial config in plugin config() function - FAILED: Variables set too late, caused E1206 dictionary error
-- 2. Moved to autocmds.lua - FAILED: File not loaded early enough in LazyVim sequence
-- 3. Moved to options.lua - SUCCESS: Variables load before plugins
-- 4. Used vim.empty_dict() instead of {} - SUCCESS: Fixed E1206 dictionary initialization error
-- 5. VM leader conflicts tried: '<leader>m' (conflicts with 'm' find operator), '<leader>v' (conflicts with paste)
-- 6. Current leader '<leader>k' - No obvious conflicts but keymaps show but don't execute
-- 7. Removed event = "VeryLazy" from plugin spec to avoid timing issues
-- 8. Added VM_maps direct assignments via vim.cmd() for Graphite layout
--
-- CURRENT ISSUE: Keymaps appear in which-key but don't execute when pressed
-- Need to debug: Plugin loading, mapping registration, or keymap activation

vim.g.VM_leader = "<leader>k"
vim.g.VM_silent_exit = 1
vim.g.VM_mouse_mappings = 0

-- Initialize VM_maps and add Graphite layout mappings
vim.g.VM_maps = vim.empty_dict()

-- Set custom mappings for Graphite layout in VM_maps
-- This attempts to map Graphite haei layout to VM's hjkl expectations
vim.cmd([[
  let g:VM_maps['h'] = 'h'
  let g:VM_maps['a'] = 'j'
  let g:VM_maps['e'] = 'k'
  let g:VM_maps['i'] = 'l'
  let g:VM_maps['r'] = 'i'
  let g:VM_maps['t'] = 'a'
  let g:VM_maps['Undo'] = 'z'
  let g:VM_maps['Redo'] = 'Z'
]])

-- Custom motions for Graphite layout (backup method)
-- This was attempt #2 to handle Graphite layout - may not be working
vim.g.VM_custom_motions = {
  ["j"] = "a", -- VM's 'j' (down) mapped to your 'a'
  ["k"] = "e", -- VM's 'k' (up) mapped to your 'e'
  ["l"] = "i", -- VM's 'l' (right) mapped to your 'i'
  ["w"] = "d", -- VM's 'w' (word) mapped to your 'd'
  ["b"] = "l", -- VM's 'b' (back) mapped to your 'l'
}

-- Custom remaps for Graphite layout (backup method)
-- This was attempt #3 to handle Graphite layout - may not be working
vim.g.VM_custom_remaps = {
  ["r"] = "i", -- Your 'r' triggers VM's 'i' (insert)
  ["t"] = "a", -- Your 't' triggers VM's 'a' (append)
}
