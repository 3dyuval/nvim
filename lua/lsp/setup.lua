-- [nfnl] fnl/lsp/setup.fnl
vim.lsp.config("*", {capabilities = {positionEncoding = "utf-8"}, root_markers = {".git"}})
vim.lsp.enable({"lua_ls", "rust_analyzer", "vtsls", "vue_ls", "elixirls", "bashls", "cssls", "jsonls", "kcl_lsp"})
vim.lsp.config("lua_ls", {settings = {Lua = {runtime = {version = "LuaJIT"}, diagnostics = {globals = {"vim"}}, workspace = {checkThirdParty = false}, telemetry = {enable = false}}}})
vim.lsp.config("rust_analyzer", {settings = {["rust-analyzer"] = {cargo = {allFeatures = true, loadOutDirsFromCheck = true, buildScripts = {enable = true}}, checkOnSave = {command = "clippy"}, procMacro = {enable = true}}}})
local vue_plugin_location = (vim.fn.stdpath("data") .. "/mason/packages/vue-language-server/node_modules/@vue/language-server")
local ignored_diag_codes = {[7047] = true, [7044] = true, [6133] = true}
local function _1_(err, result, ctx)
  if (result and result.diagnostics) then
    local function _2_(d)
      return not ignored_diag_codes[d.code]
    end
    result.diagnostics = vim.tbl_filter(_2_, result.diagnostics)
  else
  end
  return vim.lsp.handlers["textDocument/publishDiagnostics"](err, result, ctx)
end
local function _4_(err, result, ctx, config)
  local result0
  if (result and (vim.bo[ctx.bufnr].filetype == "vue")) then
    local function _5_(sym)
      local n = sym.name
      return not ((n == "import") or (n == "from") or (n == "export") or vim.startswith(n, "import ") or vim.startswith(n, "script"))
    end
    result0 = vim.tbl_filter(_5_, result)
  else
    result0 = result
  end
  return vim.lsp.handlers["textDocument/documentSymbol"](err, result0, ctx, config)
end
vim.lsp.config("vtsls", {filetypes = {"typescript", "typescriptreact", "javascript", "javascriptreact", "vue"}, settings = {vtsls = {tsserver = {globalPlugins = {{name = "@vue/typescript-plugin", location = vue_plugin_location, languages = {"vue"}, configNamespace = "typescript"}}}, autoUseWorkspaceTsdk = false}, typescript = {preferences = {importModuleSpecifier = "relative"}, inlayHints = {parameterNames = {enabled = "literals"}, variableTypes = {enabled = true}, propertyDeclarationTypes = {enabled = true}, enumMemberValues = {enabled = true}}}, javascript = {implicitProjectConfig = {checkJs = true, strictFunctionTypes = false, strictNullChecks = false}, lib = {"ES2020", "DOM"}}}, handlers = {["textDocument/publishDiagnostics"] = _1_, ["textDocument/documentSymbol"] = _4_}})
local function _7_(client)
  client.server_capabilities.renameProvider = false
  client.server_capabilities.documentSymbolProvider = false
  return nil
end
vim.lsp.config("vue_ls", {filetypes = {"vue"}, init_options = {vue = {hybridMode = true}}, settings = {vue = {complete = {casing = {tags = "kebab", props = "kebab"}}}}, on_init = _7_})
vim.lsp.config("elixirls", {settings = {elixirls = {lint_on_save = true, format_on_save = true, use_dialyzer = true}}})
vim.lsp.config("bashls", {cmd = {"bash-language-server", "start"}, filetypes = {"sh"}, single_file_support = true, settings = {bashIde = {explainshellEndpoint = "https://explainshell.com", shellcheckPath = "shellcheck", globPattern = "**/*@(.sh|.inc|.bash|.command)"}}})
vim.lsp.config("cssls", {filetypes = {"css", "scss", "less"}, settings = {css = {validate = true}, scss = {validate = true}, less = {validate = true}}})
vim.lsp.config("jsonls", {settings = {json = {schemas = require("schemastore").json.schemas(), validate = {enable = true}}}})
return vim.lsp.config("kcl_lsp", {cmd = {vim.fn.expand("~/.local/bin/kcl-language-server"), "server", "-s"}, filetypes = {"kcl"}, root_markers = {".git"}, single_file_support = true})
