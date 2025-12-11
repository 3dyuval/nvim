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

-- LSP SymbolKind numbers to names
local kind_names = {
  "File",
  "Module",
  "Namespace",
  "Package",
  "Class",
  "Method",
  "Property",
  "Field",
  "Constructor",
  "Enum",
  "Interface",
  "Function",
  "Variable",
  "Constant",
  "String",
  "Number",
  "Boolean",
  "Array",
  "Object",
  "Key",
  "Null",
  "EnumMember",
  "Struct",
  "Event",
  "Operator",
  "TypeParameter",
}

--- Get the current code path/context from navic
---@param opts? { with_types?: boolean } Options: with_types prefixes each item with its type name
M.get_code_path = function(opts)
  opts = opts or {}
  local navic = require("nvim-navic")
  -- NOTE current lsp must support documentSymbolProvider.
  if navic.is_available() then
    local data = navic.get_data()
    if data and #data > 0 then
      local parts = {}
      for _, item in ipairs(data) do
        if opts.with_types then
          local kind = kind_names[item.kind] or "Unknown"
          table.insert(parts, kind .. " " .. item.name)
        else
          table.insert(parts, item.name)
        end
      end
      return table.concat(parts, " > ")
    end
  end
  vim.notify("No code context available", vim.log.levels.WARN)
end

M.set_buffer_file_type_with_lsp = function(ft)
  vim.bo.filetype = ft
end

--- Select fenced code block (works from inside injected language)
---@param inner boolean If true, select inner content only; if false, include fences
M.select_fenced_code_block = function(inner)
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local bufnr = vim.api.nvim_get_current_buf()

  -- Try to get markdown parser (may be the root or we need to find it)
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok or not parser then
    return
  end

  -- Find fenced_code_block containing cursor
  local function find_code_block(tree_root, lang)
    if lang ~= "markdown" then
      return nil
    end

    local query = vim.treesitter.query.parse("markdown", "(fenced_code_block) @block")
    for _, node in query:iter_captures(tree_root, bufnr) do
      local sr, _, er, _ = node:range()
      -- range is 0-indexed, row is 1-indexed
      if row > sr and row <= er + 1 then
        return node
      end
    end
    return nil
  end

  -- Check all trees (markdown might be root or injected)
  local block = nil
  parser:for_each_tree(function(tree, ltree)
    if not block then
      block = find_code_block(tree:root(), ltree:lang())
    end
  end)

  if not block then
    vim.notify("Not inside a code block", vim.log.levels.WARN)
    return
  end

  local sr, sc, er, ec = block:range()
  local start_row, end_row
  if inner then
    -- Select content only (skip opening and closing fence lines)
    start_row = sr + 2 -- skip ```lang line
    end_row = er -- exclude closing ``` line
  else
    -- Select entire block including fences
    start_row = sr + 1
    end_row = er + 1
  end

  -- Use visual line mode for selection
  vim.cmd("normal! " .. start_row .. "GV" .. end_row .. "G")
end

return M
