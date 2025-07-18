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

-- Create unified FormatAndOrganize command
vim.api.nvim_create_user_command("FormatAndOrganize", function(opts)
  local bufnr = opts.args and opts.args ~= "" and vim.fn.bufnr(opts.args) or vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  
  if filepath == "" or vim.fn.filereadable(filepath) == 0 then
    return
  end
  
  -- Get absolute path
  local abs_file = vim.fn.fnamemodify(filepath, ":p")
  
  -- First: Format with conform
  local conform = require("conform")
  local format_success = conform.format({ bufnr = bufnr, timeout_ms = 5000 })
  
  if not format_success then
    return
  end
  
  -- Second: Organize imports
  local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
  
  if vim.tbl_contains({ "javascript", "javascriptreact", "typescript", "typescriptreact" }, filetype) then
    -- Check if biome is available
    local biome_cmd = vim.fn.executable("biome")
    if biome_cmd == 1 then
      -- Use biome to organize imports only (disable formatting)
      local cmd = {
        "biome",
        "check",
        "--write",
        "--formatter-enabled=false",
        "--linter-enabled=false",
        abs_file
      }
      
      vim.fn.system(cmd)
    else
      -- Fallback to TSToolsOrganizeImports
      vim.cmd("TSToolsOrganizeImports")
    end
  end
  
  -- Reload buffer to show changes
  vim.cmd("silent! checktime")
end, {
  desc = "Format code and organize imports",
  nargs = "?",
  complete = "file"
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "typescript", "json", "lua", "python", "css", "scss" },
  callback = function()
    -- Auto-pair configuration for specific filetypes
    -- The mini.pairs plugin handles {} expansion automatically
  end,
})

-- Disable "modifiable is off" notifications globally
vim.opt.shortmess:append("F")

-- Enable syntax highlighting for log files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.log",
  callback = function()
    vim.bo.filetype = "log"
  end,
})

-- Setup save patterns system
require("utils.save-patterns").setup_autocmd()
