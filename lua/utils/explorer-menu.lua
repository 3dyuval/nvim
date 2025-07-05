local M = {}

-- Reusable save patterns action
local function run_save_patterns_action(picker, items)
  local save_patterns = require("utils.save-patterns")
  local processed = 0
  local errors = 0
  
  -- Handle single item vs multiple items
  if type(items.file) == "string" then
    items = { items }
  end
  
  for _, item in ipairs(items) do
    if not item.dir and vim.fn.filereadable(item.file) == 1 then
      local success, err = pcall(function()
        local bufnr = vim.fn.bufnr(item.file, true)
        vim.fn.bufload(bufnr)
        
        vim.bo[bufnr].modifiable = true
        vim.bo[bufnr].readonly = false
        
        local filetype = vim.filetype.match({ filename = item.file }) or ""
        local patterns = save_patterns.get_patterns_for_filetype(filetype) or save_patterns.get_patterns_for_file(item.file)
        
        if patterns then
          save_patterns.run_patterns(bufnr, patterns)
          processed = processed + 1
          
          if vim.bo[bufnr].modified then
            vim.api.nvim_buf_call(bufnr, function()
              vim.cmd("silent! write")
            end)
          end
        end
      end)
      
      if not success then
        errors = errors + 1
        vim.notify("Error processing " .. vim.fn.fnamemodify(item.file, ":t") .. ": " .. (err or "unknown error"), vim.log.levels.WARN)
      end
    end
  end
  
  if processed > 0 then
    vim.notify(string.format("Processed save patterns on %d files%s", processed, errors > 0 and " (" .. errors .. " errors)" or ""))
  else
    vim.notify("No files processed - no matching patterns found", vim.log.levels.WARN)
  end
end

-- Picker context detection
M.contexts = {
  explorer = {
    detect = function(picker)
      -- Check if picker has the expected structure
      if not picker or type(picker) ~= "table" then
        return false
      end
      
      -- Check for source in various locations
      local source = picker.source or 
                    (picker.opts and picker.opts.source) or
                    (picker.opts and picker.opts.finder) or
                    (picker.config and picker.config.source) or
                    (picker.config and picker.config.finder)
      
      return source == "explorer"
    end,
    get_items = function(picker)
      local items = {}
      
      if not picker or type(picker) ~= "table" then
        return items
      end
      
      -- Try to get selected items first
      if type(picker.selected) == "function" then
        local success, selected = pcall(picker.selected, picker)
        if success and selected and #selected > 0 then
          items = selected
        end
      end
      
      -- If no selection, get current item
      if #items == 0 and type(picker.current) == "function" then
        local success, current = pcall(picker.current, picker)
        if success and current then 
          items = { current }
        end
      end
      
      -- Fallback: try list.selected (internal API)
      if #items == 0 and picker.list and picker.list.selected and type(picker.list.selected) == "table" and #picker.list.selected > 0 then
        items = picker.list.selected
      end
      
      return items
    end,
  },
  
  git_status = {
    detect = function(picker)
      if not picker or type(picker) ~= "table" then
        return false
      end
      
      local source = picker.source or 
                    (picker.opts and picker.opts.source) or
                    (picker.opts and picker.opts.finder) or
                    (picker.config and picker.config.source) or
                    (picker.config and picker.config.finder)
      
      return source == "git_status"
    end,
    get_items = function(picker)
      local items = {}
      
      if not picker or type(picker) ~= "table" then
        return items
      end
      
      -- Try to get selected items first
      if type(picker.selected) == "function" then
        local success, selected = pcall(picker.selected, picker)
        if success and selected and #selected > 0 then
          items = selected
        end
      end
      
      -- If no selection, get current item
      if #items == 0 and type(picker.current) == "function" then
        local success, current = pcall(picker.current, picker)
        if success and current then 
          items = { current }
        end
      end
      
      -- Fallback: try list.selected (internal API)
      if #items == 0 and picker.list and picker.list.selected and type(picker.list.selected) == "table" and #picker.list.selected > 0 then
        items = picker.list.selected
      end
      
      return items
    end,
  },
  
  files = {
    detect = function(picker)
      if not picker or type(picker) ~= "table" then
        return false
      end
      
      local source = picker.source or 
                    (picker.opts and picker.opts.source) or
                    (picker.opts and picker.opts.finder) or
                    (picker.config and picker.config.source) or
                    (picker.config and picker.config.finder)
      
      return source == "files" or source == "git_files"
    end,
    get_items = function(picker)
      local items = {}
      
      if not picker or type(picker) ~= "table" then
        return items
      end
      
      -- Try to get selected items first
      if type(picker.selected) == "function" then
        local success, selected = pcall(picker.selected, picker)
        if success and selected and #selected > 0 then
          items = selected
        end
      end
      
      -- If no selection, get current item
      if #items == 0 and type(picker.current) == "function" then
        local success, current = pcall(picker.current, picker)
        if success and current then 
          items = { current }
        end
      end
      
      -- Fallback: try list.selected (internal API)
      if #items == 0 and picker.list and picker.list.selected and type(picker.list.selected) == "table" and #picker.list.selected > 0 then
        items = picker.list.selected
      end
      
      return items
    end,
  },
  
  buffers = {
    detect = function(picker)
      if not picker or type(picker) ~= "table" then
        return false
      end
      
      local source = picker.source or 
                    (picker.opts and picker.opts.source) or
                    (picker.opts and picker.opts.finder) or
                    (picker.config and picker.config.source) or
                    (picker.config and picker.config.finder)
      
      return source == "buffers"
    end,
    get_items = function(picker)
      local items = {}
      
      if not picker or type(picker) ~= "table" then
        return items
      end
      
      -- Try to get selected items first
      if type(picker.selected) == "function" then
        local success, selected = pcall(picker.selected, picker)
        if success and selected and #selected > 0 then
          items = selected
        end
      end
      
      -- If no selection, get current item
      if #items == 0 and type(picker.current) == "function" then
        local success, current = pcall(picker.current, picker)
        if success and current then 
          items = { current }
        end
      end
      
      -- Fallback: try list.selected (internal API)
      if #items == 0 and picker.list and picker.list.selected and type(picker.list.selected) == "table" and #picker.list.selected > 0 then
        items = picker.list.selected
      end
      
      return items
    end,
  },
}

