-- [nfnl] fnl/lsp/setup.fnl
local capabilities
do
  local ok, blink = pcall(require, "blink.cmp")
  if ok then
    capabilities = blink.get_lsp_capabilities({positionEncoding = "utf-8"}, true)
  else
    capabilities = vim.tbl_deep_extend("force", vim.lsp.protocol.make_client_capabilities(), {positionEncoding = "utf-8"})
  end
end
vim.lsp.config("*", {capabilities = capabilities, root_markers = {".git"}})
vim.lsp.enable({"lua_ls", "rust_analyzer", "vtsls", "vue_ls", "expert", "cssls", "jsonls", "kcl_lsp", "shuck", "fennel_ls"})
vim.lsp.config("lua_ls", {settings = {Lua = {runtime = {version = "LuaJIT"}, diagnostics = {globals = {"vim"}}, workspace = {checkThirdParty = false}, telemetry = {enable = false}}}})
vim.lsp.config("rust_analyzer", {settings = {["rust-analyzer"] = {cargo = {allFeatures = true, loadOutDirsFromCheck = true, buildScripts = {enable = true}}, checkOnSave = {command = "clippy"}, procMacro = {enable = true}}}})
local vue_plugin_location = (vim.fn.stdpath("data") .. "/mason/packages/vue-language-server/node_modules/@vue/language-server")
local ignored_diag_codes = {[7047] = true, [7044] = true, [6133] = true}
local function _2_(err, result, ctx)
  if (result and result.diagnostics) then
    local function _3_(d)
      return not ignored_diag_codes[d.code]
    end
    result.diagnostics = vim.tbl_filter(_3_, result.diagnostics)
  else
  end
  return vim.lsp.handlers["textDocument/publishDiagnostics"](err, result, ctx)
end
local function _5_(err, result, ctx, config)
  local result0
  if (result and (vim.bo[ctx.bufnr].filetype == "vue")) then
    local function _6_(sym)
      local n = sym.name
      return not ((n == "import") or (n == "from") or (n == "export") or vim.startswith(n, "import ") or vim.startswith(n, "script"))
    end
    result0 = vim.tbl_filter(_6_, result)
  else
    result0 = result
  end
  return vim.lsp.handlers["textDocument/documentSymbol"](err, result0, ctx, config)
end
vim.lsp.config("vtsls", {filetypes = {"typescript", "typescriptreact", "javascript", "javascriptreact", "vue"}, settings = {vtsls = {tsserver = {globalPlugins = {{name = "@vue/typescript-plugin", location = vue_plugin_location, languages = {"vue"}, configNamespace = "typescript"}}}, autoUseWorkspaceTsdk = false}, typescript = {preferences = {importModuleSpecifier = "relative"}, inlayHints = {parameterNames = {enabled = "literals"}, variableTypes = {enabled = true}, propertyDeclarationTypes = {enabled = true}, enumMemberValues = {enabled = true}}}, javascript = {implicitProjectConfig = {checkJs = true, strictFunctionTypes = false, strictNullChecks = false}, lib = {"ES2020", "DOM"}}}, handlers = {["textDocument/publishDiagnostics"] = _2_, ["textDocument/documentSymbol"] = _5_}})
local function _8_(client)
  for _, cap in ipairs({"renameProvider", "documentSymbolProvider", "referencesProvider", "codeActionProvider", "definitionProvider", "implementationProvider", "typeDefinitionProvider", "hoverProvider"}) do
    client.server_capabilities[cap] = false
  end
  return nil
end
vim.lsp.config("vue_ls", {filetypes = {"vue"}, init_options = {vue = {hybridMode = true}}, settings = {vue = {complete = {casing = {tags = "kebab", props = "kebab"}}}}, on_init = _8_})
vim.lsp.config("shuck", {cmd = {"shuck", "server", "--config", (vim.fn.stdpath("config") .. "/formatters/shuck.toml")}})
vim.lsp.config("cssls", {filetypes = {"css", "scss", "less"}, settings = {css = {validate = true}, scss = {validate = true}, less = {validate = true}}})
vim.lsp.config("jsonls", {settings = {json = {schemas = require("schemastore").json.schemas(), validate = {enable = true}}}})
vim.lsp.config("kcl_lsp", {cmd = {vim.fn.expand("~/.local/bin/kcl-language-server"), "server", "-s"}, filetypes = {"kcl"}, root_markers = {".git"}, single_file_support = true})
local lsp_nudges = {["<leader>cr"] = "grn  (rename)", ["<leader>cR"] = "grr  (references)", ["<leader>ca"] = "gra  (code action)", gD = "grt  (go to definition)", gR = "grr  (references)"}
for lhs, target in pairs(lsp_nudges) do
  local function _9_()
    return vim.notify(("Deprecated keymap \226\128\148 use " .. target), vim.log.levels.WARN, {title = "LSP keymap moved"})
  end
  vim.keymap.set("n", lhs, _9_, {desc = ("moved -> " .. target), silent = true})
end
local function goto_definition_first()
  local function _10_(o)
    local it = o.items[1]
    if it then
      vim.fn.setqflist({}, " ", {title = o.title, items = {it}})
      return vim.cmd("cfirst")
    else
      return nil
    end
  end
  return vim.lsp.buf.definition({on_list = _10_})
end
vim.keymap.set("n", "grt", goto_definition_first, {desc = "Go to definition (first)"})
vim.keymap.set("n", "grT", vim.lsp.buf.definition, {desc = "Go to definition (list)"})
local function _12_()
  if (vim.bo.filetype == "vue") then
    return require("lsp.vue-symbols").pick("bottom")
  else
    return require("snacks").picker.lsp_symbols({layout = "bottom"})
  end
end
vim.keymap.set("n", "grs", _12_, {desc = "Symbols"})
vim.diagnostic.config({underline = true, severity_sort = true, virtual_text = {spacing = 4, source = "if_many", prefix = "\226\151\143"}, signs = {text = {[vim.diagnostic.severity.ERROR] = " ", [vim.diagnostic.severity.WARN] = " ", [vim.diagnostic.severity.HINT] = " ", [vim.diagnostic.severity.INFO] = " "}}, update_in_insert = false})
local function _14_(ev)
  local client = vim.lsp.get_client_by_id(ev.data.client_id)
  local buf = ev.buf
  if (client and client:supports_method("textDocument/inlayHint") and (vim.bo[buf].buftype == "") and (vim.bo[buf].filetype ~= "vue")) then
    return vim.lsp.inlay_hint.enable(true, {bufnr = buf})
  else
    return nil
  end
end
vim.api.nvim_create_autocmd("LspAttach", {callback = _14_})
local function _16_()
  return require("utils.files").smart_references()
end
vim.keymap.set("n", "<leader>cx", _16_, {desc = "Smart References"})
return vim.keymap.set("n", "<leader>cL", "<cmd>LspInfo<cr>", {desc = "LSP Info"})
