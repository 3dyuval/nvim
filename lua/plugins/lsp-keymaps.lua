return {
  -- Disable specific LSP keymaps that conflict with git-conflict navigation
  {
    "neovim/nvim-lspconfig",
    opts = function()
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      -- Remove the conflicting keymaps
      keys[#keys + 1] = { "[[", false }
      keys[#keys + 1] = { "]]", false }
    end,
  },
}

