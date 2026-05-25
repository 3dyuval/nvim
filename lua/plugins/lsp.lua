return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "b0o/schemastore.nvim", -- JSON schemas for jsonls
  },
  config = function()
    -- Load the new native LSP setup
    require("lsp.setup")
  end,
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
    keys[#keys + 1] = { "<leader>cr", false }
    keys[#keys + 1] = { "<C-W>d", false } -- conflicts with summon terminal

    -- Standard LSP keymaps
    keys[#keys + 1] = { "<leader>cl", vim.lsp.codelens.refresh, desc = "Refresh Codelens" }
    keys[#keys + 1] = { "<leader>cL", "<cmd>LspInfo<cr>", desc = "LSP Info" }
    keys[#keys + 1] = { "<leader>cr", require("utils.files").smart_rename, desc = "Smart Rename" }
    keys[#keys + 1] = { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action" }

    -- Reference keymaps (use native gr, keep custom as backup)
    keys[#keys + 1] = { "<leader>cR", vim.lsp.buf.references, desc = "References (quickfix)", mode = { "n" } }
    keys[#keys + 1] = {
      "<leader>cx",
      require("utils.files").smart_references,
      desc = "Smart References",
      mode = { "n" },
    }

    -- TypeScript/Vue navigation keybindings now handled by typescript-tools.nvim
    -- See lua/plugins/typescript-tools.lua for gD and gR keybindings

    -- Native Neovim 0.10+ keybindings (work by default):
    -- gd  - go to definition
    -- gr  - show references
    -- gI  - go to implementation
    -- gy  - go to type definition

    return opts
  end,
}
