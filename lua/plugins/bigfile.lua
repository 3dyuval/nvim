return {
  "LunarVim/bigfile.nvim",
  config = function()
    -- In your LunarVim config
    require("bigfile").setup({
      filesize = 1, -- Size in MB (1MB threshold)
      pattern = { "*" }, -- File patterns to check
      features = { -- Features to disable
        "indent_blankline",
        "illuminate",
        "lsp",
        "treesitter",
        "syntax", -- This should prevent the error
        "matchparen",
        "vimopts",
        "filetype",
      },
    })
  end,
}
