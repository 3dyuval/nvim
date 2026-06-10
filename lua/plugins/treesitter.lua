-- [nfnl] fnl/plugins/treesitter.fnl
local function _1_()
  return require("arborist").setup({update_cadence = "weekly", ensure_installed = {"lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "go", "rust", "ruby", "javascript", "typescript", "tsx", "python", "bash", "json", "yaml", "toml", "elixir", "heex", "vue", "css", "scss", "html", "kcl"}, overrides = {kcl = {url = "https://github.com/KittyCAD/tree-sitter-kcl"}}, disable = {indent = {"vue"}}})
end
local function _2_()
  return require("treesitter.setup").setup()
end
local function _3_()
  return require("treesitter.textobjects").setup()
end
return {{"aaronik/treewalker.nvim", opts = {highlight = true, highlight_duration = 250, highlight_group = "CursorLine", jumplist = true}}, {"arborist-ts/arborist.nvim", config = _1_, lazy = false}, {"nvim-treesitter/nvim-treesitter", branch = "main", dependencies = {"RRethy/nvim-treesitter-endwise"}, config = _2_, lazy = false}, {"nvim-treesitter/nvim-treesitter-textobjects", enabled = true, branch = "main", event = "VeryLazy", config = _3_}}
