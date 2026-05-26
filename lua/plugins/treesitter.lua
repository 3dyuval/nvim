-- Treesitter related configurations
-- Note: nvim-surround is now in lua/plugins/surround.lua
return {
  {
    "aaronik/treewalker.nvim",
    opts = {
      highlight = true,
      highlight_duration = 250,
      highlight_group = "CursorLine",
      jumplist = true,
    },
  },
  {
    "arborist-ts/arborist.nvim",
    lazy = false,
    config = function()
      require("arborist").setup({
        update_cadence = "weekly",
        ensure_installed = {
          "lua",
          "vim",
          "vimdoc",
          "query",
          "markdown",
          "markdown_inline",
          "go",
          "rust",
          "ruby",
          "javascript",
          "typescript",
          "tsx",
          "python",
          "bash",
          "json",
          "yaml",
          "toml",
          "elixir",
          "heex",
          "vue",
          "css",
          "scss",
          "html",
          "kcl",
        },
        overrides = {
          kcl = {
            url = "https://github.com/KittyCAD/tree-sitter-kcl",
          },
        },
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    dependencies = {
      "RRethy/nvim-treesitter-endwise",
    },
    config = function()
      require("treesitter.setup")()
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    enabled = true,
    branch = "main",
    event = "VeryLazy",
    config = function()
      require("treesitter.textobjects")()
    end,
  },
}
