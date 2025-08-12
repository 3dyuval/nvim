return {
  -- LSP Keymaps Override for LazyVim
  {
    "neovim/nvim-lspconfig",
    opts = function()
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      
      -- Remove the conflicting keymaps (existing functionality)
      keys[#keys + 1] = { "[[", false }
      keys[#keys + 1] = { "]]", false }
      
      -- Disable LazyVim's codelens keymap
      keys[#keys + 1] = { "<leader>cc", false }
      
      -- Standard LSP keymaps
      keys[#keys + 1] = { "<leader>cL", "<cmd>LspInfo<cr>", desc = "LSP Info" }
      keys[#keys + 1] = { "<leader>cc", vim.lsp.buf.references, desc = "Show References" }
      keys[#keys + 1] = { "<leader>cr", vim.lsp.buf.rename, desc = "Rename Symbol" }
      keys[#keys + 1] = { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action" }
    end,
  },
}
