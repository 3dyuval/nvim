-- Instant template expansion
local M = {}

-- React functional component template
local reactf_template = [[
import React from 'react'

interface %sProps {
  
}

export const %s: React.FC<%sProps> = () => {
  return (
    <div>
      %s Component
    </div>
  )
}
]]

M.setup = function()
  vim.api.nvim_create_autocmd({"FileType"}, {
    pattern = {"typescript", "typescriptreact", "javascript", "javascriptreact"},
    callback = function()
      -- Map each character of the trigger
      local trigger = "!reactf"
      local chars = {}
      
      -- Build up the sequence
      for i = 1, #trigger do
        chars[i] = trigger:sub(i, i)
      end
      
      -- Set up the instant trigger
      vim.api.nvim_create_autocmd({"InsertCharPre"}, {
        buffer = 0,
        callback = function()
          local char = vim.v.char
          local col = vim.fn.col('.') - 1
          local line = vim.api.nvim_get_current_line()
          local before_cursor = line:sub(1, col)
          
          -- Check if we're completing the trigger
          if before_cursor:sub(-6) == "!react" and char == "f" then
            -- Prevent the 'f' from being inserted
            vim.v.char = ""
            
            -- Schedule the expansion for after the current event
            vim.schedule(function()
              -- Delete the trigger text
              vim.cmd("normal! 7h7x")
              
              -- Insert the template
              local filename = vim.fn.expand("%:t:r")
              local component_name = filename:gsub("^%l", string.upper)
              local content = string.format(reactf_template, component_name, component_name, component_name, component_name)
              
              local row = vim.api.nvim_win_get_cursor(0)[1]
              local lines = vim.split(content, "\n")
              vim.api.nvim_buf_set_lines(0, row - 1, row, false, lines)
              
              -- Position cursor in props interface
              vim.api.nvim_win_set_cursor(0, {row + 2, 2})
              vim.cmd("startinsert!")
            end)
          end
        end
      })
    end
  })
end

return M