-- Menu actions for different contexts
M.actions = {
  -- Single file actions
  single_file = {
    {
      key = "o",
      desc = "Open file",
      action = function(picker, item)
        picker:close()
        vim.cmd("edit " .. vim.fn.fnameescape(item.file))
      end,
    },
    {
      key = "s",
      desc = "Split open",
      action = function(picker, item)
        picker:close()
        vim.cmd("split " .. vim.fn.fnameescape(item.file))
      end,
    },
    {
      key = "v",
      desc = "Vertical split",
      action = function(picker, item)
        picker:close()
        vim.cmd("vsplit " .. vim.fn.fnameescape(item.file))
      end,
    },
    {
      key = "t",
      desc = "Open in new tab",
      action = function(picker, item)
        picker:close()
        vim.cmd("tabnew " .. vim.fn.fnameescape(item.file))
      end,
    },
    {
      key = "r",
      desc = "Rename file",
      action = function(picker, item)
        local new_name = vim.fn.input("Rename to: ", vim.fn.fnamemodify(item.file, ":t"))
        if new_name and new_name ~= "" then
          local new_path = vim.fn.fnamemodify(item.file, ":h") .. "/" .. new_name
          local ok, err = os.rename(item.file, new_path)
          if ok then
            vim.notify("Renamed to " .. new_name)
            picker:refresh()
          else
            vim.notify("Failed to rename: " .. (err or "unknown error"), vim.log.levels.ERROR)
          end
        end
      end,
    },
    {
      key = "d",
      desc = "Delete file",
      action = function(picker, item)
        local confirm = vim.fn.confirm("Delete " .. vim.fn.fnamemodify(item.file, ":t") .. "?", "&Yes\n&No", 2)
        if confirm == 1 then
          local ok, err = os.remove(item.file)
          if ok then
            vim.notify("Deleted " .. vim.fn.fnamemodify(item.file, ":t"))
            picker:refresh()
          else
            vim.notify("Failed to delete: " .. (err or "unknown error"), vim.log.levels.ERROR)
          end
        end
      end,
    },
    {
      key = "c",
      desc = "Copy path",
      action = function(picker, item)
        vim.fn.setreg("+", item.file)
        vim.notify("Copied path: " .. item.file)
      end,
    },
    {
      key = "C",
      desc = "Copy filename",
      action = function(picker, item)
        local filename = vim.fn.fnamemodify(item.file, ":t")
        vim.fn.setreg("+", filename)
        vim.notify("Copied filename: " .. filename)
      end,
    },
    {
      key = "s",
      desc = "Run Save Patterns",
      action = run_save_patterns_action,
    },
  },

  -- Single directory actions
  single_dir = {
    {
      key = "o",
      desc = "Open directory",
      action = function(picker, item)
        picker:close()
        Snacks.picker.files({ cwd = item.file })
      end,
    },
    {
      key = "e",
      desc = "Explore directory",
      action = function(picker, item)
        picker:close()
        Snacks.picker.explorer({ cwd = item.file })
      end,
    },
    {
      key = "t",
      desc = "Open in terminal",
      action = function(picker, item)
        picker:close()
        Snacks.terminal({ cwd = item.file })
      end,
    },
    {
      key = "r",
      desc = "Rename directory",
      action = function(picker, item)
        local new_name = vim.fn.input("Rename to: ", vim.fn.fnamemodify(item.file, ":t"))
        if new_name and new_name ~= "" then
          local new_path = vim.fn.fnamemodify(item.file, ":h") .. "/" .. new_name
          local ok, err = os.rename(item.file, new_path)
          if ok then
            vim.notify("Renamed to " .. new_name)
            picker:refresh()
          else
            vim.notify("Failed to rename: " .. (err or "unknown error"), vim.log.levels.ERROR)
          end
        end
      end,
    },
    {
      key = "d",
      desc = "Delete directory",
      action = function(picker, item)
        local confirm = vim.fn.confirm("Delete directory " .. vim.fn.fnamemodify(item.file, ":t") .. "?", "&Yes\n&No", 2)
        if confirm == 1 then
          vim.fn.delete(item.file, "rf")
          vim.notify("Deleted directory " .. vim.fn.fnamemodify(item.file, ":t"))
          picker:refresh()
        end
      end,
    },
    {
      key = "c",
      desc = "Copy path",
      action = function(picker, item)
        vim.fn.setreg("+", item.file)
        vim.notify("Copied path: " .. item.file)
      end,
    },
    {
      key = "n",
      desc = "New file in directory",
      action = function(picker, item)
        local filename = vim.fn.input("New file name: ")
        if filename and filename ~= "" then
          local filepath = item.file .. "/" .. filename
          vim.cmd("edit " .. vim.fn.fnameescape(filepath))
          picker:close()
        end
      end,
    },
    {
      key = "N",
      desc = "New directory",
      action = function(picker, item)
        local dirname = vim.fn.input("New directory name: ")
        if dirname and dirname ~= "" then
          local dirpath = item.file .. "/" .. dirname
          vim.fn.mkdir(dirpath, "p")
          vim.notify("Created directory: " .. dirname)
          picker:refresh()
        end
      end,
    },
  },

  -- Multiple files/directories actions
  multiple_items = {
    {
      key = "d",
      desc = "Delete selected items",
      action = function(picker, items)
        local count = #items
        local confirm = vim.fn.confirm("Delete " .. count .. " items?", "&Yes\n&No", 2)
        if confirm == 1 then
          local deleted = 0
          for _, item in ipairs(items) do
            if item.dir then
              vim.fn.delete(item.file, "rf")
            else
              os.remove(item.file)
            end
            deleted = deleted + 1
          end
          vim.notify("Deleted " .. deleted .. " items")
          picker:refresh()
        end
      end,
    },
    {
      key = "c",
      desc = "Copy paths",
      action = function(picker, items)
        local paths = {}
        for _, item in ipairs(items) do
          table.insert(paths, item.file)
        end
        vim.fn.setreg("+", table.concat(paths, "\n"))
        vim.notify("Copied " .. #paths .. " paths")
      end,
    },
    {
      key = "o",
      desc = "Open all files",
      action = function(picker, items)
        picker:close()
        for _, item in ipairs(items) do
          if not item.dir then
            vim.cmd("edit " .. vim.fn.fnameescape(item.file))
          end
        end
      end,
    },
    {
      key = "s",
      desc = "Run Save Patterns",
      action = run_save_patterns_action,
    },
  },

  -- Git-specific actions (when in git repo)
  git_actions = {
    {
      key = "ga",
      desc = "Git add",
      action = function(picker, items)
        local files = {}
        for _, item in ipairs(items) do
          if not item.dir then
            table.insert(files, item.file)
          end
        end
        if #files > 0 then
          vim.system({ "git", "add", unpack(files) })
          vim.notify("Added " .. #files .. " files to git")
          if picker.refresh then picker:refresh() end
        end
      end,
    },
    {
      key = "gr",
      desc = "Git restore",
      action = function(picker, items)
        local files = {}
        for _, item in ipairs(items) do
          if not item.dir then
            table.insert(files, item.file)
          end
        end
        if #files > 0 then
          local confirm = vim.fn.confirm("Restore " .. #files .. " files?", "&Yes\n&No", 2)
          if confirm == 1 then
            vim.system({ "git", "restore", unpack(files) })
            vim.notify("Restored " .. #files .. " files")
            if picker.refresh then picker:refresh() end
          end
        end
      end,
    },
  },

  -- Git status specific actions
  git_status_actions = {
    {
      key = "s",
      desc = "Stage/Unstage Files",
      action = function(picker, items)
        for _, item in ipairs(items) do
          local file = item.file
          if item.status and (item.status:match("^M") or item.status:match("^A") or item.status:match("^D")) then
            -- File is staged, unstage it
            vim.system({ "git", "restore", "--staged", file })
          else
            -- File is unstaged, stage it
            vim.system({ "git", "add", file })
          end
        end
        vim.notify("Toggled stage status for " .. #items .. " files")
        if picker.refresh then picker:refresh() end
      end,
    },
    {
      key = "p",
      desc = "Run Save Patterns",
      action = function(picker, items)
        run_save_patterns_action(picker, items)
        if picker.refresh then picker:refresh() end
      end,
    },
    {
      key = "d",
      desc = "Show diff",
      action = function(picker, item)
        -- Don't close picker, open diff in split
        vim.cmd("split")
        vim.cmd("Gvdiffsplit " .. vim.fn.fnameescape(item.file))
      end,
    },
    {
      key = "r",
      desc = "Restore file",
      action = function(picker, items)
        local files = {}
        for _, item in ipairs(items) do
          table.insert(files, item.file)
        end
        local confirm = vim.fn.confirm("Restore " .. #files .. " files?", "&Yes\n&No", 2)
        if confirm == 1 then
          vim.system({ "git", "restore", unpack(files) })
          vim.notify("Restored " .. #files .. " files")
          if picker.refresh then picker:refresh() end
        end
      end,
    },
  },

  -- Buffer-specific actions
  buffer_actions = {
    {
      key = "d",
      desc = "Delete Buffer",
      action = function(picker, items)
        for _, item in ipairs(items) do
          if item.bufnr then
            vim.api.nvim_buf_delete(item.bufnr, { force = false })
          end
        end
        vim.notify("Deleted " .. #items .. " buffers")
        if picker.refresh then picker:refresh() end
      end,
    },
    {
      key = "w",
      desc = "Wipe Buffer (Force)",
      action = function(picker, items)
        for _, item in ipairs(items) do
          if item.bufnr then
            vim.api.nvim_buf_delete(item.bufnr, { force = true })
          end
        end
        vim.notify("Wiped " .. #items .. " buffers")
        if picker.refresh then picker:refresh() end
      end,
    },
    {
      key = "s",
      desc = "Save Buffer",
      action = function(picker, items)
        local saved = 0
        for _, item in ipairs(items) do
          if item.bufnr and vim.api.nvim_buf_is_loaded(item.bufnr) then
            local success, err = pcall(function()
              vim.api.nvim_buf_call(item.bufnr, function()
                vim.cmd("write")
              end)
            end)
            if success then
              saved = saved + 1
            end
          end
        end
        vim.notify("Saved " .. saved .. "/" .. #items .. " buffers")
      end,
    },
    {
      key = "p",
      desc = "Run Save Patterns",
      action = function(picker, items)
        -- Convert buffer items to file items for the reusable function
        local file_items = {}
        for _, item in ipairs(items) do
          if item.bufnr and vim.api.nvim_buf_is_loaded(item.bufnr) then
            local filepath = vim.api.nvim_buf_get_name(item.bufnr)
            if filepath and filepath ~= "" then
              table.insert(file_items, { file = filepath, dir = false })
            end
          end
        end
        
        if #file_items > 0 then
          run_save_patterns_action(picker, file_items)
        else
          vim.notify("No valid files found in selected buffers", vim.log.levels.WARN)
        end
      end,
    },
  },
}

-- Detect picker context
function M.detect_context(picker)
  if not picker or type(picker) ~= "table" then
    return "unknown", nil
  end
  
  -- Use improved context detection
  for context_name, context in pairs(M.contexts) do
    if context.detect(picker) then
      return context_name, context
    end
  end
  return "unknown", nil
end

-- Get context-appropriate actions
function M.get_actions(picker)
  local context_name, context = M.detect_context(picker)
  
  if not context then
    return {}, {}
  end
  
  local items = context.get_items(picker)
  
  if #items == 0 then
    return {}, {}
  end
  
  local actions = {}
  
  -- Context-specific actions
  if context_name == "git_status" then
    vim.list_extend(actions, M.actions.git_status_actions)
  elseif context_name == "buffers" then
    vim.list_extend(actions, M.actions.buffer_actions)
  elseif context_name == "explorer" or context_name == "files" then
    if #items == 1 then
      local item = items[1]
      if item.dir then
        vim.list_extend(actions, M.actions.single_dir)
      else
        vim.list_extend(actions, M.actions.single_file)
      end
    else
      vim.list_extend(actions, M.actions.multiple_items)
    end
  end
  
  -- Add git actions if in git repo (for file-based pickers)
  if (context_name == "explorer" or context_name == "files") and 
     (vim.fn.isdirectory(".git") == 1 or vim.fn.finddir(".git", ".;") ~= "") then
    vim.list_extend(actions, M.actions.git_actions)
  end
  
  return actions, items
end

-- Show context menu
function M.show_menu(picker)
  -- Validate picker
  if not picker or type(picker) ~= "table" then
    vim.notify("Invalid picker object", vim.log.levels.ERROR)
    return
  end
  
  local actions, items = M.get_actions(picker)
  local context_name, context = M.detect_context(picker)
  
  if #actions == 0 then
    -- For unknown contexts, provide basic file actions if we can get current item
    if context_name == "unknown" and type(picker.current) == "function" then
      local success, current = pcall(picker.current, picker)
      if success and current and current.file then
        actions = M.actions.single_file
        items = { current }
      end
    end
    
    if #actions == 0 then
      vim.notify("No actions available. Context: " .. (context_name or "unknown") .. ", Items: " .. #items, vim.log.levels.WARN)
      return
    end
  end
  
  -- Create menu items
  local menu_items = {}
  for _, action in ipairs(actions) do
    table.insert(menu_items, {
      text = string.format("[%s] %s", action.key, action.desc),
      key = action.key,
      action = action.action,
    })
  end
  
  -- Show picker menu
  Snacks.picker({
    source = {
      name = "explorer_menu",
      get = function()
        return menu_items
      end,
    },
    format = function(item)
      return item.text
    end,
    win = {
      input = {
        keys = vim.tbl_extend("force", {
          ["<Esc>"] = "close",
          ["q"] = "close",
        }, vim.tbl_map(function(action)
          return function(menu_picker)
            menu_picker:close()
            if #items == 1 then
              action.action(picker, items[1])
            else
              action.action(picker, items)
            end
          end
        end, vim.tbl_map(function(item) return { action = item.action } end, menu_items))),
      },
    },
    confirm = function(menu_picker)
      local selected = menu_picker:current()
      if selected then
        menu_picker:close()
        if #items == 1 then
          selected.action(picker, items[1])
        else
          selected.action(picker, items)
        end
      end
    end,
  })
end

return M