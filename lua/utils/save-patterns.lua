local M = {}

-- Save patterns configuration
M.patterns = {
  typescript = {
    filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    extensions = { "*.ts", "*.tsx", "*.js", "*.jsx" },
    actions = {
      {
        name = "organize_imports",
        desc = "Organize imports",
        fn = function(bufnr)
          -- Use LSP organize imports directly
          if LazyVim and LazyVim.lsp and LazyVim.lsp.action then
            local organize_imports = LazyVim.lsp.action["source.organizeImports"]
            if organize_imports and type(organize_imports) == "function" then
              pcall(organize_imports)
            end
          end
        end,
      },
      -- {
      --   name = "format",
      --   desc = "Format with conform",
      --   (deleted- already being handled by lazy)
    },
  },
  lua = {
    filetypes = { "lua" },
    extensions = { "*.lua" },
    actions = {
      {
        name = "format",
        desc = "Format with stylua",
        fn = function(bufnr)
          -- Use LazyVim's formatting system instead of direct conform calls
          if LazyVim and LazyVim.format then
            LazyVim.format({ buf = bufnr })
          else
            -- Fallback to direct conform if LazyVim not available
            local conform = require("conform")
            conform.format({ bufnr = bufnr, async = false })
          end
        end,
      },
    },
  },
  json = {
    filetypes = { "json", "jsonc" },
    extensions = { "*.json", "*.jsonc" },
    actions = {
      {
        name = "format",
        desc = "Format with biome",
        fn = function(bufnr)
          -- Use LazyVim's formatting system instead of direct conform calls
          if LazyVim and LazyVim.format then
            LazyVim.format({ buf = bufnr })
          else
            -- Fallback to direct conform if LazyVim not available
            local conform = require("conform")
            conform.format({ bufnr = bufnr, async = false })
          end
        end,
      },
    },
  },
}

-- Get patterns for a specific filetype
function M.get_patterns_for_filetype(filetype)
  for _, pattern in pairs(M.patterns) do
    if vim.tbl_contains(pattern.filetypes, filetype) then
      return pattern
    end
  end
  return nil
end

-- Get patterns for a file path
function M.get_patterns_for_file(filepath)
  for _, pattern in pairs(M.patterns) do
    for _, ext in ipairs(pattern.extensions) do
      if vim.fn.fnamemodify(filepath, ":t"):match(ext:gsub("%*", ".*")) then
        return pattern
      end
    end
  end
  return nil
end

-- Run save patterns for current buffer
function M.run_for_current_buffer()
  local bufnr = vim.api.nvim_get_current_buf()
  local filetype = vim.bo[bufnr].filetype
  local filepath = vim.api.nvim_buf_get_name(bufnr)

  local patterns = M.get_patterns_for_filetype(filetype) or M.get_patterns_for_file(filepath)
  if not patterns then
    vim.notify("No save patterns configured for " .. filetype, vim.log.levels.INFO)
    return
  end

  M.run_patterns(bufnr, patterns)
end

-- Run save patterns for a specific buffer
function M.run_patterns(bufnr, patterns)
  if not patterns or not patterns.actions then
    return
  end

  local filepath = vim.api.nvim_buf_get_name(bufnr)
  local filename = vim.fn.fnamemodify(filepath, ":t")

  for _, action in ipairs(patterns.actions) do
    local ok, err = pcall(action.fn, bufnr)
    if not ok then
      vim.notify(string.format("Save pattern '%s' failed for %s: %s", action.name, filename, err), vim.log.levels.WARN)
    end
  end
end

-- Run save patterns on multiple files via picker
function M.run_on_multiple_files()
  local picker = Snacks.picker.files({
    prompt = "Select files to run save patterns on (Tab to select multiple, Enter to process)",
  })

  -- Override the confirm action
  picker.opts.win = picker.opts.win or {}
  picker.opts.win.list = picker.opts.win.list or {}
  picker.opts.win.list.keys = picker.opts.win.list.keys or {}

  picker.opts.win.list.keys["<CR>"] = function(self)
    local items = self:selected()
    if #items == 0 then
      local current = self:current()
      if current then
        items = { current }
      end
    end

    if #items == 0 then
      vim.notify("No files selected", vim.log.levels.WARN)
      return
    end

    local processed = 0
    local total = #items

    for _, item in ipairs(items) do
      local filepath = item.file
      if filepath and vim.fn.filereadable(filepath) == 1 then
        -- Open file in a buffer temporarily
        local bufnr = vim.fn.bufnr(filepath, true)
        vim.fn.bufload(bufnr)

        -- Get filetype
        local filetype = vim.filetype.match({ filename = filepath }) or ""

        local patterns = M.get_patterns_for_filetype(filetype) or M.get_patterns_for_file(filepath)
        if patterns then
          M.run_patterns(bufnr, patterns)
          processed = processed + 1

          -- Save the buffer if it was modified
          if vim.bo[bufnr].modified then
            vim.api.nvim_buf_call(bufnr, function()
              vim.cmd("write")
            end)
          end
        end
      end
    end

    vim.notify(string.format("Processed save patterns on %d/%d files", processed, total), vim.log.levels.INFO)
    self:close()
  end

  picker.opts.win.list.keys["<Tab>"] = "toggle_select"

  return picker
end

-- Enhanced run on multiple files with async formatter API
function M.run_on_multiple_files_async()
  local picker = Snacks.picker.files({
    prompt = "Select files to run save patterns on (Tab to select multiple, Enter to process)",
  })

  -- Override the confirm action
  picker.opts.win = picker.opts.win or {}
  picker.opts.win.list = picker.opts.win.list or {}
  picker.opts.win.list.keys = picker.opts.win.list.keys or {}

  picker.opts.win.list.keys["<CR>"] = function(self)
    local items = self:selected()
    if #items == 0 then
      local current = self:current()
      if current then
        items = { current }
      end
    end

    if #items == 0 then
      vim.notify("No files selected", vim.log.levels.WARN)
      return
    end

    -- Extract file paths
    local paths = {}
    for _, item in ipairs(items) do
      if item.file then
        table.insert(paths, item.file)
      end
    end

    if #paths > 0 then
      -- Use the async formatter API for better progress tracking
      local formatter = require("utils.formatter")
      formatter.format_batch(paths, {
        verbose = true,
        on_progress = function(status)
          vim.notify(string.format("Processing patterns: %s", status.message), vim.log.levels.INFO)
        end,
        on_complete = function(status)
          local message = string.format("Save patterns completed: %s", status.message)
          local level = status.exit_code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
          vim.notify(message, level)
        end
      })
    end

    self:close()
  end

  picker.opts.win.list.keys["<Tab>"] = "toggle_select"

  return picker
end

-- Setup autocmd for save patterns
function M.setup_autocmd()
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("SavePatterns", { clear = true }),
    callback = function(args)
      local bufnr = args.buf
      
      -- Respect LazyVim's auto-format settings
      -- Check global auto-format setting
      if vim.g.autoformat == false then
        return
      end
      
      -- Check buffer-specific auto-format setting
      if vim.b[bufnr].autoformat == false then
        return
      end
      
      local filetype = vim.bo[bufnr].filetype
      local filepath = vim.api.nvim_buf_get_name(bufnr)

      local patterns = M.get_patterns_for_filetype(filetype) or M.get_patterns_for_file(filepath)
      if patterns then
        M.run_patterns(bufnr, patterns)
      end
    end,
  })
end

return M
