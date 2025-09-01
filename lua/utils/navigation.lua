-- Navigation and window utilities
local M = {}

--- Helper to produce a lambda for smart-splits movement with default opts
---@param dir "left"|"down"|"up"|"right"
---@param op "move" | "resize"
M.move_split = function(dir, op)
  return function()
    if op == "move" then
      -- Check if we're currently in a snacks explorer buffer
      local buf_name = vim.api.nvim_buf_get_name(0)
      local is_snacks_explorer = buf_name:match("snacks://") or vim.bo.filetype == "snacks_picker"

      require("smart-splits")["move_cursor_" .. dir]({
        same_row = false,
        at_edge = "stop",
      })
    end
    if op == "resize" then
      require("smart-splits")["resize_" .. dir](5)
    end
  end
end

M.buffer_close_callback = function()
  local bufs = vim.tbl_filter(function(buf)
    return vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted
  end, vim.api.nvim_list_bufs())

  if #bufs == 0 then
    vim.schedule(function()
      require("snacks").dashboard()
    end)
  end
end

return M