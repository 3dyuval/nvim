local M = {}

-- ============================================================================
-- PICKER UTILITIES MODULE
-- Centralized location for all Snacks.nvim picker extensions and utilities
-- ============================================================================

-- ============================================================================
-- CORE UTILITIES
-- ============================================================================

-- Validate picker instance
local function validate_picker(picker)
  if not picker or type(picker) ~= "table" then
    vim.notify("Invalid picker object", vim.log.levels.ERROR)
    return false
  end
  return true
end

-- Safe picker method call with error handling
local function safe_picker_call(picker, method, ...)
  if not validate_picker(picker) then
    return nil, "Invalid picker"
  end

  if type(picker[method]) ~= "function" then
    return nil, "Method " .. method .. " not available"
  end

  -- Use colon notation for picker methods (they expect self as first argument)
  local success, result = pcall(function(...)
    return picker[method](picker, ...)
  end, ...)

  if success then
    return result, nil
  else
    return nil, result
  end
end

-- ============================================================================
-- PICKER ACTIONS
-- ============================================================================

-- Explorer: Open multiple buffers action
M.open_multiple_buffers = function(picker)
  if not validate_picker(picker) then
    return
  end

  local sel, err = safe_picker_call(picker, "selected")
  if err then
    vim.notify("Could not get selected items: " .. err, vim.log.levels.WARN)
    return
  end

  sel = sel or {}
  if #sel == 0 then
    vim.notify("No files selected", vim.log.levels.WARN)
    return
  end

  picker:close()

  for _, item in ipairs(sel) do
    if item and item.file then
      vim.cmd("edit " .. vim.fn.fnameescape(item.file))
    end
  end

  vim.notify(string.format("Opened %d file(s)", #sel))
end

-- Explorer: Copy file path with options
M.copy_file_path = function(picker, item)
  if not item then
    vim.notify("No item provided", vim.log.levels.WARN)
    return
  end

  local vals = {
    ["PATH"] = item.file,
    ["FILE CONTENT"] = "file_content",
    ["PATH (HOME)"] = vim.fn.fnamemodify(item.file, ":~"),
    ["PATH (CWD)"] = vim.fn.fnamemodify(item.file, ":."),
    ["BASENAME"] = vim.fn.fnamemodify(item.file, ":t:r"),
    ["EXTENSION"] = vim.fn.fnamemodify(item.file, ":t:e"),
    ["FILENAME"] = vim.fn.fnamemodify(item.file, ":t"),
    ["URI"] = vim.uri_from_fname(item.file),
  }

  local options = vim.tbl_filter(function(val)
    return vals[val] ~= ""
  end, vim.tbl_keys(vals))

  if vim.tbl_isempty(options) then
    vim.notify("No values to copy", vim.log.levels.WARN)
    return
  end

  vim.ui.select(options, {
    prompt = "Choose to copy to clipboard:",
    format_item = function(list_item)
      return ("%s: %s"):format(list_item, vals[list_item])
    end,
  }, function(choice)
    local result = vals[choice]
    if result then
      if choice == "FILE CONTENT" then
        if vim.fn.filereadable(item.file) == 0 then
          vim.notify("File not readable: " .. item.file, vim.log.levels.ERROR)
          return
        end
        local content = vim.fn.readfile(item.file)
        local content_str = table.concat(content, "\n")
        vim.fn.setreg("+", content_str)
        local filename = vim.fn.fnamemodify(item.file, ":t")
        local line_count = #content
        Snacks.notify.info(string.format("File content copied to clipboard: %s (%d lines)", filename, line_count))
      else
        vim.fn.setreg("+", result)
        Snacks.notify.info("Yanked `" .. result .. "`")
      end
    end
  end)
end

-- Explorer: Search in directory
M.search_in_directory = function(picker, item)
  if not item then
    vim.notify("No item provided", vim.log.levels.WARN)
    return
  end

  local dir = vim.fn.fnamemodify(item.file, ":p:h")
  Snacks.picker.grep({
    cwd = dir,
    cmd = "rg",
    args = {
      "-g",
      "!.git",
      "-g",
      "!node_modules",
      "-g",
      "!dist",
      "-g",
      "!build",
      "-g",
      "!coverage",
      "-g",
      "!.DS_Store",
      "-g",
      "!.docusaurus",
      "-g",
      "!.dart_tool",
    },
    show_empty = true,
    hidden = true,
    ignored = true,
    follow = false,
    supports_live = true,
  })
end

-- Explorer: Diff two selected files
M.diff_selected = function(picker)
  if not validate_picker(picker) then
    return
  end

  picker:close()
  local sel, err = safe_picker_call(picker, "selected")
  if err then
    vim.notify("Could not get selected items: " .. err, vim.log.levels.WARN)
    return
  end

  sel = sel or {}
  if #sel >= 2 then
    Snacks.notify.info(sel[1].file)
    vim.cmd("tabnew " .. sel[1].file)
    vim.cmd("vert diffs " .. sel[2].file)
    Snacks.notify.info("Diffing " .. sel[1].file .. " against " .. sel[2].file)
  else
    Snacks.notify.info("Select two entries for the diff")
  end
end

-- Directory expansion handler
M.handle_directory_expansion = function(picker)
  if not validate_picker(picker) then
    return
  end

  local item, err = safe_picker_call(picker, "current")
  if err then
    vim.notify("Could not get current item: " .. err, vim.log.levels.WARN)
    return
  end

  if item and item.dir then
    -- For directories, use the default confirm behavior
    picker:confirm()
  end
  -- For files, do nothing
end

-- ============================================================================
-- CONTEXT MENU SYSTEM
-- ============================================================================

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
        local patterns = save_patterns.get_patterns_for_filetype(filetype)
          or save_patterns.get_patterns_for_file(item.file)

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
        vim.notify(
          "Error processing " .. vim.fn.fnamemodify(item.file, ":t") .. ": " .. (err or "unknown error"),
          vim.log.levels.WARN
        )
      end
    end
  end

  if processed > 0 then
    vim.notify(
      string.format(
        "Processed save patterns on %d files%s",
        processed,
        errors > 0 and " (" .. errors .. " errors)" or ""
      )
    )
  else
    vim.notify("No files processed - no matching patterns found", vim.log.levels.WARN)
  end
end

-- Context detection system
local contexts = {
  sidebar_explorer = {
    detect = function(picker)
      if not validate_picker(picker) then
        return false
      end

      -- Detect sidebar explorer by minimal action set
      local has_minimal_explorer = picker.opts
        and picker.opts.actions
        and (picker.opts.actions.explorer_add and picker.opts.actions.list_down)

      if has_minimal_explorer then
        local action_count = 0
        for _ in pairs(picker.opts.actions) do
          action_count = action_count + 1
        end

        -- Sidebar explorers have very few actions (< 10)
        -- Your popup explorer has 50+ actions
        return action_count < 10
      end

      return false
    end,
    get_items = function(picker)
      vim.notify("Sidebar explorer detected - context menu not yet supported", vim.log.levels.INFO)
      return {}
    end,
  },

  explorer = {
    detect = function(picker)
      if not validate_picker(picker) then
        return false
      end

      -- Check if the picker has explorer-specific actions (most reliable method)
      local has_explorer_actions = picker.opts
        and picker.opts.actions
        and (
          picker.opts.actions.explorer_add
          or picker.opts.actions.explorer_del
          or picker.opts.actions.explorer_open
          or picker.opts.actions.explorer_rename
          or picker.opts.actions.explorer_close
          or picker.opts.actions.explorer_up
          or picker.opts.actions.explorer_focus
        )

      -- Exclude sidebar explorers (they have minimal actions and different structure)
      if has_explorer_actions then
        local action_count = 0
        for _ in pairs(picker.opts.actions) do
          action_count = action_count + 1
        end
        -- Sidebar explorers typically have very few actions (< 5)
        -- Popup explorers have many actions (> 10)
        if action_count < 5 then
          return false -- This is likely a sidebar explorer
        end

        -- This IS an explorer picker - return true regardless of item properties
        return true
      end

      return false
    end,
    get_items = function(picker)
      local items = {}

      if not validate_picker(picker) then
        return items
      end

      local selected, err = safe_picker_call(picker, "selected")
      if not err and selected and #selected > 0 then
        items = selected
      end

      if #items == 0 then
        local current, err = safe_picker_call(picker, "current")
        if not err and current then
          items = { current }
        end
      end

      if
        #items == 0
        and picker.list
        and picker.list.selected
        and type(picker.list.selected) == "table"
        and #picker.list.selected > 0
      then
        items = picker.list.selected
      end

      return items
    end,
  },

  git_status = {
    detect = function(picker)
      if not validate_picker(picker) then
        return false
      end

      -- Check source first (if available) - this is the most reliable
      local source = picker.opts and picker.opts.source
      if source == "git_status" then
        return true
      end

      -- Only fallback to item checking if we're NOT in an explorer
      -- (explorer items can have status but aren't git status items)
      local has_explorer_actions = picker.opts
        and picker.opts.actions
        and (picker.opts.actions.explorer_add or picker.opts.actions.explorer_del or picker.opts.actions.explorer_open)

      if not has_explorer_actions then
        -- Fallback: check if current item has git status properties
        local current, err = safe_picker_call(picker, "current")
        if not err and current and current.status and current.file and not current.dir then
          -- Check if status looks like git status (M, A, D, ??, etc.)
          if current.status:match("^[MADRCU?!]") then
            return true
          end
        end
      end

      return false
    end,
    get_items = function(picker)
      local items = {}

      if not validate_picker(picker) then
        return items
      end

      local selected, err = safe_picker_call(picker, "selected")
      if not err and selected and #selected > 0 then
        items = selected
      end

      if #items == 0 then
        local current, err = safe_picker_call(picker, "current")
        if not err and current then
          items = { current }
        end
      end

      if
        #items == 0
        and picker.list
        and picker.list.selected
        and type(picker.list.selected) == "table"
        and #picker.list.selected > 0
      then
        items = picker.list.selected
      end

      return items
    end,
  },

  files = {
    detect = function(picker)
      if not validate_picker(picker) then
        return false
      end

      -- Check source first (if available)
      local source = picker.opts and picker.opts.source
      if source == "files" or source == "git_files" then
        return true
      end

      -- Fallback: check if it has file-specific characteristics but NOT explorer actions
      local has_explorer_actions = picker.opts
        and picker.opts.actions
        and (picker.opts.actions.explorer_add or picker.opts.actions.explorer_del)

      -- If no explorer actions and has file-like items, assume it's a files picker
      if not has_explorer_actions then
        local current, err = safe_picker_call(picker, "current")
        if not err and current and current.file and not current.dir then
          return true
        end
      end

      return false
    end,
    get_items = function(picker)
      local items = {}

      if not validate_picker(picker) then
        return items
      end

      local selected, err = safe_picker_call(picker, "selected")
      if not err and selected and #selected > 0 then
        items = selected
      end

      if #items == 0 then
        local current, err = safe_picker_call(picker, "current")
        if not err and current then
          items = { current }
        end
      end

      if
        #items == 0
        and picker.list
        and picker.list.selected
        and type(picker.list.selected) == "table"
        and #picker.list.selected > 0
      then
        items = picker.list.selected
      end

      return items
    end,
  },

  buffers = {
    detect = function(picker)
      if not validate_picker(picker) then
        return false
      end

      -- Check source first (if available)
      local source = picker.opts and picker.opts.source
      if source == "buffers" then
        return true
      end

      -- Fallback: check if current item has bufnr
      local current, err = safe_picker_call(picker, "current")
      if not err and current and current.bufnr then
        return true
      end

      return false
    end,
    get_items = function(picker)
      local items = {}

      if not validate_picker(picker) then
        return items
      end

      local selected, err = safe_picker_call(picker, "selected")
      if not err and selected and #selected > 0 then
        items = selected
      end

      if #items == 0 then
        local current, err = safe_picker_call(picker, "current")
        if not err and current then
          items = { current }
        end
      end

      if
        #items == 0
        and picker.list
        and picker.list.selected
        and type(picker.list.selected) == "table"
        and #picker.list.selected > 0
      then
        items = picker.list.selected
      end

      return items
    end,
  },
}

-- Menu actions for different contexts
local actions = {
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
            if picker.refresh then
              picker:refresh()
            end
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
            if picker.refresh then
              picker:refresh()
            end
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
      key = "p",
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
            if picker.refresh then
              picker:refresh()
            end
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
        local confirm =
          vim.fn.confirm("Delete directory " .. vim.fn.fnamemodify(item.file, ":t") .. "?", "&Yes\n&No", 2)
        if confirm == 1 then
          vim.fn.delete(item.file, "rf")
          vim.notify("Deleted directory " .. vim.fn.fnamemodify(item.file, ":t"))
          if picker.refresh then
            picker:refresh()
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
          if picker.refresh then
            picker:refresh()
          end
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
          if picker.refresh then
            picker:refresh()
          end
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
      key = "p",
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
          if picker.refresh then
            picker:refresh()
          end
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
            if picker.refresh then
              picker:refresh()
            end
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
        if picker.refresh then
          picker:refresh()
        end
      end,
    },
    {
      key = "p",
      desc = "Run Save Patterns",
      action = function(picker, items)
        run_save_patterns_action(picker, items)
        if picker.refresh then
          picker:refresh()
        end
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
          if picker.refresh then
            picker:refresh()
          end
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
        if picker.refresh then
          picker:refresh()
        end
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
        if picker.refresh then
          picker:refresh()
        end
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
local function detect_context(picker)
  if not validate_picker(picker) then
    return "unknown", nil
  end

  -- Check contexts in specific order (most specific first)
  local context_order = { "sidebar_explorer", "explorer", "git_status", "buffers", "files" }

  for _, context_name in ipairs(context_order) do
    local context = contexts[context_name]
    if context and context.detect(picker) then
      return context_name, context
    end
  end

  -- Fallback: try to detect based on current item structure
  local current, err = safe_picker_call(picker, "current")
  if not err and current then
    -- If current item has bufnr, it's likely a buffer picker
    if current.bufnr then
      return "buffers", contexts.buffers
    end

    -- If current item has file property, it's likely a file-based picker
    if current.file then
      return "files", contexts.files
    end
  end

  return "unknown", nil
end

-- Get context-appropriate actions
local function get_actions(picker)
  local context_name, context = detect_context(picker)

  if not context then
    return {}, {}
  end

  local items = context.get_items(picker)

  if #items == 0 then
    return {}, {}
  end

  local action_list = {}

  -- Context-specific actions
  if context_name == "explorer" or context_name == "files" then
    if #items == 1 then
      local item = items[1]
      if item.dir then
        vim.list_extend(action_list, actions.single_dir)
      else
        vim.list_extend(action_list, actions.single_file)
      end
    else
      vim.list_extend(action_list, actions.multiple_items)
    end
  elseif context_name == "git_status" then
    vim.list_extend(action_list, actions.git_status_actions)
  elseif context_name == "buffers" then
    vim.list_extend(action_list, actions.buffer_actions)
  end

  -- Add git actions if in git repo (for file-based pickers)
  if
    (context_name == "explorer" or context_name == "files")
    and (vim.fn.isdirectory(".git") == 1 or vim.fn.finddir(".git", ".;") ~= "")
  then
    vim.list_extend(action_list, actions.git_actions)
  end

  return action_list, items
end

-- Show context menu
M.show_context_menu = function(picker)
  if not validate_picker(picker) then
    return
  end

  local action_list, items = get_actions(picker)
  local context_name, context = detect_context(picker)

  if #action_list == 0 then
    -- For unknown contexts, provide basic file actions if we can get current item
    if context_name == "unknown" then
      local current, err = safe_picker_call(picker, "current")
      if not err and current and current.file then
        action_list = actions.single_file
        items = { current }
      end
    end

    if #action_list == 0 then
      error(
        "No actions available. Context: "
          .. (context_name or "unknown")
          .. ", Items: "
          .. #items
          .. "\nPicker state: "
          .. vim.inspect({
            source = picker.opts and picker.opts.source,
            has_actions = picker.opts and picker.opts.actions and vim.tbl_keys(picker.opts.actions) or {},
            current_item = safe_picker_call(picker, "current"),
            selected_items = safe_picker_call(picker, "selected"),
          })
      )
    end
  end

  -- Create menu items for vim.ui.select
  local menu_options = {}
  local action_map = {}

  for i, action in ipairs(action_list) do
    local option_text = string.format("[%s] %s", action.key, action.desc)
    table.insert(menu_options, option_text)
    action_map[i] = action
  end

  -- Show menu using vim.ui.select
  vim.ui.select(menu_options, {
    prompt = "Choose action:",
    format_item = function(item)
      return item
    end,
  }, function(choice, idx)
    if choice and idx and action_map[idx] then
      local action = action_map[idx]
      if #items == 1 then
        action.action(picker, items[1])
      else
        action.action(picker, items)
      end
    end
  end)
end

-- ============================================================================
-- PUBLIC API
-- ============================================================================

-- Export all picker action functions for use in snacks.lua
M.actions = {
  open_multiple_buffers = M.open_multiple_buffers,
  copy_file_path = M.copy_file_path,
  search_in_directory = M.search_in_directory,
  diff_selected = M.diff_selected,
  handle_directory_expansion = M.handle_directory_expansion,
}

-- Export context menu function (main entry point)
M.show_menu = M.show_context_menu

return M
