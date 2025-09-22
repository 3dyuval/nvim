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

-- Get current focused item from picker (follows folke's architecture)
M.get_current_item = function(picker)
  if not validate_picker(picker) then
    return nil, "Invalid picker"
  end

  -- Use folke's standard method: picker:current()
  if type(picker.current) == "function" then
    local success, item = pcall(picker.current, picker)
    if success and item then
      return item, nil
    end
  end

  -- Fallback to list:current() if picker:current() fails
  if picker.list and type(picker.list.current) == "function" then
    local success, item = pcall(picker.list.current, picker.list)
    if success and item then
      return item, nil
    end
  end

  return nil, "No current item found"
end

-- Extract branch name from picker item (follows folke's git.lua patterns)
M.get_branch_name = function(item)
  if not item then
    return nil
  end

  -- If item has a branch field (folke's standard), use it
  if type(item) == "table" and item.branch then
    return item.branch
  end

  -- If item has text field, try to parse it using folke's patterns
  if type(item) == "table" and item.text then
    local commit_pat = ("[a-z0-9]"):rep(7)
    local patterns = {
      -- e.g. "* (HEAD detached at f65a2c8) f65a2c8 chore(build): auto-generate docs"
      "^(.)%s(%b())%s+("
        .. commit_pat
        .. ")%s*(.*)$",
      -- e.g. "  main                       d2b2b7b [origin/main: behind 276] chore(build): auto-generate docs"
      "^(.)%s(%S+)%s+("
        .. commit_pat
        .. ")%s*(.*)$",
    }

    for p, pattern in ipairs(patterns) do
      local status, branch, _commit, _msg = item.text:match(pattern)
      if status and branch then
        local detached = p == 1
        if not detached then
          return branch
        end
      end
    end

    -- Fallback: simple cleanup for basic branch names
    local cleaned = item.text:gsub("^%s*%*?%s*", ""):gsub("%s+$", "")
    -- Handle remotes/ prefix properly
    if cleaned:match("^remotes/") then
      cleaned = cleaned:gsub("^remotes/", "")
    end
    -- Extract just the branch name (before any whitespace/commit info)
    local branch_only = cleaned:match("^(%S+)")
    if branch_only and branch_only ~= "" then
      return branch_only
    end
  end

  -- Handle string items (simple branch names)
  if type(item) == "string" then
    local cleaned = item:gsub("^%s*%*?%s*", ""):gsub("%s+$", "")
    cleaned = cleaned:gsub("^remotes/", "")
    return cleaned ~= "" and cleaned or nil
  end

  return nil
end

-- ============================================================================
-- PICKER ACTIONS
-- ============================================================================

-- Reusable format action function
local function format_action(picker, item_or_items)
  -- Handle both single item and multiple items
  local items
  if type(item_or_items) == "table" and item_or_items[1] then
    -- Multiple items array
    items = item_or_items
  else
    -- Single item or selected items
    local selected = safe_picker_call(picker, "selected") or {}
    if #selected > 0 then
      items = selected
    else
      items = { item_or_items }
    end
  end

  -- Collect all files to format
  local files_to_format = {}
  for _, selected_item in ipairs(items) do
    if selected_item.dir or vim.fn.isdirectory(selected_item.file) == 1 then
      -- Directory: find all supported files recursively
      local find_cmd = string.format(
        "find %s -type f \\( -name '*.js' -o -name '*.jsx' -o -name '*.ts' -o -name '*.tsx' -o -name '*.json' -o -name '*.lua' -o -name '*.html' -o -name '*.vue' -o -name '*.css' -o -name '*.scss' \\)",
        vim.fn.shellescape(selected_item.file)
      )
      local dir_files = vim.fn.systemlist(find_cmd)
      for _, file in ipairs(dir_files) do
        if vim.fn.filereadable(file) == 1 then
          table.insert(files_to_format, file)
        end
      end
    else
      -- Single file: add if readable
      if vim.fn.filereadable(selected_item.file) == 1 then
        table.insert(files_to_format, selected_item.file)
      end
    end
  end

  -- Format all collected files
  if #files_to_format > 0 then
    for _, file in ipairs(files_to_format) do
      -- Use conform directly since it now handles import organization
      local conform = require("conform")
      local ok, bufnr = pcall(vim.fn.bufnr, file, true)
      if ok and bufnr > 0 then
        pcall(vim.fn.bufload, bufnr)
        pcall(conform.format, { bufnr = bufnr, timeout_ms = 5000 })
      end
    end

    -- Refresh picker if possible
    if picker.refresh then
      picker:refresh()
    end
  end
end

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

  -- Create ordered list with icons and values
  local copy_options = {
    { key = "PATH (CWD)", icon = "󰉋", value = vim.fn.fnamemodify(item.file, ":.") },
    { key = "PATH (HOME)", icon = "󰋜", value = vim.fn.fnamemodify(item.file, ":~") },
    { key = "FILE CONTENT", icon = "󰈙", value = "file_content" },
    { key = "FILENAME", icon = "󰈔", value = vim.fn.fnamemodify(item.file, ":t") },
    { key = "PATH", icon = "󰆏", value = item.file },
    { key = "BASENAME", icon = "󰈙", value = vim.fn.fnamemodify(item.file, ":t:r") },
    { key = "EXTENSION", icon = "󰈙", value = vim.fn.fnamemodify(item.file, ":t:e") },
    { key = "URI", icon = "󰌷", value = vim.uri_from_fname(item.file) },
  }

  -- Filter out empty values and create menu options
  local menu_options = {}
  local option_map = {}

  for i, option in ipairs(copy_options) do
    if option.value and option.value ~= "" then
      local display_text = string.format("%s %s: %s", option.icon, option.key, option.value)
      table.insert(menu_options, display_text)
      option_map[#menu_options] = option
    end
  end

  if #menu_options == 0 then
    vim.notify("No values to copy", vim.log.levels.WARN)
    return
  end

  vim.ui.select(menu_options, {
    prompt = "Choose to copy to clipboard:",
    format_item = function(list_item)
      return list_item
    end,
  }, function(choice, idx)
    if choice and idx and option_map[idx] then
      local selected_option = option_map[idx]
      local result = selected_option.value

      if selected_option.key == "FILE CONTENT" then
        if vim.fn.filereadable(item.file) == 0 then
          vim.notify("File not readable: " .. item.file, vim.log.levels.ERROR)
          return
        end
        local content = vim.fn.readfile(item.file)
        local content_str = table.concat(content, "\n")
        vim.fn.setreg("+", content_str)
        local filename = vim.fn.fnamemodify(item.file, ":t")
        local line_count = #content
        Snacks.notify.info(
          string.format("File content copied to clipboard: %s (%d lines)", filename, line_count)
        )
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

-- Format files using conform.nvim
local function format_files_action(picker, items)
  local conform = require("conform")
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

        -- Use conform directly since it now handles import organization
        conform.format({ bufnr = bufnr, timeout_ms = 5000 })
        processed = processed + 1

        if vim.bo[bufnr].modified then
          vim.api.nvim_buf_call(bufnr, function()
            vim.cmd("silent! write")
          end)
        end
      end)

      if not success then
        errors = errors + 1
        vim.notify(
          "Error formatting "
            .. vim.fn.fnamemodify(item.file, ":t")
            .. ": "
            .. (err or "unknown error"),
          vim.log.levels.WARN
        )
      end
    end
  end

  if processed > 0 then
    vim.notify(
      string.format(
        "Formatted %d files%s",
        processed,
        errors > 0 and " (" .. errors .. " errors)" or ""
      )
    )
  else
    vim.notify("No files formatted", vim.log.levels.WARN)
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
        and (
          picker.opts.actions.explorer_add
          or picker.opts.actions.explorer_del
          or picker.opts.actions.explorer_open
        )

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

  git_branches = {
    detect = function(picker)
      if not validate_picker(picker) then
        return false
      end

      -- Check source first (most reliable method, follows folke's pattern)
      local source = picker.opts and picker.opts.source
      if source == "git_branches" then
        return true
      end

      -- Check if picker has git branch-specific properties
      local current, err = M.get_current_item(picker)
      if not err and current then
        -- Check for folke's git branch item structure
        if type(current) == "table" then
          -- Look for git branch specific fields (from folke's git.lua)
          if
            current.branch
            or current.commit
            or current.current ~= nil
            or current.detached ~= nil
          then
            return true
          end

          -- Check if text field matches git branch patterns
          if current.text then
            local commit_pat = ("[a-z0-9]"):rep(7)
            local patterns = {
              "^(.)%s(%b())%s+(" .. commit_pat .. ")%s*(.*)$",
              "^(.)%s(%S+)%s+(" .. commit_pat .. ")%s*(.*)$",
            }
            for _, pattern in ipairs(patterns) do
              if current.text:match(pattern) then
                return true
              end
            end
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

      -- Try to get selected items first
      local selected, err = safe_picker_call(picker, "selected")
      if not err and selected and #selected > 0 then
        items = selected
      end

      -- Fallback to current item
      if #items == 0 then
        local current, err = M.get_current_item(picker)
        if not err and current then
          items = { current }
        end
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
      key = "f",
      desc = "󰉋 Format file",
      action = function(picker, item)
        local formatter = require("utils.formatter")
        if item.dir then
          -- Format directory recursively
          formatter.format_batch({ item.file }, {
            verbose = true,
            on_complete = function(status)
              if picker.refresh then
                picker:refresh()
              end
            end,
          })
        else
          -- Format single file
          formatter.format_file(item.file, {
            verbose = true,
            on_complete = function(status)
              if picker.refresh then
                picker:refresh()
              end
            end,
          })
        end
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
        local confirm =
          vim.fn.confirm("Delete " .. vim.fn.fnamemodify(item.file, ":t") .. "?", "&Yes\n&No", 2)
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
      key = "f",
      desc = "Format files",
      action = format_action,
    },
    {
      key = "f",
      desc = "Format files",
      action = format_files_action,
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
        local confirm = vim.fn.confirm(
          "Delete directory " .. vim.fn.fnamemodify(item.file, ":t") .. "?",
          "&Yes\n&No",
          2
        )
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
      key = "f",
      desc = "Format files in directory",
      action = format_action,
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
    {
      key = "f",
      desc = "󰈔 Format directory",
      action = function(picker, item)
        local formatter = require("utils.formatter")
        formatter.format_batch({ item.file }, {
          verbose = true,
          on_complete = function(status)
            if picker.refresh then
              picker:refresh()
            end
          end,
        })
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
      key = "f",
      desc = "Format selected files",
      action = format_action,
    },
    {
      key = "f",
      desc = "Format files",
      action = format_files_action,
    },
    {
      key = "f",
      desc = "󰉋 Format selected items",
      action = function(picker, items)
        local formatter = require("utils.formatter")
        local paths = {}
        for _, item in ipairs(items) do
          if item.file then
            table.insert(paths, item.file)
          end
        end

        if #paths > 0 then
          formatter.format_batch(paths, {
            verbose = true,
            on_complete = function(status)
              if picker.refresh then
                picker:refresh()
              end
            end,
          })
        end
      end,
    },
  },

  -- Basic git actions (use Snacks built-ins when possible)
  git_actions = {
    {
      key = "s",
      desc = "Stage/Unstage files",
      action = function(picker, items)
        -- Use Snacks built-in git_stage action
        require("snacks").picker.actions.git_stage(picker)
      end,
    },
  },

  -- Git status specific actions (using Snacks built-ins)
  git_status_actions = {
    {
      key = "p",
      desc = "Run Save Patterns",
      action = function(picker, items)
        format_files_action(picker, items)
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
            local success, _err = pcall(function()
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
          format_files_action(picker, file_items)
        else
          vim.notify("No valid files found in selected buffers", vim.log.levels.WARN)
        end
      end,
    },
  },

  -- Git branch-specific actions (using Snacks built-ins)
  git_branch_actions = {
    {
      key = "c",
      desc = "Checkout branch",
      action = function(picker, item)
        -- Use Snacks built-in git_checkout action
        require("snacks").picker.actions.git_checkout(picker, item)
      end,
    },
    {
      key = "d",
      desc = "Delete branch",
      action = function(picker, item)
        -- Use Snacks built-in git_branch_del action
        require("snacks").picker.actions.git_branch_del(picker, item)
      end,
    },
    {
      key = "n",
      desc = "Create new branch",
      action = function(picker, item)
        -- Use Snacks built-in git_branch_add action
        require("snacks").picker.actions.git_branch_add(picker)
      end,
    },
    -- Keep some custom actions that don't have direct Snacks equivalents
    {
      key = "l",
      desc = "Show log",
      action = function(picker, item)
        local branch = M.get_branch_name(item)
        if not branch then
          vim.notify("No branch selected", vim.log.levels.WARN)
          return
        end
        Snacks.picker.git_log({ branch = branch })
      end,
    },
    {
      key = "v",
      desc = "View diff vs current branch",
      action = function(picker, item)
        local branch = M.get_branch_name(item)
        if not branch then
          vim.notify("No branch selected", vim.log.levels.WARN)
          return
        end
        vim.cmd("DiffviewOpen HEAD.." .. branch)
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
  local context_order =
    { "sidebar_explorer", "explorer", "git_branches", "git_status", "buffers", "files" }

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

-- Get context-appropriate actions (follows folke's action pattern)
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

  -- Context-specific actions (prioritize git contexts like folke does)
  if context_name == "git_branches" then
    vim.list_extend(action_list, actions.git_branch_actions)
  elseif context_name == "git_status" then
    vim.list_extend(action_list, actions.git_status_actions)
    -- Add built-in git stage action
    table.insert(action_list, {
      key = "s",
      desc = "Stage/Unstage files",
      action = function(picker, items)
        require("snacks").picker.actions.git_stage(picker)
      end,
    })
  elseif context_name == "buffers" then
    vim.list_extend(action_list, actions.buffer_actions)
  elseif context_name == "explorer" or context_name == "files" then
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

    -- Add git actions if in git repo (for file-based pickers)
    if vim.fn.isdirectory(".git") == 1 or vim.fn.finddir(".git", ".;") ~= "" then
      vim.list_extend(action_list, actions.git_actions)
    end
  end

  -- Dynamically update descriptions based on selection state
  local selected_items = {}
  local current_item = nil

  -- Check if we have selected items
  local selected, err = safe_picker_call(picker, "selected")
  if not err and selected and #selected > 0 then
    selected_items = selected
  end

  -- Get current item
  local current, current_err = safe_picker_call(picker, "current")
  if not current_err and current then
    current_item = current
  end

  -- Update format action descriptions with icons
  for _, action in ipairs(action_list) do
    if action.key == "f" then
      if #selected_items > 0 then
        if #selected_items == 1 then
          local item = selected_items[1]
          if item.dir then
            action.desc = "󰈔 Format selected directory (recursive)"
          else
            -- Get file icon if possible
            local icon = "󰈙" -- default file icon
            if item.file then
              local ok, devicons = pcall(require, "nvim-web-devicons")
              if ok then
                local file_icon = devicons.get_icon(vim.fn.fnamemodify(item.file, ":t"))
                if file_icon then
                  icon = file_icon
                end
              end
            end
            action.desc = icon .. " Format selected file"
          end
        else
          action.desc = "󰈔 Format selected items (" .. #selected_items .. ")"
        end
      else
        -- No selection, use hovered item
        if current_item then
          if current_item.dir then
            action.desc = "󰈔 Format hovered directory (recursive)"
          else
            -- Get file icon if possible
            local icon = "󰈙" -- default file icon
            if current_item.file then
              local ok, devicons = pcall(require, "nvim-web-devicons")
              if ok then
                local file_icon = devicons.get_icon(vim.fn.fnamemodify(current_item.file, ":t"))
                if file_icon then
                  icon = file_icon
                end
              end
            end
            action.desc = icon .. " Format hovered file"
          end
        else
          action.desc = "󰈙 Format item"
        end
      end
    end
  end

  return action_list, items
end

-- Context menu action that shows a vim.ui.select menu
M.context_menu = function(picker, item)
  local formatter = require("utils.formatter")

  -- Determine what we're working with
  local menu_title
  local target_items = { item }

  if item then
    if item.dir then
      menu_title = "󰈔 " .. vim.fn.fnamemodify(item.file, ":t") .. " (Directory)"
    else
      menu_title = "󰈙 " .. vim.fn.fnamemodify(item.file, ":t")
    end
  else
    vim.notify("No item available", vim.log.levels.WARN)
    return
  end

  -- Create menu options
  local options = {}
  local actions = {}

  -- Format action
  table.insert(options, "󰉋 Format")
  table.insert(actions, function()
    -- Use the unified format action that works with any scenario
    format_action(picker, item)
  end)

  -- Rename action
  table.insert(options, "󰑕 Rename")
  table.insert(actions, function()
    if #target_items == 1 then
      local target_item = target_items[1]
      local new_name = vim.fn.input("Rename to: ", vim.fn.fnamemodify(target_item.file, ":t"))
      if new_name and new_name ~= "" then
        local new_path = vim.fn.fnamemodify(target_item.file, ":h") .. "/" .. new_name
        local ok, err = os.rename(target_item.file, new_path)
        if ok then
          vim.notify("Renamed to " .. new_name)
          if picker.refresh then
            picker:refresh()
          end
        else
          vim.notify("Failed to rename: " .. (err or "unknown error"), vim.log.levels.ERROR)
        end
      end
    end
  end)

  -- Delete action
  table.insert(options, "󰆴 Delete")
  table.insert(actions, function()
    local count = #target_items
    local confirm = vim.fn.confirm("Delete " .. count .. " items?", "&Yes\n&No", 2)
    if confirm == 1 then
      for _, target_item in ipairs(target_items) do
        if target_item.dir then
          vim.fn.delete(target_item.file, "rf")
        else
          os.remove(target_item.file)
        end
      end
      vim.notify("Deleted " .. count .. " items")
      if picker.refresh then
        picker:refresh()
      end
    end
  end)

  -- Show the menu
  vim.ui.select(options, {
    prompt = menu_title .. " - Choose action:",
    format_item = function(item)
      return item
    end,
  }, function(choice, idx)
    if choice and idx and actions[idx] then
      actions[idx]()
    end
  end)
end

-- Git-specific context menu for git_status picker
M.git_context_menu = function(picker, item)
  local formatter = require("utils.formatter")

  if not item then
    vim.notify("No item available", vim.log.levels.WARN)
    return
  end

  local target_items = { item }
  local menu_title = "󰈙 " .. vim.fn.fnamemodify(item.file, ":t") .. " (Git)"

  -- Create menu options
  local options = {}
  local actions = {}

  -- Conflict filter toggle action
  local is_conflict_filter_active = picker._conflict_filter_active or false
  local conflict_toggle_text = is_conflict_filter_active and "󰍉 Show All Files"
    or "󰍉 Show Only Conflicts"
  table.insert(options, conflict_toggle_text)
  table.insert(actions, function()
    -- Use the proper toggle function
    M.toggle_conflict_filter(picker)
  end)

  -- Format action
  table.insert(options, "󰉋 Format")
  table.insert(actions, function()
    local paths = {}
    for _, target_item in ipairs(target_items) do
      if target_item.file then
        table.insert(paths, target_item.file)
      end
    end

    if #paths > 0 then
      formatter.format_file(paths[1], {
        verbose = true,
        on_complete = function(status)
          if picker.refresh then
            picker:refresh()
          end
        end,
      })
    end
  end)

  -- Stage/unstage action
  table.insert(options, "󰊢 Stage/Unstage")
  table.insert(actions, function()
    for _, target_item in ipairs(target_items) do
      local file = target_item.file
      if
        target_item.status
        and (
          target_item.status:match("^M")
          or target_item.status:match("^A")
          or target_item.status:match("^D")
        )
      then
        -- File is staged, unstage it
        vim.system({ "git", "restore", "--staged", file })
      else
        -- File is unstaged, stage it
        vim.system({ "git", "add", file })
      end
    end
    vim.notify("Toggled stage status for " .. #target_items .. " files")
    if picker.refresh then
      picker:refresh()
    end
  end)

  -- Copy path action
  table.insert(options, "󰆏 Copy Path")
  table.insert(actions, function()
    local paths = {}
    for _, target_item in ipairs(target_items) do
      table.insert(paths, target_item.file)
    end
    vim.fn.setreg("+", table.concat(paths, "\n"))
    vim.notify("Copied " .. #paths .. " paths")
  end)

  -- Show the menu
  vim.ui.select(options, {
    prompt = menu_title .. " - Choose action:",
    format_item = function(item)
      return item
    end,
  }, function(choice, idx)
    if choice and idx and actions[idx] then
      actions[idx]()
    end
  end)
end

-- Buffer-specific context menu for buffer picker
M.buffer_context_menu = function(picker, item)
  local formatter = require("utils.formatter")

  if not item then
    vim.notify("No item available", vim.log.levels.WARN)
    return
  end

  local target_items = { item }
  local menu_title = "󰈙 "
    .. (item.name or vim.fn.fnamemodify(vim.api.nvim_buf_get_name(item.bufnr or 0), ":t"))

  -- Create menu options
  local options = {}
  local actions = {}

  -- Format action
  table.insert(options, "󰉋 Format")
  table.insert(actions, function()
    local paths = {}
    for _, target_item in ipairs(target_items) do
      if target_item.bufnr and vim.api.nvim_buf_is_loaded(target_item.bufnr) then
        local filepath = vim.api.nvim_buf_get_name(target_item.bufnr)
        if filepath and filepath ~= "" then
          table.insert(paths, filepath)
        end
      end
    end

    if #paths > 0 then
      formatter.format_file(paths[1], {
        verbose = true,
        on_complete = function(status)
          if picker.refresh then
            picker:refresh()
          end
        end,
      })
    end
  end)

  -- Copy path action
  table.insert(options, "󰆏 Copy Path")
  table.insert(actions, function()
    local paths = {}
    for _, target_item in ipairs(target_items) do
      if target_item.bufnr and vim.api.nvim_buf_is_loaded(target_item.bufnr) then
        local filepath = vim.api.nvim_buf_get_name(target_item.bufnr)
        if filepath and filepath ~= "" then
          table.insert(paths, filepath)
        end
      end
    end
    vim.fn.setreg("+", table.concat(paths, "\n"))
    vim.notify("Copied " .. #paths .. " paths")
  end)

  -- Delete buffer action
  table.insert(options, "󰖭 Delete Buffer")
  table.insert(actions, function()
    for _, target_item in ipairs(target_items) do
      if target_item.bufnr then
        vim.api.nvim_buf_delete(target_item.bufnr, { force = false })
      end
    end
    vim.notify("Deleted " .. #target_items .. " buffers")
    if picker.refresh then
      picker:refresh()
    end
  end)

  -- Save buffer action
  table.insert(options, "󰆓 Save Buffer")
  table.insert(actions, function()
    local saved = 0
    for _, target_item in ipairs(target_items) do
      if target_item.bufnr and vim.api.nvim_buf_is_loaded(target_item.bufnr) then
        local success, _err = pcall(function()
          vim.api.nvim_buf_call(target_item.bufnr, function()
            vim.cmd("write")
          end)
        end)
        if success then
          saved = saved + 1
        end
      end
    end
    vim.notify("Saved " .. saved .. "/" .. #target_items .. " buffers")
  end)

  -- Show the menu
  vim.ui.select(options, {
    prompt = menu_title .. " - Choose action:",
    format_item = function(item)
      return item
    end,
  }, function(choice, idx)
    if choice and idx and actions[idx] then
      actions[idx]()
    end
  end)
end

-- Git conflicts filter function - filters items to show only conflicted files
M.filter_conflicts = function(item, ctx)
  -- Debug: print the item structure to understand what fields are available
  if vim.g.debug_git_conflicts then
    print("Git item debug:")
    print("  status:", vim.inspect(item.status))
    print("  git_status:", vim.inspect(item.git_status))
    print("  text:", vim.inspect(item.text))
    print("  full item:", vim.inspect(item))
  end

  -- Try different possible fields for git status
  local status = item.status or item.git_status
  if status and (status:match("UU") or status:match("AA") or status:match("DD")) then
    return item
  end
  return false -- Filter out non-conflicted files (use false, not nil)
end

-- Git conflicts picker - dedicated picker for conflicted files only
M.git_conflicts = function()
  Snacks.picker.git_status({
    transform = M.filter_conflicts,
    auto_close = false,
    layout = "sidebar",
    win = {
      title = "Git Conflicts",
      list = {
        keys = {
          ["f"] = "git_context_menu",
          ["s"] = { "git_stage", mode = { "n", "i" } },
        },
      },
    },
    actions = {
      git_context_menu = {
        action = function(picker, item)
          require("utils.picker-extensions").actions.git_context_menu(picker, item)
        end,
      },
    },
  })
end

-- Git status: Toggle conflict filter
M.toggle_conflict_filter = function(picker)
  -- Toggle the conflict filter state
  picker._conflict_filter_active = not picker._conflict_filter_active

  if picker._conflict_filter_active then
    vim.notify("Showing only conflicted files", vim.log.levels.INFO)
    -- Store original filter search
    picker._original_filter_search = picker.filter.search
    -- Set filter to match conflict patterns
    picker.filter.search = "UU|AA|DD"
    picker.filter.opts = vim.tbl_extend("force", picker.filter.opts or {}, {
      -- Make sure we're searching in the status field
      fields = { "status" },
    })
  else
    vim.notify("Showing all git status files", vim.log.levels.INFO)
    -- Restore original filter
    picker.filter.search = picker._original_filter_search or ""
    picker.filter.opts.fields = nil
  end

  -- Update the filter
  picker:update_filter()
end

-- ============================================================================
-- PUBLIC API
-- ============================================================================

-- Explorer: Duplicate file/folder
M.duplicate_file = function(picker, item)
  if not item then
    vim.notify("No item provided", vim.log.levels.WARN)
    return
  end

  local source = item.file
  local source_name = vim.fn.fnamemodify(source, ":t")
  local source_dir = vim.fn.fnamemodify(source, ":h")
  local source_ext = vim.fn.fnamemodify(source, ":e")
  local source_base = vim.fn.fnamemodify(source, ":t:r")

  -- Generate default duplicate name
  local default_name
  if item.dir then
    default_name = source_name .. "_copy"
  else
    if source_ext ~= "" then
      default_name = source_base .. "_copy." .. source_ext
    else
      default_name = source_name .. "_copy"
    end
  end

  local new_name = vim.fn.input("Duplicate as: ", default_name)
  if new_name and new_name ~= "" then
    local target = source_dir .. "/" .. new_name

    -- Check if target already exists
    if vim.fn.filereadable(target) == 1 or vim.fn.isdirectory(target) == 1 then
      vim.notify("Target already exists: " .. new_name, vim.log.levels.ERROR)
      return
    end

    if item.dir then
      -- Duplicate directory
      local cmd = { "cp", "-r", source, target }
      local result = vim.fn.system(cmd)
      if vim.v.shell_error == 0 then
        vim.notify("Duplicated directory: " .. new_name)
        if picker.refresh then
          picker:refresh()
        end
      else
        vim.notify(
          "Failed to duplicate directory: " .. (result or "unknown error"),
          vim.log.levels.ERROR
        )
      end
    else
      -- Duplicate file
      local cmd = { "cp", source, target }
      local result = vim.fn.system(cmd)
      if vim.v.shell_error == 0 then
        vim.notify("Duplicated file: " .. new_name)
        if picker.refresh then
          picker:refresh()
        end
      else
        vim.notify(
          "Failed to duplicate file: " .. (result or "unknown error"),
          vim.log.levels.ERROR
        )
      end
    end
  end
end

-- Export all picker action functions for use in snacks.lua
M.actions = {
  open_multiple_buffers = M.open_multiple_buffers,
  copy_file_path = M.copy_file_path,
  search_in_directory = M.search_in_directory,
  diff_selected = M.diff_selected,
  handle_directory_expansion = M.handle_directory_expansion,
  format_action = format_action,
  toggle_conflict_filter = M.toggle_conflict_filter,
  git_conflicts = M.git_conflicts,
  git_conflicts_explorer = M.git_conflicts_explorer,
  filter_conflicts = M.filter_conflicts,
  filter_conflicts_explorer = M.filter_conflicts_explorer,
  duplicate_file = M.duplicate_file,
  -- Context menu actions (which-key based)
  context_menu = M.context_menu,
  git_context_menu = M.git_context_menu,
  buffer_context_menu = M.buffer_context_menu,
}

return M
