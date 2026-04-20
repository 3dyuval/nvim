-- Global capabilities for all servers
vim.lsp.config('*', {
  capabilities = {
    positionEncoding = 'utf-8',
  },
  root_markers = { '.git' },
})

-- Enable all your servers
vim.lsp.enable({
  'lua_ls', 'rust_analyzer', 'vtsls', 'vue_ls', 'elixirls', 'bashls', 'cssls',
})

-- Server-specific settings
vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      diagnostics = { globals = { 'vim' } },
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
})

vim.lsp.config('rust_analyzer', {
  settings = {
    ['rust-analyzer'] = {
      cargo = {
        allFeatures = true,
        loadOutDirsFromCheck = true,
        buildScripts = { enable = true },
      },
      checkOnSave = { command = 'clippy' },
      procMacro = { enable = true },
    },
  },
})

vim.lsp.config('vtsls', {
  filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact', 'vue' },
  settings = {
    vtsls = {
      autoUseWorkspaceTsdk = false,
      tsserver = {
        globalPlugins = {
          {
            name = '@vue/typescript-plugin',
            location = vim.fn.stdpath('data') .. '/mason/packages/vue-language-server/node_modules/@vue/language-server',
            languages = { 'vue' },
            configNamespace = 'typescript',
          },
        },
      },
    },
    typescript = {
      preferences = { importModuleSpecifier = 'relative' },
      inlayHints = {
        parameterNames = { enabled = 'literals' },
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
      lib = { 'ES2020', 'DOM' },
    },
  },
  -- Filter diagnostics (replaces your init handler)
  handlers = {
    ['textDocument/publishDiagnostics'] = function(err, result, ctx)
      if result and result.diagnostics then
        local ignored = { [7047] = true, [7044] = true, [6133] = true }
        result.diagnostics = vim.tbl_filter(function(d)
          return not ignored[d.code]
        end, result.diagnostics)
      end
      return vim.lsp.handlers['textDocument/publishDiagnostics'](err, result, ctx)
    end,
  },
})

vim.lsp.config('vue_ls', {
  filetypes = { 'vue' },
  init_options = { vue = { hybridMode = true } },
  settings = {
    vue = {
      complete = {
        casing = { tags = 'kebab', props = 'kebab' },
      },
    },
  },
})

vim.lsp.config('elixirls', {
  settings = {
    elixirls = {
      lint_on_save = true,
      format_on_save = true,
      use_dialyzer = true,
    },
  },
})

vim.lsp.config('bashls', {
  cmd = { 'bash-language-server', 'start' },
  filetypes = { 'sh' },
  single_file_support = true,
  settings = {
    bashIde = {
      explainshellEndpoint = 'https://explainshell.com',
      shellcheckPath = 'shellcheck',
      globPattern = '**/*@(.sh|.inc|.bash|.command)',
    },
  },
})

vim.lsp.config('cssls', {
  filetypes = { 'css', 'scss', 'less', 'vue' },
  settings = {
    css = { validate = true },
    scss = { validate = true },
    less = { validate = true },
  },
})

-- Disable vue_ls rename in hybrid mode
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client.name == 'vue_ls' then
      client.server_capabilities.renameProvider = false
    end
  end,
})
