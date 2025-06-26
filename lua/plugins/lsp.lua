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
        "typescript-language-server",
        "angular-language-server",
      },
    },
  },

  -- Bridge between Mason and lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "lua_ls",
        "ts_ls",
        "angularls",
      },
      automatic_installation = true,
      handlers = {
        -- Default setup for all servers
        function(server_name)
          local ok, lspconfig = pcall(require, "lspconfig")
          if not ok then
            vim.notify("LSPConfig not found", vim.log.levels.ERROR)
            return
          end

          lspconfig[server_name].setup({})
        end,

        -- Enhanced TypeScript Language Server configuration
        ["ts_ls"] = function()
          require("lspconfig").ts_ls.setup({
            filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
            settings = {
              typescript = {
                inlayHints = {
                  includeInlayParameterNameHints = "all",
                  includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                  includeInlayFunctionParameterTypeHints = true,
                  includeInlayVariableTypeHints = true,
                  includeInlayPropertyDeclarationTypeHints = true,
                  includeInlayFunctionLikeReturnTypeHints = true,
                  includeInlayEnumMemberValueHints = true,
                },
                preferences = {
                  importModuleSpecifier = "non-relative",
                  organizeImports = true,
                },
              },
              javascript = {
                inlayHints = {
                  includeInlayParameterNameHints = "all",
                  includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                  includeInlayFunctionParameterTypeHints = true,
                  includeInlayVariableTypeHints = true,
                  includeInlayPropertyDeclarationTypeHints = true,
                  includeInlayFunctionLikeReturnTypeHints = true,
                  includeInlayEnumMemberValueHints = true,
                },
              },
            },
            on_attach = function(client, bufnr)
              -- Enable inlay hints
              if client.supports_method("textDocument/inlayHint") then
                vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
              end

              -- Enable code lens
              if client.supports_method("textDocument/codeLens") then
                vim.lsp.codelens.refresh({ bufnr = bufnr })

                -- Auto refresh code lens on text changes
                vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
                  buffer = bufnr,
                  callback = function()
                    vim.lsp.codelens.refresh({ bufnr = bufnr })
                  end,
                })
              end
            end,
          })
        end,

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
                analytics = false,
                trace = { server = "off" },
                suggest = {
                  includeCompletionsForModuleExports = true,
                },
                experimental = {
                  lazyTemplates = true,
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

  -- Vue.js support
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("lspconfig").volar.setup({
        filetypes = { "vue", "typescript", "javascript" },
        init_options = {
          vue = {
            hybridMode = false,
          },
          typescript = {
            tsdk = require("mason-registry").get_package("typescript-language-server"):get_install_path()
              .. "/node_modules/typescript/lib",
          },
        },
        settings = {
          vue = {
            complete = {
              casing = {
                tags = "kebab",
                props = "kebab",
              },
            },
          },
        },
      })
    end,
  },
}
