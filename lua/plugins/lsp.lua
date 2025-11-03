return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      ["*"] = {
        capabilities = {
          positionEncoding = "utf-8",
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
        Snacks.util.lsp.on({ name = "volar" }, function(buf, client)
          vim.keymap.set(
            "n",
            "<leader>cr",
            vim.lsp.buf.rename,
            { buffer = buf, desc = "LSP Rename" }
          )
          if client.server_capabilities.documentSymbolProvider then
            require("nvim-navic").attach(client, buf)
          end
        end)
      end,
    },
  },
}
