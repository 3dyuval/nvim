--- Shared utilities for shell blink sources

local M = {}

--- Check if the cursor is inside a command invocation of `cmd` using treesitter.
--- Falls back to line scanning if no treesitter parser is available.
---@param ctx table blink completion context
---@param cmd string command name to look for (e.g. "curl", "jq")
---@return boolean
function M.in_command(ctx, cmd)
  local bufnr = vim.api.nvim_get_current_buf()
  local row = ctx.cursor[1] - 1
  local col = ctx.cursor[2]

  -- Try treesitter first
  local ok, node = pcall(vim.treesitter.get_node, { bufnr = bufnr, pos = { row, col } })
  if ok and node then
    -- Walk up the tree to find a command node
    local current = node
    while current do
      if current:type() == "command" or current:type() == "pipeline" then
        local text = vim.treesitter.get_node_text(current, bufnr)
        if text and text:match(cmd) then
          return true
        end
      end
      current = current:parent()
    end
  end

  -- Fallback: scan current line and backwards through continuations
  local line = ctx.line
  if line:match(cmd) then
    return true
  end
  for i = row - 1, math.max(0, row - 20), -1 do
    local prev = vim.api.nvim_buf_get_lines(bufnr, i, i + 1, false)[1] or ""
    if prev:match(cmd) then
      return true
    end
    if not prev:match("[\\|]%s*$") then
      break
    end
  end

  return false
end

return M
