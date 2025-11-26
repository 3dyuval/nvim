-- File operations utilities
local M = {}

-- Standard fff.nvim file picker with override
M.find_files = function()
  require("fff").find_files()
end

-- Snacks picker with fff.nvim backend
M.find_files_snacks = function()
  if _G.fff_snacks_picker then
    _G.fff_snacks_picker()
  else
    vim.notify("FFF Snacks picker not available", vim.log.levels.WARN)
    Snacks.picker.files()
  end
end

M.save_file = ":w<CR>"

M.save_and_stage_file = function()
  vim.cmd("write")
  local file = vim.fn.expand("%:p")
  if file ~= "" then
    vim.fn.system("git add " .. vim.fn.shellescape(file))
    vim.notify("Saved and staged: " .. vim.fn.expand("%:t"), vim.log.levels.INFO)
  end
end

-- Check if cursor is on an import module path string (not the import specifier/binding)
local function is_import_path()
  -- Use ignore_injections = false to get nodes from injected languages (e.g., TS in Vue)
  local node = vim.treesitter.get_node({ ignore_injections = false })
  if not node then
    return false
  end

  local node_type = node:type()
  -- Check if we're on the string part of an import (the module path)
  local string_types = { string = true, string_fragment = true }
  if string_types[node_type] then
    -- Verify it's inside an import statement
    local parent = node:parent()
    while parent do
      local parent_type = parent:type()
      if parent_type == "import_statement" or parent_type == "import_declaration" then
        return true
      end
      parent = parent:parent()
    end
  end
  return false
end

-- Resolve import path under cursor to actual file path using LSP definition
local function resolve_import_file(callback)
  local params = vim.lsp.util.make_position_params(0, "utf-16")
  vim.lsp.buf_request(0, "textDocument/definition", params, function(err, result)
    if err or not result or #result == 0 then
      callback(nil)
      return
    end
    local uri = result[1].uri or result[1].targetUri
    if uri then
      callback(vim.uri_to_fname(uri))
    else
      callback(nil)
    end
  end)
end

-- Smart rename: handles both symbol rename and file rename for import paths
M.smart_rename = function()
  -- Find client that supports rename
  local client
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    if c.server_capabilities.renameProvider then
      client = c
      break
    end
  end

  if not client then
    Snacks.rename.rename_file()
    return
  end

  local position_encoding = client.offset_encoding or "utf-16"
  local params = vim.lsp.util.make_position_params(0, position_encoding)

  client.request("textDocument/prepareRename", params, function(_, result)
    if result then
      -- Extract placeholder from prepareRename result
      local placeholder = result.placeholder or (result.range and vim.api.nvim_buf_get_text(
        0,
        result.range.start.line,
        result.range.start.character,
        result.range["end"].line,
        result.range["end"].character,
        {}
      )[1])
      vim.lsp.buf.rename(placeholder)
    elseif is_import_path() then
      resolve_import_file(function(file_path)
        if file_path then
          Snacks.rename.rename_file({ file = file_path })
        else
          Snacks.rename.rename_file()
        end
      end)
    else
      Snacks.rename.rename_file()
    end
  end, 0)
end

return M
