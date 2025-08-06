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

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "snacks_win", "snacks_picker", "snacks_explorer" },
  callback = function()
    vim.opt_local.swapfile = false
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
vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
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
