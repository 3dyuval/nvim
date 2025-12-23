-- File operations utilities
local M = {}

-- Find files from git root using fff.nvim
M.find_files = function()
  require("fff").find_in_git_root()
end

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

-- ============================================================================
-- GITIGNORE PARSING & PICKER ARGS
-- ============================================================================

-- Default patterns to always exclude (large/irrelevant directories)
local default_excludes = {
  ".git",
  "node_modules",
  "dist",
  "build",
  "coverage",
  ".cache",
  ".next",
  ".nuxt",
  "vendor",
  "__pycache__",
  "*.pyc",
  "target", -- Rust
}

-- Parse .gitignore file and return list of patterns
-- Skips comments, empty lines, and negation patterns (lines starting with !)
local function parse_gitignore(gitignore_path)
  if not gitignore_path or vim.fn.filereadable(gitignore_path) == 0 then
    return {}
  end

  local patterns = {}
  local lines = vim.fn.readfile(gitignore_path)

  for _, line in ipairs(lines) do
    -- Trim whitespace
    line = line:match("^%s*(.-)%s*$")
    -- Skip empty lines, comments, and negation patterns
    if line ~= "" and not line:match("^#") and not line:match("^!") then
      table.insert(patterns, line)
    end
  end

  return patterns
end

-- Find closest .gitignore file walking up from cwd
local function find_gitignore()
  local found = vim.fs.find(".gitignore", { upward = true, path = vim.fn.getcwd() })
  return found[1]
end

-- Build fd args with gitignore patterns
-- @param opts table|nil { use_gitignore: boolean, extra_excludes: string[] }
M.build_fd_args = function(opts)
  opts = opts or {}
  local use_gitignore = opts.use_gitignore ~= false -- default true

  local args = {
    "--color=never",
    "--type",
    "f",
    "--type",
    "l",
    "--hidden",
    "--follow",
    "--no-ignore", -- We handle excludes manually to allow *.local.* files
  }

  -- Add default excludes
  for _, pattern in ipairs(default_excludes) do
    table.insert(args, "--exclude")
    table.insert(args, pattern)
  end

  -- Add extra excludes from opts
  if opts.extra_excludes then
    for _, pattern in ipairs(opts.extra_excludes) do
      table.insert(args, "--exclude")
      table.insert(args, pattern)
    end
  end

  -- Parse and add gitignore patterns
  if use_gitignore then
    local gitignore = find_gitignore()
    local patterns = parse_gitignore(gitignore)
    for _, pattern in ipairs(patterns) do
      -- Skip patterns that match *.local.* (we want those visible)
      if not pattern:match("%.local%.") then
        table.insert(args, "--exclude")
        table.insert(args, pattern)
      end
    end
  end

  return args
end

