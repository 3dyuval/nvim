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
      ts_ls = { enabled = false },
      -- Suppress LazyVim typescript extra's typescript-language-server
      -- See issue #1 - LazyVim extra conflicts with vtsls configuration
      ["typescript-language-server"] = { enabled = false },

      -- Disable vtsls (replaced with typescript-tools.nvim)
      vtsls = { enabled = false },

      -- Disable Angular LSP (not using Angular)
      angularls = { enabled = false },

      -- === Vue Development ===
      volar = {
        filetypes = { "vue" },
        init_options = {
          vue = { hybridMode = false },
          typescript = {
            -- tsdk path can be customized here if needed
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
      volar = function(_, opts)
        Snacks.util.lsp.on({ name = "volar" }, function(bufnr, client)
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
