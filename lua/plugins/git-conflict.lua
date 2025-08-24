return {
  "akinsho/git-conflict.nvim",
  version = "*",
  enabled = false,
  config = function()
    require("git-conflict").setup({
      default_mappings = false, -- Disable to avoid conflicts with global git keymaps
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
