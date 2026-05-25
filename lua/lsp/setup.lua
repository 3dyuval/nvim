-- Global capabilities for all servers
vim.lsp.config("*", {
  capabilities = {
    positionEncoding = "utf-8",
  },
  root_markers = { ".git" },
})

-- Enable all your servers
-- Note: Enable vtsls here when USE_TYPESCRIPT_TOOLS = false in lua/plugins/typescript.lua
vim.lsp.enable({
  "lua_ls",
  "rust_analyzer",
  -- "vtsls",  -- Enable when using vtsls instead of typescript-tools
  -- "vue_ls",  -- Disabled - vtsls/typescript-tools handles Vue
  "elixirls",
  "bashls",
  "cssls",
  "jsonls",
  "kcl_lsp",
})

-- Server-specific settings
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
})

vim.lsp.config("rust_analyzer", {
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        allFeatures = true,
        loadOutDirsFromCheck = true,
        buildScripts = { enable = true },
      },
      checkOnSave = { command = "clippy" },
      procMacro = { enable = true },
    },
  },
})


vim.lsp.config("elixirls", {
  settings = {
    elixirls = {
      lint_on_save = true,
      format_on_save = true,
      use_dialyzer = true,
    },
  },
})

vim.lsp.config("bashls", {
  cmd = { "bash-language-server", "start" },
  filetypes = { "sh" },
  single_file_support = true,
  settings = {
    bashIde = {
      explainshellEndpoint = "https://explainshell.com",
      shellcheckPath = "shellcheck",
      globPattern = "**/*@(.sh|.inc|.bash|.command)",
    },
  },
})

vim.lsp.config("cssls", {
  filetypes = { "css", "scss", "less", "vue" },
  settings = {
    css = { validate = true },
    scss = { validate = true },
    less = { validate = true },
  },
})

vim.lsp.config("jsonls", {
  settings = {
    json = {
      schemas = require("schemastore").json.schemas(),
      validate = { enable = true },
    },
  },
})

-- vtsls configuration (only active when enabled in vim.lsp.enable above)
vim.lsp.config("vtsls", {
  filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact", "vue" },
  settings = {
    vtsls = {
      autoUseWorkspaceTsdk = false,
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
      preferences = { importModuleSpecifier = "relative" },
      inlayHints = {
        parameterNames = { enabled = "literals" },
        variableTypes = { enabled = true },
        propertyDeclarationTypes = { enabled = true },
        enumMemberValues = { enabled = true },
      },
    },
    javascript = {
      implicitProjectConfig = {
        checkJs = true,
        strictNullChecks = false,
        strictFunctionTypes = false,
      },
      lib = { "ES2020", "DOM" },
    },
  },
  handlers = {
    ["textDocument/publishDiagnostics"] = function(err, result, ctx)
      if result and result.diagnostics then
        local ignored = { [7047] = true, [7044] = true, [6133] = true }
        result.diagnostics = vim.tbl_filter(function(d)
          return not ignored[d.code]
        end, result.diagnostics)
      end
      return vim.lsp.handlers["textDocument/publishDiagnostics"](err, result, ctx)
    end,
  },
})

-- Install: download from https://github.com/KittyCAD/modeling-app/releases (kcl-language-server-x86_64-unknown-linux-gnu.gz)
vim.lsp.config("kcl_lsp", {
  cmd = { vim.fn.expand("~/.local/bin/kcl-language-server"), "server", "-s" },
  filetypes = { "kcl" },
  root_markers = { ".git" },
  single_file_support = true,
})

-- LspAttach autocmd removed - no longer needed with vtsls takeover mode
