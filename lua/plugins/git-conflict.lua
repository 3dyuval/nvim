return {
  "akinsho/git-conflict.nvim",
  version = "*",
  config = function()
    require("git-conflict").setup({
      default_mappings = {
        ours = "gp", -- map gp to choose ours (put)
        theirs = "go", -- map go to choose theirs (get)
        none = "0", -- keep default
        both = "gv",
        next = "]]",
        prev = "[[",
      },
      default_commands = true,
      disable_diagnostics = false,
      list_opener = "copen",
      highlights = {
        incoming = "DiffAdd",
        current = "DiffText",
      },
    })
  end,
}
