-- Add NVM node to PATH before plugins load (required for Treesitter + LSP)
vim.env.PATH = vim.env.HOME .. "/.nvm/versions/node/v20.19.3/bin:" .. vim.env.PATH

require("config.lazy")
require("utils.diff-highlights")
