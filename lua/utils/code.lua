-- Code utilities (TypeScript/JavaScript)
-- Uses vtsls LSP commands and code actions
local M = {}

-- Helper to run LSP code action by kind
local function lsp_action(kind)
  vim.lsp.buf.code_action({
    apply = true,
    context = { only = { kind }, diagnostics = {} },
  })
end

-- Helper to execute vtsls command with current file path
local function vtsls_cmd(command)
  local filepath = vim.api.nvim_buf_get_name(0)
  vim.lsp.buf.execute_command({
    command = command,
    arguments = { filepath },
  })
end

-- vtsls commands for import management (take filePath argument)
M.organize_imports = function()
  vtsls_cmd("typescript.organizeImports")
end

M.remove_unused_imports = function()
  vtsls_cmd("typescript.removeUnusedImports")
end

-- Code actions for source fixes
M.add_missing_imports = function()
  lsp_action("source.addMissingImports.ts")
end

M.fix_all = function()
  lsp_action("source.fixAll.ts")
end

M.organize_imports_and_fix = function()
  vtsls_cmd("typescript.organizeImports")
  vim.schedule(function()
    vtsls_cmd("typescript.removeUnusedImports")
    vim.schedule(function()
      lsp_action("source.fixAll.ts")
    end)
  end)
end

-- vtsls commands (workspace/executeCommand)
M.select_ts_version = function()
  vim.lsp.buf.execute_command({ command = "typescript.selectTypeScriptVersion" })
end

M.go_to_source_definition = function()
  local params = vim.lsp.util.make_position_params()
  vim.lsp.buf.execute_command({
    command = "typescript.goToSourceDefinition",
    arguments = { params.textDocument.uri, params.position },
  })
end

M.file_references = function()
  local uri = vim.uri_from_bufnr(0)
  vim.lsp.buf.execute_command({
    command = "typescript.findAllFileReferences",
    arguments = { uri },
  })
end

M.get_code_path = function()
  local navic = require("nvim-navic")
  -- NOTE current lsp must support documentSymbolProvider.
  if navic.is_available() then
    local location = navic.get_location()
    if location and location ~= "" then
      return location
    end
  end
  vim.notify("No code context available", vim.log.levels.WARN)
end

M.set_buffer_file_type_with_lsp = function(ft)
  vim.bo.filetype = ft
end

return M
