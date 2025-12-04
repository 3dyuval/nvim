return {
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
      keys[#keys + 1] = { "<leader>cr", false }

      -- Standard LSP keymaps
      keys[#keys + 1] = { "<leader>cl", vim.lsp.codelens.refresh, desc = "Refresh Codelens" }
      keys[#keys + 1] = { "<leader>cL", "<cmd>LspInfo<cr>", desc = "LSP Info" }
      keys[#keys + 1] = { "<leader>cr", require("utils.files").smart_rename, desc = "Smart Rename" }
      keys[#keys + 1] = { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action" }

      -- Reference keymaps
      keys[#keys + 1] =
        { "<leader>cR", vim.lsp.buf.references, desc = "References (quickfix)", mode = { "n" } }
      keys[#keys + 1] = {
        "<leader>cx",
        require("utils.files").smart_references,
        desc = "Smart References",
        mode = { "n" },
      }

      local ts_ft = { "typescript", "typescriptreact", "javascript", "javascriptreact", "vue" }

      keys[#keys + 1] = {
        "gD",
        function()
          local params = vim.lsp.util.make_position_params(0, "utf-16")
          LazyVim.lsp.execute({
            command = "typescript.goToSourceDefinition",
            arguments = { params.textDocument.uri, params.position },
            open = true,
          })
        end,
        desc = "Goto Source Definition",
        ft = ts_ft,
      }
      keys[#keys + 1] = {
        "gR",
        function()
          LazyVim.lsp.execute({
            command = "typescript.findAllFileReferences",
            arguments = { vim.uri_from_bufnr(0) },
            open = true,
          })
        end,
        desc = "File References",
        ft = ts_ft,
      }

      return opts
    end,
  },
}
