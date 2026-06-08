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
    -- Smart references picker kept (no native equivalent).
    keys[#keys + 1] = {
      "<leader>cx",
      require("utils.files").smart_references,
      desc = "Smart References",
      mode = { "n" },
    }

    -- NOTE: <leader>cr (rename), <leader>ca (code action), <leader>cR (references),
    -- and gd / gD / gR moved to Neovim 0.11 native gr* defaults. They are now
    -- noop+notify nudges defined in fnl/lsp/setup.fnl. Native mappings to use:
    --   grn rename · gra code action · grr references · gd definition
    --   gri implementation · grt type definition · gO document symbols

    return opts
  end,
}
