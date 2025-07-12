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
