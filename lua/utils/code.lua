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

-- ============================================================================
-- FENCED CODE BLOCK API
-- ============================================================================

--- Find the fenced_code_block node at cursor position
---@return TSNode|nil node, number|nil bufnr
M.find_fence_at_cursor = function()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local bufnr = vim.api.nvim_get_current_buf()

  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok or not parser then
    return nil, nil
  end

  local block = nil
  parser:for_each_tree(function(tree, ltree)
    if block or ltree:lang() ~= "markdown" then
      return
    end
    local query = vim.treesitter.query.parse("markdown", "(fenced_code_block) @block")
    for _, node in query:iter_captures(tree:root(), bufnr) do
      local sr, _, er, _ = node:range()
      if row > sr and row <= er + 1 then
        block = node
        return
      end
    end
  end)

  return block, bufnr
end

--- Get the language type from a fence node
---@param node TSNode
---@param bufnr? number
---@return string|nil
M.get_fence_type = function(node, bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  for child in node:iter_children() do
    if child:type() == "info_string" then
      return vim.treesitter.get_node_text(child, bufnr)
    end
  end
  return nil
end

--- Select fenced code block inner content (linewise)
M.select_fenced_code_block_inner = function()
  local node, _ = M.find_fence_at_cursor()
  if not node then
    vim.notify("Not inside a code block", vim.log.levels.WARN)
    return
  end
  local sr, _, er, _ = node:range() -- 0-based, er is exclusive (past last row)
  -- Inner: skip opening fence, exclude closing fence
  -- 1-based: first content line = sr+2, last content line = er-1
  vim.api.nvim_win_set_cursor(0, { sr + 2, 0 })
  vim.cmd("normal! V")
  vim.api.nvim_win_set_cursor(0, { er - 1, 0 })
end

--- Select fenced code block including fences (linewise)
M.select_fenced_code_block_around = function()
  local node, _ = M.find_fence_at_cursor()
  if not node then
    vim.notify("Not inside a code block", vim.log.levels.WARN)
    return
  end
  local sr, _, er, _ = node:range() -- 0-based, er is exclusive (past last row)
  -- Around: all lines, 1-based: sr+1 to er (er is already 1-based equivalent)
  vim.api.nvim_win_set_cursor(0, { sr + 1, 0 })
  vim.cmd("normal! V")
  vim.api.nvim_win_set_cursor(0, { er, 0 })
end

--- Change or add fence type (language) for code block at cursor
---@param new_type string|nil The new language type, or nil to prompt
M.change_or_add_fence_type = function(new_type)
  local node, bufnr = M.find_fence_at_cursor()
  if not node then
    vim.notify("Not inside a code block", vim.log.levels.WARN)
    return
  end

  if not new_type then
    local current = M.get_fence_type(node, bufnr) or ""
    new_type = vim.fn.input("Fence type: ", current)
    if new_type == "" then
      return
    end
  end

  local sr = node:range() -- 0-based
  local lines = vim.api.nvim_buf_get_lines(bufnr, sr, sr + 1, false)
  local new_line = lines[1]:gsub("^(```)[%w%-]*", "%1" .. new_type)
  vim.api.nvim_buf_set_lines(bufnr, sr, sr + 1, false, { new_line })
end

--- Create a new empty fence and position cursor inside
---@param fence_type string|nil The language type, or nil to prompt
M.create_fence = function(fence_type)
  if not fence_type then
    fence_type = vim.fn.input("Language: ")
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1 -- 0-indexed

  -- Insert fence lines: ```{type}, empty line, ```
  local lines = { "```" .. (fence_type or ""), "", "```" }
  vim.api.nvim_buf_set_lines(bufnr, row, row, false, lines)

  -- Move cursor to the empty line inside the fence and enter insert mode
  vim.api.nvim_win_set_cursor(0, { row + 2, 0 })
  vim.cmd("startinsert")
end

return M
