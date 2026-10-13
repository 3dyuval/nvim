-- [nfnl] fnl/workspace/mcp-virtual-text.fnl
local M = {}
local function mark_rows()
  local ns = vim.api.nvim_create_namespace("mcp_virtual_text")
  local buf = vim.api.nvim_get_current_buf()
  local marks = vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, {})
  local seen = {}
  local rows = {}
  for _, m in ipairs(marks) do
    local r = m[2]
    if not seen[r] then
      seen[r] = true
      table.insert(rows, r)
    else
    end
  end
  table.sort(rows)
  return rows
end
local function jump(dir)
  local rows = mark_rows()
  if (#rows > 0) then
    local cur = (vim.fn.line(".") - 1)
    local target = nil
    if (dir == "next") then
      for _, r in ipairs(rows) do
        if ((r > cur) and (target == nil)) then
          target = r
        else
        end
      end
    else
      for _, r in ipairs(rows) do
        if (r < cur) then
          target = r
        else
        end
      end
    end
    if target then
      return vim.api.nvim_win_set_cursor(0, {(target + 1), 0})
    else
      return nil
    end
  else
    return nil
  end
end
M.next = function()
  return jump("next")
end
M.prev = function()
  return jump("prev")
end
return M
