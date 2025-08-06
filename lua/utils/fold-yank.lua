local M = {}

-- Function to yank only visible lines (excluding folded content)
-- Based on the solution from Stack Overflow using foldclosed()
function M.yank_visible()
  -- Get visual selection range
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")

  -- Clear a temporary register
  vim.cmd("let @z = ''")

  -- Build the command to yank only non-folded lines
  local cmd =
    string.format("'<,'>g/^/if line('.')==foldclosed('.') || foldclosed('.')==-1|y Z |endif")

  -- Execute the command
  vim.cmd(cmd)

  -- Copy to system clipboard and default register
  local content = vim.fn.getreg("z")
  vim.fn.setreg("+", content)
  vim.fn.setreg('"', content)

  -- Count visible lines
  local visible_count = 0
  for line = start_line, end_line do
    if vim.fn.foldclosed(line) == -1 then
      visible_count = visible_count + 1
    end
  end

  -- Provide feedback
  vim.notify(string.format("Yanked %d visible lines (excluded folded content)", visible_count))

  -- Exit visual mode
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end

return M
