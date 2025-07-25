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

-- Initialize sticky explorer
require("utils.sticky-explorer").setup()
