-- TypeScript Tools - Alternative to vtsls/ts_ls
-- Based on solution from: https://github.com/LazyVim/LazyVim/discussions/3603
-- This replaces vtsls with typescript-tools.nvim which is more stable

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Disable ALL TypeScript servers to prevent conflicts
        tsserver = { enabled = false },
        ts_ls = { enabled = false },
        vtsls = { enabled = false },
        ["typescript-language-server"] = { enabled = false },
      },
    },
  },
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    ft = {
      "javascript",
      "javascriptreact",
      "javascript.jsx",
      "typescript",
      "typescriptreact",
      "typescript.tsx",
    },
    opts = {
      settings = {
        -- spawn additional tsserver instance to calculate diagnostics on it
        separate_diagnostic_server = true,
        -- "change"|"insert_leave" determine when the client asks the server about diagnostic
        publish_diagnostic_on = "insert_leave",
        -- array of strings("fix_all"|"add_missing_imports"|"remove_unused"|
        -- "remove_unused_imports"|"organize_imports") -- or string "all"
        -- to include all supported code actions
        -- specify commands exposed as code_actions
        expose_as_code_action = "all", -- Expose all supported code actions
        -- string|nil - specify a custom path to `tsserver.js` file, if this is nil or file under path
        -- not exists then standard path resolution strategy is applied
        tsserver_path = nil,
        -- specify a list of plugins to load by tsserver, e.g., for support of styled-components
        -- (see 💅 `styled-components` support section)
        tsserver_plugins = {},
        -- this value is passed to: https://nodejs.org/api/cli.html#--max-old-space-sizesize-in-megabytes
        -- memory limit in megabytes or "auto"(basically no limit)
        tsserver_max_memory = "auto",
        -- described below
        tsserver_format_options = {},
        tsserver_file_preferences = {
          -- Import preferences
          importModuleSpecifier = "non-relative",
          -- Conservative inlay hints (reduced verbosity)
          includeInlayParameterNameHints = "literals", -- Only for literal values, not "all"
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = false, -- Disable verbose function parameter types
          includeInlayVariableTypeHints = false, -- Disable verbose variable types
          includeInlayPropertyDeclarationTypeHints = true, -- Keep useful property types
          includeInlayFunctionLikeReturnTypeHints = false, -- Disable verbose return types
          includeInlayEnumMemberValueHints = true, -- Keep concise enum values
        },
        -- File watching optimization - exclude large directories to reduce file watchers (issue #48)
        watchOptions = {
          excludeDirectories = {
            "**/node_modules",
            "**/dist",
            "**/build",
            "**/.git",
            "**/coverage",
            "**/tmp",
            "**/temp",
          },
        },
        -- locale of all tsserver messages, supported locales you can find here:
        -- https://github.com/microsoft/TypeScript/blob/3c221fc086be52b19801f6e8d82596d04607ede6/src/compiler/utilitiesPublic.ts#L620
        tsserver_locale = "en",
        -- mirror of VSCode's `typescript.suggest.completeFunctionCalls`
        complete_function_calls = false,
        include_completions_with_insert_text = true,
        -- CodeLens
        -- WARNING: Experimental feature also in VSCode, because it might hit performance of server.
        -- possible values: ("off"|"all"|"implementations_only"|"references_only")
        code_lens = "off",
        -- by default code lenses are displayed on all referencable values and for some of you it can
        -- be too much this option reduce count of them by removing member references from lenses
        disable_member_code_lens = true,
        -- JSXCloseTag
        -- WARNING: it is disabled by default (maybe you configuration or distro already uses nvim-ts-autotag,
        -- that maybe have a conflict if enable this feature. )
        jsx_close_tag = {
          enable = false,
          filetypes = { "javascriptreact", "typescriptreact" },
        },
      },
      filetypes = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
      },
    },
    config = function(_, opts)
      require("typescript-tools").setup(opts)

      -- Enable inlay hints and codelens for TypeScript files
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.name == "typescript-tools" then
            -- Enable inlay hints (new syntax for Neovim 0.10+)
            vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })

            -- Codelens disabled at server level (code_lens = "off") to prevent performance issues
          end
        end,
      })
    end,
    keys = {
      {
        "gD",
        "<cmd>TSToolsGoToSourceDefinition<cr>",
        desc = "Goto Source Definition",
      },
      { "<leader>cD", "<cmd>TSToolsRunCodelens<cr>", desc = "Run Codelens Action" },
      { "<leader>cC", "<cmd>LspInfo<cr>", desc = "LSP Info" },
      { "<leader>cL", vim.lsp.codelens.refresh, desc = "Refresh Codelens" },
      { "<leader>cr", vim.lsp.buf.references, desc = "Show References" },
      { "<leader>cc", vim.lsp.buf.rename, desc = "Rename Symbol" },
      { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action" },
      {
        "gR",
        "<cmd>TSToolsFileReferences<cr>",
        desc = "File References",
      },
      {
        "<leader>co",
        function()
          -- Use biome for organize imports only (no formatting)
          local bufnr = vim.api.nvim_get_current_buf()
          local filepath = vim.api.nvim_buf_get_name(bufnr)

          if filepath == "" or vim.fn.filereadable(filepath) == 0 then
            vim.notify("No valid file to organize imports", vim.log.levels.WARN)
            return
          end

          -- Check if biome is available
          local biome_cmd = vim.fn.executable("biome")
          if biome_cmd == 0 then
            -- Fallback to TSToolsOrganizeImports if biome not available
            vim.cmd("TSToolsOrganizeImports")
            return
          end

          -- Use biome to organize imports only (disable formatting)
          local cmd = {
            "biome",
            "check",
            "--write",
            "--formatter-enabled=false",
            "--linter-enabled=false",
            filepath,
          }

          vim.fn.system(cmd)

          -- Reload the buffer to show changes
          vim.cmd("silent! checktime")
        end,
        desc = "Organize Imports (Biome)",
      },
      {
        "<leader>cI",
        "<cmd>TSToolsAddMissingImports<cr>",
        desc = "Add missing imports",
      },
      {
        "<leader>cu",
        "<cmd>TSToolsRemoveUnusedImports<cr>",
        desc = "Remove unused imports",
      },
      {
        "<leader>cF",
        "<cmd>TSToolsFixAll<cr>",
        desc = "Fix all diagnostics",
      },
      {
        "<leader>cV",
        "<cmd>TSToolsSelectTsVersion<cr>",
        desc = "Select TS workspace version",
      },
    },
  },
}
