return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      -- Disable other TypeScript servers
      tsserver = { enabled = false },
      ts_ls = { enabled = false },
      -- Suppress LazyVim typescript extra's typescript-language-server
      -- See issue #1 - LazyVim extra conflicts with vtsls configuration
      ["typescript-language-server"] = { enabled = false },

      -- Disable vtsls (replaced with typescript-tools.nvim)
      vtsls = { enabled = false },
      
      -- Enable Biome LSP for real-time diagnostics
      biome = {
        cmd = { "biome", "lsp-proxy" },
        filetypes = {
          "javascript",
          "javascriptreact", 
          "json",
          "jsonc",
          "typescript",
          "typescriptreact"
        },
        root_dir = function(fname)
          return require("lspconfig.util").root_pattern("biome.json", "biome.jsonc")(fname)
            or require("lspconfig.util").find_git_ancestor(fname)
        end,
        single_file_support = true,
        settings = {
          biome = {
            config_path = vim.fn.stdpath("config") .. "/biome.json",
          },
        },
      },
      
      -- Original vtsls config preserved for reference
      --[[vtsls = {
        filetypes = {
          "javascript",
          "javascriptreact",
          "javascript.jsx",
          "typescript",
          "typescriptreact",
          "typescript.tsx",
        },
        settings = {
          complete_function_calls = true,
          vtsls = {
            enableMoveToFileCodeAction = true,
            autoUseWorkspaceTsdk = true,
            experimental = {
              maxInlayHintLength = 30,
              completion = {
                enableServerSideFuzzyMatch = true,
              },
            },
          },
          typescript = {
            updateImportsOnFileMove = { enabled = "always" },
            suggest = {
              completeFunctionCalls = false,
            },
            preferences = {
              importModuleSpecifier = "non-relative",
            },
            inlayHints = {
              enumMemberValues = { enabled = true },
              functionLikeReturnTypes = { enabled = true },
              parameterNames = { enabled = "literals" },
              parameterTypes = { enabled = true },
              propertyDeclarationTypes = { enabled = true },
              variableTypes = { enabled = false },
            },
            referencesCodeLens = {
              enabled = true,
              showOnAllFunctions = true,
            },
            implementationsCodeLens = {
              enabled = true,
              showOnInterfaceMethods = true,
            },
          },
        },
        keys = {
          {
            "gD",
            function()
              local params = vim.lsp.util.make_position_params(0, "utf-8")
              LazyVim.lsp.execute({
                command = "typescript.goToSourceDefinition",
                arguments = { params.textDocument.uri, params.position },
                open = true,
              })
            end,
            desc = "Goto Source Definition",
          },
          { "<leader>cD", vim.lsp.codelens.run, desc = "Run Codelens Action" },
          {
            "gR",
            function()
              LazyVim.lsp.execute({
                command = "typescript.findAllFileReferences",
                arguments = { vim.uri_from_bufnr(0) },
                open = true,
              })
            end,
            desc = "File References",
          },
          {
            "<leader>co",
            LazyVim.lsp.action["source.organizeImports"],
            desc = "Organize Imports",
          },
          {
            "<leader>cI",
            LazyVim.lsp.action["source.addMissingImports.ts"],
            desc = "Add missing imports",
          },
          {
            "<leader>cu",
            LazyVim.lsp.action["source.removeUnused.ts"],
            desc = "Remove unused imports",
          },
          {
            "<leader>cD",
            LazyVim.lsp.action["source.fixAll.ts"],
            desc = "Fix all diagnostics",
          },
          {
            "<leader>cV",
            function()
              LazyVim.lsp.execute({ command = "typescript.selectTypeScriptVersion" })
            end,
            desc = "Select TS workspace version",
          },
        },
      },--]]

      -- Enable Volar for Vue
      volar = {
        filetypes = { "vue" },
        init_options = {
          vue = {
            hybridMode = false,
          },
          typescript = {
            -- You may want to set the tsdk path, or leave it default
            -- tsdk = "/path/to/typescript/lib",
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

      -- Disable Angular Language Server (conflicts with typescript-tools)
      angularls = { enabled = false },
    },
    setup = {
      -- Don't define setup functions for disabled servers
      -- tsserver, ts_ls, vtsls, and typescript-language-server are disabled via enabled = false
      --[[vtsls_old = function(_, opts)
        LazyVim.lsp.on_attach(function(client, buffer)
          vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { buffer = buffer, desc = "LSP Rename" })

          if client.server_capabilities.documentSymbolProvider then
            require("nvim-navic").attach(client, buffer)
          end

          if client.supports_method("textDocument/codeLens") then
            -- Initial refresh
            vim.lsp.codelens.refresh()

            -- Create a debounced refresh function
            local timer = nil
            local function debounced_refresh()
              if timer then
                timer:stop()
              end
              timer = vim.defer_fn(function()
                vim.lsp.codelens.refresh()
                timer = nil
              end, 500) -- 500ms debounce
            end

            -- Only refresh on meaningful events, with debouncing
            vim.api.nvim_create_autocmd({ "BufWritePost", "TextChanged" }, {
              buffer = buffer,
              callback = debounced_refresh,
            })

            -- Refresh when entering buffer (but only once)
            vim.api.nvim_create_autocmd("BufEnter", {
              buffer = buffer,
              once = true,
              callback = function()
                vim.lsp.codelens.refresh()
              end,
            })
          end

          client.commands["_typescript.moveToFileRefactoring"] = function(command, ctx)
            local action, uri, range = unpack(command.arguments)
            local function move(newf)
              client.request("workspace/executeCommand", {
                command = command.command,
                arguments = { action, uri, range, newf },
              })
            end
            local fname = vim.uri_to_fname(uri)
            client.request("workspace/executeCommand", {
              command = "typescript.tsserverRequest",
              arguments = {
                "getMoveToRefactoringFileSuggestions",
                {
                  file = fname,
                  startLine = range.start.line + 1,
                  startOffset = range.start.character + 1,
                  endLine = range["end"].line + 1,
                  endOffset = range["end"].character + 1,
                },
              },
            }, function(_, result)
              local files = result.body.files
              table.insert(files, 1, "Enter new path...")
              vim.ui.select(files, {
                prompt = "Select move destination:",
                format_item = function(f)
                  return vim.fn.fnamemodify(f, ":~:.")
                end,
              }, function(f)
                if f and f:find("^Enter new path") then
                  vim.ui.input({
                    prompt = "Enter move destination:",
                    default = vim.fn.fnamemodify(fname, ":h") .. "/",
                    completion = "file",
                  }, function(newf)
                    return newf and move(newf)
                  end)
                elseif f then
                  move(f)
                end
              end)
            end)
          end
        end, "vtsls")
        -- copy typescript settings to javascript
        opts.settings.javascript =
          vim.tbl_deep_extend("force", {}, opts.settings.typescript, opts.settings.javascript or {})
      end,--]]
      volar = function(_, opts)
        LazyVim.lsp.on_attach(function(client, buffer)
          vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { buffer = buffer, desc = "LSP Rename" })
          if client.server_capabilities.documentSymbolProvider then
            require("nvim-navic").attach(client, buffer)
          end
        end, "volar")
      end,
      -- angularls setup function removed since server is disabled
    },
  },
}
