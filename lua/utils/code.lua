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

-- ============================================================================
-- SELF-CLOSING TAG API (HTML/JSX)
-- ============================================================================

-- Self-closing tag node types by language
local self_closing_types = {
  self_closing_tag = true, -- HTML/Vue
  jsx_self_closing_element = true, -- TSX/JSX
}

--- Find the self_closing_tag node at cursor position
---@return TSNode|nil node, number|nil bufnr
M.find_self_closing_tag_at_cursor = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1] - 1, cursor[2] -- 0-based

  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok or not parser then
    return nil, nil
  end

  -- Parse all trees (important for multi-language files)
  parser:parse(true)

  -- Try vim.treesitter.get_node first (works in normal usage)
  local node = vim.treesitter.get_node({ bufnr = bufnr, pos = { row, col } })

  -- Walk up to find self-closing tag
  while node do
    if self_closing_types[node:type()] then
      return node, bufnr
    end
    node = node:parent()
  end

  -- Fallback: manually search trees for self-closing tag at position
  -- (needed when get_node returns nil, e.g., in headless tests)
  local found = nil

  local function find_at_pos(n)
    if found then
      return
    end
    -- Check if this is a self-closing tag
    if self_closing_types[n:type()] then
      local sr, sc, er, ec = n:range()
      -- Check if cursor is within this node's range
      local in_row = row >= sr and row <= er
      local in_col = (row > sr or col >= sc) and (row < er or col < ec)
      if in_row and in_col then
        found = n
        return
      end
    end
    -- Always recurse into children (don't prune based on range)
    for child in n:iter_children() do
      find_at_pos(child)
    end
  end

  -- Get all trees and search each one
  local trees = parser:trees()
  for _, tree in ipairs(trees) do
    find_at_pos(tree:root())
    if found then
      return found, bufnr
    end
  end

  return nil, nil
end

--- Select self-closing tag at cursor (visual mode)
M.select_self_closing_tag = function()
  local node, _ = M.find_self_closing_tag_at_cursor()
  if not node then
    return
  end

  local sr, sc, er, ec = node:range() -- 0-based, ec is exclusive
  vim.api.nvim_buf_set_mark(0, "<", sr + 1, sc, {})
  vim.api.nvim_buf_set_mark(0, ">", er + 1, ec - 1, {})
  vim.cmd("normal! gv")
end

return M
