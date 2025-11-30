return {
  -- LSP Keymaps Override for LazyVim
  -- Consolidates all LSP keymaps from lsp-keymaps.lua, codelens.lua, and lazyvim-config.lua
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts = opts or {}
      opts.servers = opts.servers or {}
      opts.servers["*"] = opts.servers["*"] or {}
      opts.servers["*"].keys = opts.servers["*"].keys or {}

      local keys = opts.servers["*"].keys

      -- Disable conflicting default keymaps
      keys[#keys + 1] = { "[[", false }
      keys[#keys + 1] = { "]]", false }
      keys[#keys + 1] = { "<leader>cc", false }
      keys[#keys + 1] = { "<leader>cr", false } -- From lazyvim-config.lua

      -- Standard LSP keymaps
      keys[#keys + 1] = { "<leader>cl", vim.lsp.codelens.refresh, desc = "Refresh Codelens" }
      keys[#keys + 1] = { "<leader>cL", "<cmd>LspInfo<cr>", desc = "LSP Info" }
      keys[#keys + 1] = { "<leader>cr", require("utils.files").smart_rename, desc = "Smart Rename" }
      keys[#keys + 1] = { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action" }

      -- Reference keymaps
      keys[#keys + 1] =
        { "<leader>cR", vim.lsp.buf.references, desc = "References (quickfix)", mode = { "n" } }
      keys[#keys + 1] =
        { "<leader>cx", require("utils.files").smart_references, desc = "Smart References", mode = { "n" } }

      return opts
    end,
  },
}
