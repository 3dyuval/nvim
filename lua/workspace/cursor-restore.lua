-- [nfnl] fnl/workspace/cursor-restore.fnl
local function _1_(args)
  local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
  local lines = vim.api.nvim_buf_line_count(args.buf)
  if (mark[1] > 0) and (mark[1] <= lines) then
    local function _2_()
      return vim.cmd('normal! g`"zz')
    end
    return vim.api.nvim_buf_call(args.buf, _2_)
  else
    return nil
  end
end
vim.api.nvim_create_autocmd("BufReadPost", { callback = _1_ })
return {}
