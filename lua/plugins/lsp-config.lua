return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      -- Global server config
      ["*"] = {
        capabilities = {
          positionEncoding = "utf-8",
        },
      },

      -- === Lua Development ===
      lua_ls = {
        capabilities = { positionEncoding = "utf-8" },
        settings = {
          Lua = {
            runtime = {
              version = "LuaJIT",
            },
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME,
              },
            },
            telemetry = {
              enable = false,
            },
          },
        },
      },

      -- === Ruby Development ===
      solargraph = {
        capabilities = { positionEncoding = "utf-8" },
        settings = {
          solargraph = {
            diagnostics = true,
            completion = true,
            hover = true,
            formatting = true,
          },
        },
      },

      -- === Rust Development ===
      rust_analyzer = {
        capabilities = { positionEncoding = "utf-8" },
        settings = {
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = true,
              loadOutDirsFromCheck = true,
              buildScripts = {
                enable = true,
              },
            },
            checkOnSave = {
              command = "clippy",
            },
            procMacro = {
              enable = true,
            },
          },
        },
      },

      -- === Go Development ===
      gopls = {
        capabilities = { positionEncoding = "utf-8" },
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
              shadow = true,
            },
            staticcheck = true,
            gofumpt = true,
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
          },
        },
      },
      -- Disable formatters that Mason tries to use as LSP servers
      stylua = { enabled = false }, -- stylua is only a formatter (via conform.nvim), not an LSP

      -- Disable other TypeScript servers
      tsserver = { enabled = false },
      -- Suppress LazyVim typescript extra's typescript-language-server
      -- See issue #1 - LazyVim extra conflicts with vtsls configuration
      ["typescript-language-server"] = { enabled = false },

      ts_ls = { enabled = false },
      volar = { enabled = false },
      angularls = { enabled = false },

      -- === TypeScript/JavaScript Development ===
      -- Using vtsls with @vue/typescript-plugin for Vue support
      vtsls = {
        enabled = true,
        filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
        settings = {
          vtsls = {
            tsserver = {
              globalPlugins = {},
            },
          },
          typescript = {
            preferences = {
              importModuleSpecifier = "relative",
            },
            inlayHints = {
              parameterNames = { enabled = "literals" },
              parameterTypes = { enabled = false },
              variableTypes = { enabled = true },
              propertyDeclarationTypes = { enabled = true },
              functionLikeReturnTypes = { enabled = false },
              enumMemberValues = { enabled = true },
            },
          },
        },
        before_init = function(_, config)
          -- Add Vue plugin if vue-language-server is installed via Mason
          local vue_plugin_path = vim.fn.stdpath("data")
            .. "/mason/packages/vue-language-server/node_modules/@vue/language-server"
          if vim.fn.isdirectory(vue_plugin_path) == 1 then
            table.insert(config.settings.vtsls.tsserver.globalPlugins, {
              name = "@vue/typescript-plugin",
              location = vue_plugin_path,
              languages = { "vue" },
              configNamespace = "typescript",
              enableForWorkspaceTypeScriptVersions = true,
            })
          end
        end,
      },

      -- === Vue Development ===
      -- Hybrid mode with vtsls handling TypeScript
      vue_ls = {
        enabled = true,
        filetypes = { "vue" },
        init_options = {
          vue = { hybridMode = true },
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
      },

      -- === CSS/Styling ===
      tailwindcss = {
        capabilities = { positionEncoding = "utf-8" },
        filetypes = {
          "html",
          "css",
          "scss",
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
        },
        settings = {
          tailwindCSS = {
            validate = true,
            lint = {
              cssConflict = "warning",
              invalidApply = "error",
              invalidScreen = "error",
              invalidTailwindDirective = "error",
              invalidVariant = "error",
              recommendedVariantOrder = "warning",
            },
            experimental = {
              classRegex = {
                "className\\s*=\\s*[\"']([^\"']*)[\"']",
                "class\\s*=\\s*[\"']([^\"']*)[\"']",
                "classList\\s*=\\s*[\"']([^\"']*)[\"']",
                { "clsx\\(([^)]*)\\)", "[\"'`]([^\"'`]*)[\"'`]" },
                { "classnames\\(([^)]*)\\)", "[\"'`]([^\"'`]*)[\"'`]" },
                { "cn\\(([^)]*)\\)", "[\"'`]([^\"'`]*)[\"'`]" },
              },
            },
          },
        },
      },
    },
    setup = {
      vue_ls = function(_, opts)
        Snacks.util.lsp.on({ name = "vue_ls" }, function(bufnr, client)
          vim.keymap.set(
            "n",
            "<leader>cr",
            vim.lsp.buf.rename,
            { buffer = bufnr, desc = "LSP Rename" }
          )
          if client.server_capabilities.documentSymbolProvider then
            require("nvim-navic").attach(client, bufnr)
          end
        end)
      end,
    },
  },
}
