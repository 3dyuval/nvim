return {
  -- LSP Configuration & Plugins
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason.nvim",
      "mason-lspconfig.nvim",
    },
  },

  -- Mason for managing LSP servers
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    opts = {
      ensure_installed = {
        "stylua",
        "shfmt",
        "prettier",
        "typescript-language-server", -- For typescript-tools compatibility
        "angular-language-server", -- For Angular support
      },
    },
  },

  -- Bridge between Mason and lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "lua_ls",
        "ts_ls", -- Keep for installation but don't setup
        "angularls", -- Angular Language Server
        -- Add any language servers you want installed
      },
      automatic_installation = true,
      handlers = {
        -- Default setup for all servers with enhanced capabilities
        function(server_name)
          local ok, lspconfig = pcall(require, "lspconfig")
          if not ok then
            vim.notify("LSPConfig not found", vim.log.levels.ERROR)
            return
          end

          lspconfig[server_name].setup({})
        end,
        -- Prevent typescript-language-server setup (managed by typescript-tools)
        ["ts_ls"] = function() end,
        ["tsserver"] = function() end,
        -- Enhanced Angular Language Server configuration
        ["angularls"] = function()
          require("lspconfig").angularls.setup({
            filetypes = {
              "typescript",
              "html",
              "typescriptreact",
              "typescript.tsx",
            },
            root_dir = require("lspconfig.util").root_pattern("angular.json", "project.json"),
            settings = {
              angular = {
                analytics = false, -- Disable analytics
                trace = { server = "off" },
                suggest = {
                  includeCompletionsForModuleExports = true,
                },
                experimental = {
                  lazyTemplates = true, -- Enable lazy template parsing
                },
              },
            },
          })
        end,
      },
    },
  },

  -- TypeScript type information display
  {
    "marilari88/twoslash-queries.nvim",
    ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    opts = {
      multi_line = true,
      is_enabled = true,
    },
  },

  -- Enhanced TypeScript development
  {
    "pmizio/typescript-tools.nvim",
    ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    keys = {
      {
        "<leader>cI",
        "<cmd>TSToolsAddMissingImports<cr>",
        desc = "Add missing imports",
        ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
      },
      {
        "<leader>ci",
        function()
          vim.lsp.buf.code_action({
            apply = true,
            filter = function(action)
              return action.title:match("Add import") or action.title:match("Import")
            end,
          })
        end,
        desc = "Import symbol under cursor",
        ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
      },
    },
    opts = {
      settings = {
        -- Disable built-in code lens to prevent duplicate autocmds
        code_lens = "off", -- We'll enable it manually in on_attach
        disable_member_code_lens = false, -- Show references for object members
        tsserver_file_preferences = {
          includeInlayParameterNameHints = "all",
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
          importModuleSpecifier = "non-relative",
        },
      },
      -- Disable typescript-tools' built-in autocmds to prevent conflicts
      code_lens_auto_refresh = false,
      on_attach = function(client, bufnr)
        -- Enable inlay hints for TypeScript
        if client.supports_method("textDocument/inlayHint") then
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end

        -- Enable code lens manually with minimal refresh for typescript-tools
        if client.name == "typescript-tools" then
          -- Force enable code lens capabilities manually
          if not client.server_capabilities.codeLensProvider then
            client.server_capabilities.codeLensProvider = { resolveProvider = true }
          end

          -- Single initial refresh only
          vim.defer_fn(function()
            if vim.api.nvim_buf_is_valid(bufnr) then
              vim.lsp.codelens.refresh({ bufnr = bufnr })
            end
          end, 1000)
        end
      end,
      handlers = {
        ["workspace/executeCommand"] = function(_err, result, ctx, _config)
          if ctx.params.command ~= "_typescript.goToSourceDefinition" then
            return
          end
          if result == nil or #result == 0 then
            return
          end
          vim.lsp.util.jump_to_location(result[1], "utf-8")
        end,
      },
    },
  },
}
