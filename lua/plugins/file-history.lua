return {
  "dawsers/file-history.nvim",
  dependencies = {
    "folke/snacks.nvim",
  },
  config = function()
    local file_history = require("file_history")
    file_history.setup({
      -- Default values
      backup_dir = "~/.file-history-git",
      git_cmd = "git",
      -- Use default hostname detection
      hostname = nil,
    })
    
    -- Workaround: Override the history function to customize the picker
    local original_history = file_history.history
    file_history.history = function(...)
      -- Store the original snacks picker function
      local snacks_picker = require("snacks.picker")
      local original_pick = snacks_picker.pick
      
      -- Override the pick function temporarily
      snacks_picker.pick = function(source, opts)
        -- Only modify if this is our file history picker
        if source == "git_log" or (opts and opts.cmd and opts.cmd:find("git log")) then
          opts = opts or {}
          
          -- Configure layout for bottom position
          opts.layout = opts.layout or {}
          opts.layout.preset = "bottom"
          
          -- Focus on list by default (disable input)
          opts.focus = "list"
          
          -- Add custom key bindings
          opts.win = opts.win or {}
          opts.win.list = opts.win.list or {}
          opts.win.list.keys = opts.win.list.keys or {}
          
          -- Add <C-Enter> as alias for <C-r> (revert functionality)
          if opts.win.list.keys["<C-r>"] then
            opts.win.list.keys["<C-CR>"] = opts.win.list.keys["<C-r>"]
          else
            -- If <C-r> doesn't exist, we need to find the revert action
            -- This is a fallback in case the key binding structure changes
            local revert_action = function(picker)
              local item = picker:current()
              if not item then
                return
              end
              
              -- Get the commit hash from the item
              local commit_hash = item.text and item.text:match("^(%w+)") or item.value
              if not commit_hash then
                vim.notify("Could not find commit hash", vim.log.levels.ERROR)
                return
              end
              
              -- Get current file path
              local file_path = vim.fn.expand("%:p")
              if file_path == "" then
                vim.notify("No file is currently open", vim.log.levels.ERROR)
                return
              end
              
              -- Revert current buffer to selected commit
              local cmd = string.format("git show %s:%s", commit_hash, vim.fn.fnamemodify(file_path, ":."))
              local handle = io.popen(cmd)
              if handle then
                local content = handle:read("*a")
                handle:close()
                
                if content and content ~= "" then
                  local lines = vim.split(content, "\n")
                  -- Remove the last empty line if present
                  if lines[#lines] == "" then
                    table.remove(lines)
                  end
                  
                  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
                  vim.bo.modified = true
                  vim.notify("Reverted to commit " .. commit_hash:sub(1, 7))
                else
                  vim.notify("Could not retrieve file content from commit", vim.log.levels.ERROR)
                end
              else
                vim.notify("Failed to execute git command", vim.log.levels.ERROR)
              end
            end
            
            opts.win.list.keys["<C-r>"] = revert_action
            opts.win.list.keys["<C-CR>"] = revert_action
          end
        end
        
        return original_pick(source, opts)
      end
      
      -- Call the original history function
      local result = original_history(...)
      
      -- Restore the original pick function
      snacks_picker.pick = original_pick
      
      return result
    end
  end,
}