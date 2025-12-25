return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    -- Suppress vtsls internal notification (no client handler needed)
    vim.lsp.commands["_typescript.didOrganizeImports"] = function() end

    -- Register custom tsgo server
    local lspconfig = require("lspconfig")
    local configs = require("lspconfig.configs")

    if not configs.tsgo then
      configs.tsgo = {
        default_config = {
          cmd = { "tsgo", "--lsp", "--stdio" },
          filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
          root_dir = lspconfig.util.root_pattern("tsconfig.json", "jsconfig.json", "package.json", ".git"),
        },
      }
    end

    opts.servers = opts.servers
      or {
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
                -- library managed by lazydev.nvim
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
        -- === TypeScript Go (tsgo) ===
        tsgo = { enabled = true },

        -- Disable formatters that Mason tries to use as LSP servers
        stylua = { enabled = false }, -- stylua is only a formatter (via conform.nvim), not an LSP

        -- Disable other TypeScript servers
        tsserver = { enabled = false },
        -- Suppress LazyVim typescript extra's typescript-language-server
        -- See issue #1 - LazyVim extra conflicts with vtsls configuration
        ["typescript-language-server"] = { enabled = false },

        ts_ls = { enabled = false },
        volar = { enabled = false },

        -- === TypeScript/JavaScript Development ===
        -- Using vtsls with @vue/typescript-plugin for Vue support
        -- https://github.com/vuejs/language-tools/wiki/Neovim
        vtsls = {
          enabled = true,
          -- Use local build for testing willRenameFiles support
          cmd = { vim.fn.expand("~/proj/vtsls/packages/server/bin/vtsls.js"), "--stdio" },
          filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
          settings = {
            vtsls = {
              autoUseWorkspaceTsdk = false, -- Automatically use bundled TypeScript instead of projects'
              tsserver = {
                globalPlugins = {
                  {
                    name = "@vue/typescript-plugin",
                    location = vim.fn.stdpath("data")
                      .. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
                    languages = { "vue" },
                    configNamespace = "typescript",
                  },
                },
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
      }

    opts.setup = opts.setup or {}
    opts.setup.vue_ls = function(_, opts)
      Snacks.util.lsp.on({ name = "vue_ls" }, function(bufnr, client)
        -- Disable rename in hybrid mode (vtsls handles it)
        client.server_capabilities.renameProvider = false
        -- navic auto-attaches with preference (see navic.lua)
      end)
    end
  end,
}
