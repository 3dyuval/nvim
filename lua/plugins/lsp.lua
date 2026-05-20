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

    local ts_ft = { "typescript", "typescriptreact", "javascript", "javascriptreact", "vue" }

    -- Helper to execute vtsls-specific commands
    local function vtsls_execute(command, args)
      local clients = vim.lsp.get_clients({ bufnr = 0, name = "vtsls" })
      if #clients == 0 then
        vim.notify("vtsls client not attached", vim.log.levels.WARN)
        return
      end

      clients[1].request("workspace/executeCommand", {
        command = command,
        arguments = args,
      }, function(err, result)
        if err then
          vim.notify("vtsls command error: " .. vim.inspect(err), vim.log.levels.ERROR)
          return
        end
        if result then
          -- Handle single location or list of locations
          local locations = vim.islist(result) and result or { result }
          if #locations > 0 then
            vim.lsp.util.jump_to_location(locations[1], "utf-8", true)
          end
        end
      end, 0)
    end

    -- TypeScript/Vue specific navigation using vtsls commands
    -- Override gd for Vue to use vtsls command (better template support)
    keys[#keys + 1] = {
      "gd",
      function()
        vtsls_execute("typescript.goToSourceDefinition", {
          vim.uri_from_bufnr(0),
          vim.lsp.util.make_position_params().position,
        })
      end,
      desc = "Go to Definition (TS/Vue)",
      ft = { "vue" },
    }
    keys[#keys + 1] = {
      "gD",
      function()
        vtsls_execute("typescript.goToSourceDefinition", {
          vim.uri_from_bufnr(0),
          vim.lsp.util.make_position_params().position,
        })
      end,
      desc = "Goto Source Definition (TS/Vue)",
      ft = ts_ft,
    }
    keys[#keys + 1] = {
      "gR",
      function()
        vtsls_execute("typescript.findAllFileReferences", { vim.uri_from_bufnr(0) })
      end,
      desc = "File References (TS/Vue)",
      ft = ts_ft,
    }

    -- Native Neovim 0.10+ keybindings (already work by default):
    -- gd  - go to definition
    -- gr  - show references (replaces gR for most cases)
    -- gI  - go to implementation (useful for Vue components)
    -- gy  - go to type definition

    return opts
  end,
}
