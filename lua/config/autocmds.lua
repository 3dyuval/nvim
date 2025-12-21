-- Auto-save only buffers modified by LSP workspace edits (e.g., import updates on file rename)
-- https://github.com/yioneko/vtsls/issues/287
local original_apply_workspace_edit = vim.lsp.util.apply_workspace_edit
vim.lsp.util.apply_workspace_edit = function(workspace_edit, offset_encoding)
  -- Track which buffers were already loaded before the edit
  local pre_loaded = {}
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      pre_loaded[bufnr] = true
    end
  end

  local result = original_apply_workspace_edit(workspace_edit, offset_encoding)

  -- Defer save to avoid blocking and batch the writes
  vim.schedule(function()
    -- Collect affected buffers (only those that were already loaded)
    local buffers_to_save = {}
    local buffers_to_cleanup = {}

    local function process_uri(uri)
      local bufnr = vim.uri_to_bufnr(uri)
      if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].modified then
        if pre_loaded[bufnr] then
          buffers_to_save[bufnr] = true
        else
          -- Buffer was created by the edit, save then unload
          buffers_to_cleanup[bufnr] = uri
        end
      end
    end

    if workspace_edit.changes then
      for uri in pairs(workspace_edit.changes) do
        process_uri(uri)
      end
    end
    if workspace_edit.documentChanges then
      for _, change in ipairs(workspace_edit.documentChanges) do
        local uri = change.textDocument and change.textDocument.uri
        if uri then
          process_uri(uri)
        end
      end
    end

    -- Save with minimal UI disruption
    local eventignore = vim.o.eventignore
    vim.o.eventignore = "all"

    for bufnr in pairs(buffers_to_save) do
      vim.api.nvim_buf_call(bufnr, function()
        vim.cmd("silent! noautocmd write")
      end)
    end

    -- Save and unload buffers that weren't originally open
    for bufnr, uri in pairs(buffers_to_cleanup) do
      local filepath = vim.uri_to_fname(uri)
      vim.api.nvim_buf_call(bufnr, function()
        vim.cmd("silent! noautocmd write")
      end)
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end

    vim.o.eventignore = eventignore
    vim.cmd("redraw")
  end)

  return result
end

-- restore cursor to file position in previous editing session
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      vim.api.nvim_buf_call(args.buf, function()
        vim.cmd('normal! g`"zz')
      end)
    end
  end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "Fastfile", "Appfile", "Matchfile", "Pluginfile" },
  command = "set filetype=ruby",
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "snacks_win", "snacks_picker", "snacks_explorer" },
  callback = function()
    vim.opt_local.swapfile = false
  end,
})

-- Optimize for SSHFS mounts - disable swap/undo/backup to reduce network I/O
vim.api.nvim_create_autocmd("BufReadPre", {
  pattern = { vim.fn.expand("~") .. "/mnt/*", vim.fn.expand("~") .. "/.sshfs/*" },
  callback = function()
    vim.opt_local.swapfile = false
    vim.opt_local.undofile = false
    vim.opt_local.backup = false
    vim.opt_local.writebackup = false
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "typescript", "json", "lua", "python", "css", "scss" },
  callback = function()
    -- Auto-pair configuration for specific filetypes
    -- The mini.pairs plugin handles {} expansion automatically
  end,
})

vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Disable "modifiable is off" notifications globally
vim.opt.shortmess:append("F")

-- Enable syntax highlighting for log files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.log",
  callback = function()
    vim.bo.filetype = "log"
  end,
})

-- Prevent automatic refolding on cursor movements and edits
-- Use a more robust approach to preserve fold state
local fold_preserved = false
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  callback = function()
    if not fold_preserved then
      -- Preserve current fold level
      local current_foldlevel = vim.wo.foldlevel
      vim.defer_fn(function()
        if vim.wo.foldlevel ~= current_foldlevel then
          vim.wo.foldlevel = current_foldlevel
        end
      end, 50)
    end
  end,
})

-- Also ensure fold level stays high when entering windows
vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
  callback = function()
    if vim.wo.foldlevel < 99 then
      vim.wo.foldlevel = 99
    end
  end,
})

-- Simple approach: just ensure foldlevel stays at 99 when switching tabs
-- Let persistence.nvim handle the actual fold state saving
vim.api.nvim_create_autocmd({ "TabEnter", "BufWinEnter" }, {
  callback = function()
    -- Small delay to let UFO settle, then ensure foldlevel is high
    vim.defer_fn(function()
      if vim.wo.foldlevel < 99 then
        vim.wo.foldlevel = 99
      end
    end, 100)
  end,
})

-- Note: Removed vim.api.nvim_echo override - was interfering with diffview

-- Note: Removed FileType autocmd for DiffviewFiles - was interfering with buffer creation

-- Auto-start Tailwind CSS LSP in projects that have tailwind.config.js
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  pattern = { "*.ts", "*.tsx", "*.js", "*.jsx" },
  callback = function()
    -- Only proceed if we haven't already tried to start tailwindcss for this buffer
    if vim.b.tailwind_checked then
      return
    end
    vim.b.tailwind_checked = true

    -- Check if tailwind config exists in project root
    local config_files = { "tailwind.config.js", "tailwind.config.ts", "tailwind.config.cjs", "tailwind.config.mjs" }

    for _, config_file in ipairs(config_files) do
      if vim.fn.filereadable(config_file) == 1 then
        print("Found " .. config_file .. ", starting Tailwind LSP...")
        vim.defer_fn(function()
          vim.cmd("LspStart tailwindcss")
        end, 200)
        break
      end
    end
  end,
})

-- Remove kitty window padding when Neovim starts, restore on exit
-- Use defer_fn to ensure it runs after Neovim is fully initialized
vim.defer_fn(function()
  if vim.env.KITTY_WINDOW_ID and vim.env.KITTY_LISTEN_ON then
    local window_id = vim.env.KITTY_WINDOW_ID
    local socket = vim.env.KITTY_LISTEN_ON
    local cmd = string.format("kitten @ --to %s set-spacing --match id:%s padding=0", socket, window_id)
    vim.fn.system(cmd)
  end
end, 100)

vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    if vim.env.KITTY_WINDOW_ID and vim.env.KITTY_LISTEN_ON then
      local window_id = vim.env.KITTY_WINDOW_ID
      local socket = vim.env.KITTY_LISTEN_ON
      local cmd = string.format("kitten @ --to %s set-spacing --match id:%s padding=12", socket, window_id)
      vim.fn.system(cmd)
    end
  end,
})