-- Build rg args with gitignore patterns
-- @param opts table|nil { use_gitignore: boolean, extra_excludes: string[] }
M.build_rg_args = function(opts)
  opts = opts or {}
  local use_gitignore = opts.use_gitignore ~= false -- default true

  local args = {
    "--color=never",
    "--no-heading",
    "--with-filename",
    "--line-number",
    "--column",
    "--smart-case",
    "--hidden",
    "--no-ignore", -- We handle excludes manually to allow *.local.* files
  }

  -- Add default excludes (rg uses --glob with ! prefix)
  for _, pattern in ipairs(default_excludes) do
    table.insert(args, "--glob")
    -- Add /* suffix for directories if not already a glob pattern
    if not pattern:match("%*") then
      table.insert(args, "!" .. pattern .. "/*")
    else
      table.insert(args, "!" .. pattern)
    end
  end

  -- Add extra excludes from opts
  if opts.extra_excludes then
    for _, pattern in ipairs(opts.extra_excludes) do
      table.insert(args, "--glob")
      if not pattern:match("%*") then
        table.insert(args, "!" .. pattern .. "/*")
      else
        table.insert(args, "!" .. pattern)
      end
    end
  end

  -- Parse and add gitignore patterns
  if use_gitignore then
    local gitignore = find_gitignore()
    local patterns = parse_gitignore(gitignore)
    for _, pattern in ipairs(patterns) do
      -- Skip patterns that match *.local.* (we want those visible)
      if not pattern:match("%.local%.") then
        table.insert(args, "--glob")
        if not pattern:match("%*") then
          table.insert(args, "!" .. pattern .. "/*")
        else
          table.insert(args, "!" .. pattern)
        end
      end
    end
  end

  return args
end

-- ============================================================================
-- SMART REFERENCES
-- ============================================================================

local function show_references_picker(results)
  if not results or #results == 0 then
    vim.notify("No references found", vim.log.levels.INFO)
    return
  end

  local items = {}
  for i, ref in ipairs(results) do
    local uri = ref.uri or ref.targetUri
    local filename = vim.fn.fnamemodify(vim.uri_to_fname(uri), ":~:.")
    local line_num = ref.range.start.line + 1
    local col_num = ref.range.start.character + 1

    local line_content = ""
    local bufnr = vim.uri_to_bufnr(uri)
    if vim.api.nvim_buf_is_loaded(bufnr) then
      line_content = vim.api.nvim_buf_get_lines(bufnr, ref.range.start.line, ref.range.start.line + 1, false)[1] or ""
    end

    table.insert(items, {
      file = vim.uri_to_fname(uri),
      text = string.format("%s:%d:%d %s", filename, line_num, col_num, line_content:gsub("^%s+", "")),
      pos = { line_num, col_num },
      idx = i,
      score = 1,
    })
  end

  local picker_ext = require("utils.picker-extensions")
  Snacks.picker({
    name = "references",
    items = items,
    layout = { preset = "default" },
    format = "file",
    preview = "file",
    actions = {
      confirm = function(p, item)
        p:close()
        vim.cmd("edit " .. item.file)
        if item.pos then
          vim.api.nvim_win_set_cursor(0, { item.pos[1], item.pos[2] - 1 })
        end
      end,
      copy_file_path = {
        action = function(p, item)
          picker_ext.copy_file_path(p, item)
        end,
      },
    },
    win = {
      input = { keys = { ["p"] = "copy_file_path" } },
      list = { keys = { ["p"] = "copy_file_path" } },
    },
    focus = "list",
  })
end

local function request_references(callback)
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })

  if #clients == 0 then
    vim.notify("No LSP clients attached to buffer", vim.log.levels.WARN)
    return
  end

  local params = vim.lsp.util.make_position_params(0, "utf-16")
  params.context = { includeDeclaration = true }

  vim.lsp.buf_request(bufnr, "textDocument/references", params, function(err, result)
    if err then
      vim.notify("References error: " .. tostring(err), vim.log.levels.ERROR)
      return
    end
    if not result or #result == 0 then
      vim.notify("No references found", vim.log.levels.INFO)
      return
    end
    callback(result)
  end)
end

-- Get file path to use for references when no symbol under cursor
-- Checks: 1) Snacks explorer item, 2) Current buffer filename
local function get_fallback_file()
  local ft = vim.bo.filetype

  -- Check if in Snacks picker/explorer
  if ft == "snacks_picker_list" then
    local pickers = Snacks.picker.get()
    if pickers and #pickers > 0 then
      local picker = pickers[1]
      local item = picker:current()
      if item and item.file and vim.fn.filereadable(item.file) == 1 then
        return item.file
      end
    end
  end

  -- Fallback to current buffer filename
  local bufname = vim.api.nvim_buf_get_name(0)
  if bufname ~= "" and vim.fn.filereadable(bufname) == 1 then
    return bufname
  end

  return nil
end

-- Find references to a file by opening it and requesting references at first line
local function find_file_references(file_path)
  vim.cmd("edit " .. file_path)
  vim.schedule(function()
    request_references(show_references_picker)
  end)
end

-- Check if cursor is on a renameable symbol (uses LSP prepareRename under the hood)
local function has_symbol_under_cursor(callback)
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })

  local client
  for _, c in ipairs(clients) do
    if c.server_capabilities.renameProvider then
      client = c
      break
    end
  end

  if not client then
    callback(true) -- No way to check, assume yes
    return
  end

  local position_encoding = client.offset_encoding or "utf-16"
  local params = vim.lsp.util.make_position_params(0, position_encoding)

  client.request("textDocument/prepareRename", params, function(_, result)
    callback(result ~= nil)
  end, bufnr)
end

-- Smart references: symbol under cursor → import path → explorer item → current file
M.smart_references = function()
  if is_import_path() then
    resolve_import_file(function(file_path)
      if file_path then
        find_file_references(file_path)
      else
        request_references(show_references_picker)
      end
    end)
    return
  end

  has_symbol_under_cursor(function(has_symbol)
    if has_symbol then
      request_references(show_references_picker)
    else
      local fallback_file = get_fallback_file()
      if fallback_file then
        find_file_references(fallback_file)
      else
        vim.notify("No symbol or file to find references for", vim.log.levels.INFO)
      end
    end
  end)
end

-- ============================================================================
-- SMART RENAME
-- ============================================================================

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

  client.request("textDocument/prepareRename", params, function(err, result)
    if result then
      -- Extract placeholder from prepareRename result
      local placeholder = result.placeholder
        or (
          result.range
          and vim.api.nvim_buf_get_text(
            0,
            result.range.start.line,
            result.range.start.character,
            result.range["end"].line,
            result.range["end"].character,
            {}
          )[1]
        )
      vim.lsp.buf.rename(placeholder)
    elseif err == nil and client.server_capabilities.renameProvider then
      -- prepareRename returned nil but client supports rename (e.g., lua_ls)
      vim.lsp.buf.rename()
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
