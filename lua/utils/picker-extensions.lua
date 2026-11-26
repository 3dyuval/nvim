-- [nfnl] fnl/utils/picker-extensions.fnl
local M = {}
local explorer_layout = (vim.g.explorer_layout or "sidebar")
local function floating_layout_3f(preset)
  return ((preset == "default") or (preset == "fullscreen"))
end
local function preview_for_layout(preset)
  return floating_layout_3f(preset)
end
local _path_signal = nil
local function path_signal()
  if not _path_signal then
    local ok, t = pcall(require, "u.tracker")
    if ok then
      _path_signal = t.create_signal(nil)
    else
    end
  else
  end
  return _path_signal
end
local function validate_picker(picker)
  if picker and (type(picker) == "table") then
    return true
  else
    vim.notify("Invalid picker object", vim.log.levels.ERROR)
    return false
  end
end
local function safe_call(picker, method, ...)
  if not validate_picker(picker) then
    return nil, "Invalid picker"
  elseif type(picker[method]) == "function" then
    local args = { ... }
    local ok, res
    local function _4_()
      return picker[method](picker, table.unpack(args))
    end
    ok, res = pcall(_4_)
    if ok then
      return res, nil
    else
      return nil, res
    end
  else
    return nil, ("Method " .. method .. " not available")
  end
end
local function picker_items(picker)
  local sel, _ = safe_call(picker, "selected")
  if sel and (#sel > 0) then
    return sel
  else
    local cur, _0 = safe_call(picker, "current")
    if cur then
      return { cur }
    elseif
      picker.list
      and picker.list.selected
      and (type(picker.list.selected) == "table")
      and (#picker.list.selected > 0)
    then
      return picker.list.selected
    else
      return {}
    end
  end
end
M.open_explorer = function(opts)
  local old_shortmess = vim.o.shortmess
  vim.o.shortmess = (vim.o.shortmess .. "A")
  if opts and opts.layout and opts.layout.preset then
    explorer_layout = opts.layout.preset
    vim.g.explorer_layout = explorer_layout
  else
  end
  local focus_editor
  local function _10_(picker)
    if picker.main and vim.api.nvim_win_is_valid(picker.main) then
      return vim.api.nvim_set_current_win(picker.main)
    else
      return vim.cmd("wincmd l")
    end
  end
  focus_editor = _10_
  local win_override
  if not floating_layout_3f(explorer_layout) then
    win_override = {
      input = { keys = { ["<Esc>"] = { "focus_editor", mode = { "n", "i" } } } },
      list = { keys = { ["<Esc>"] = "focus_editor" } },
    }
  else
    win_override = nil
  end
  local config
  local function _13_(picker)
    vim.g.explorer_was_open = false
    local item = picker:current()
    if item and (item.file or item.dir) then
      local s = path_signal()
      if s then
        return s:set((item.file or item.dir))
      else
        return nil
      end
    else
      return nil
    end
  end
  local function _16_(picker)
    vim.g.explorer_was_open = true
    if not floating_layout_3f(explorer_layout) then
      local s = path_signal()
      local path = (s and s:get())
      if path then
        local function _17_()
          local found = false
          for i, item in ipairs(picker.list.items) do
            if found then
              break
            end
            if item and ((item.file == path) or (item.dir == path)) then
              picker.list:view(i)
              found = true
            else
            end
          end
          return nil
        end
        return picker:find({ on_done = _17_ })
      else
        return nil
      end
    else
      return nil
    end
  end
  config = vim.tbl_deep_extend(
    "force",
    {
      layout = { preset = explorer_layout, preview = preview_for_layout(explorer_layout) },
      auto_close = floating_layout_3f(explorer_layout),
      win = win_override,
      actions = { focus_editor = { action = focus_editor } },
      on_close = _13_,
      on_show = _16_,
      root = false,
    },
    (opts or {})
  )
  Snacks.picker.explorer(config)
  vim.o.shortmess = old_shortmess
  return nil
end
M.get_current_item = function(picker)
  if not validate_picker(picker) then
    return nil, "Invalid picker"
  else
    if type(picker.current) == "function" then
      local ok, item = pcall(picker.current, picker)
      if ok and item then
        return item, nil
      else
      end
    else
    end
    if picker.list and (type(picker.list.current) == "function") then
      local ok, item = pcall(picker.list.current, picker.list)
      if ok and item then
        return item, nil
      else
      end
    else
    end
    return nil, "No current item found"
  end
end
M.get_branch_name = function(item)
  if not item then
    return nil
  elseif (type(item) == "table") and item.branch then
    return item.branch
  elseif (type(item) == "table") and item.text then
    local commit_pat = string.rep("[a-z0-9]", 7)
    local patterns =
      { ("^(.)%s(%b())%s+(" .. commit_pat .. ")%s*(.*)$"), ("^(.)%s(%S+)%s+(" .. commit_pat .. ")%s*(.*)$") }
    local result = nil
    for p, pattern in ipairs(patterns) do
      if result then
        break
      end
      local status, branch = item.text:match(pattern)
      if status and branch and not (p == 1) then
        result = branch
      else
      end
    end
    if result then
      return result
    else
      local cleaned = item.text:gsub("^%s*%*?%s*", ""):gsub("%s+$", "")
      local cleaned0
      if cleaned:match("^remotes/") then
        cleaned0 = cleaned:gsub("^remotes/", "")
      else
        cleaned0 = cleaned
      end
      local branch_only = cleaned0:match("^(%S+)")
      if branch_only and not (branch_only == "") then
        return branch_only
      else
        return nil
      end
    end
  elseif type(item) == "string" then
    local cleaned = item:gsub("^%s*%*?%s*", ""):gsub("%s+$", ""):gsub("^remotes/", "")
    if not (cleaned == "") then
      return cleaned
    else
      return nil
    end
  else
    return nil
  end
end
M.open_multiple_buffers = function(picker)
  if validate_picker(picker) then
    local sel, err = safe_call(picker, "selected")
    if err then
      return vim.notify(("Could not get selected items: " .. err), vim.log.levels.WARN)
    else
      local sel0 = (sel or {})
      if #sel0 == 0 then
        return vim.notify("No files selected", vim.log.levels.WARN)
      else
        picker:close()
        for _, item in ipairs(sel0) do
          if item and item.file then
            vim.cmd(("edit " .. vim.fn.fnameescape(item.file)))
          else
          end
        end
        return vim.notify(string.format("Opened %d file(s)", #sel0))
      end
    end
  else
    return nil
  end
end
M.search_in_directory = function(picker, item)
  if not item then
    return vim.notify("No item provided", vim.log.levels.WARN)
  else
    return Snacks.picker.grep({
      cwd = vim.fn.fnamemodify(item.file, ":p:h"),
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
      supports_live = true,
      follow = false,
    })
  end
end
M.diff_selected = function(picker)
  if validate_picker(picker) then
    picker:close()
    local sel, err = safe_call(picker, "selected")
    if err then
      return vim.notify(("Could not get selected items: " .. err), vim.log.levels.WARN)
    else
      local sel0 = (sel or {})
      if #sel0 >= 2 then
        Snacks.notify.info(sel0[1].file)
        vim.cmd(("tabnew " .. sel0[1].file))
        vim.cmd(("vert diffs " .. sel0[2].file))
        return Snacks.notify.info(("Diffing " .. sel0[1].file .. " against " .. sel0[2].file))
      else
        return Snacks.notify.info("Select two entries for the diff")
      end
    end
  else
    return nil
  end
end
M.handle_directory_expansion = function(picker)
  if validate_picker(picker) then
    local item, err = safe_call(picker, "current")
    if err then
      return vim.notify(("Could not get current item: " .. err), vim.log.levels.WARN)
    else
      if item and item.dir then
        return picker:confirm()
      else
        return nil
      end
    end
  else
    return nil
  end
end
M.copy_file_path = function(picker, item)
  local sel, err = safe_call(picker, "selected")
  local items
  if not err and sel and (#sel > 0) then
    items = sel
  elseif item then
    items = { item }
  else
    items = nil
  end
  if not items then
    return vim.notify("No item provided", vim.log.levels.WARN)
  else
    local is_multi = (#items > 1)
    local copy_options
    if is_multi then
      local paths_cwd = {}
      local paths_home = {}
      local filenames = {}
      local paths_abs = {}
      for _, itm in ipairs(items) do
        table.insert(paths_cwd, vim.fn.fnamemodify(itm.file, ":."))
        table.insert(paths_home, vim.fn.fnamemodify(itm.file, ":~"))
        table.insert(filenames, vim.fn.fnamemodify(itm.file, ":t"))
        table.insert(paths_abs, itm.file)
      end
      copy_options = {
        { key = "cwd", icon = "\243\176\137\139", value = table.concat(paths_cwd, "\n") },
        { key = "tree", icon = "", value = "tree_structure", items = items },
        { key = "home", icon = "\243\176\139\156", value = table.concat(paths_home, "\n") },
        { key = "content", icon = "\243\176\136\153", value = "file_content_multi", items = items },
        { key = "name", icon = "\243\176\136\148", value = table.concat(filenames, "\n") },
        { key = "path", icon = "\243\176\134\143", value = table.concat(paths_abs, "\n") },
        { key = "claude", icon = "", value = "claude_add", items = items },
      }
    else
      local f = items[1].file
      copy_options = {
        { key = "tree", icon = "", value = "tree_structure", items = items },
        { key = "cwd", icon = "\243\176\137\139", value = vim.fn.fnamemodify(f, ":.") },
        { key = "home", icon = "\243\176\139\156", value = vim.fn.fnamemodify(f, ":~") },
        { key = "content", icon = "\243\176\136\153", value = "file_content", items = items },
        { key = "name", icon = "\243\176\136\148", value = vim.fn.fnamemodify(f, ":t") },
        { key = "path", icon = "\243\176\134\143", value = f },
        { key = "basename", icon = "\243\176\136\153", value = vim.fn.fnamemodify(f, ":t:r") },
        { key = "extension", icon = "\243\176\136\153", value = vim.fn.fnamemodify(f, ":t:e") },
        { key = "uri", icon = "\243\176\140\183", value = vim.uri_from_fname(f) },
        { key = "claude", icon = "", value = "claude_add", items = items },
      }
    end
    local menu_options = {}
    local option_map = {}
    for _, option in ipairs(copy_options) do
      if option.value and not (option.value == "") then
        table.insert(menu_options, string.format("%s %s: %s", option.icon, option.key, option.value))
        option_map[#menu_options] = option
      else
      end
    end
    if #menu_options == 0 then
      return vim.notify("No values to copy", vim.log.levels.WARN)
    else
      local function _46_(list_item)
        return list_item
      end
      local function _47_(choice, idx)
        if choice and idx and option_map[idx] then
          local opt = option_map[idx]
          return M._copy_path_apply(picker, opt, is_multi)
        else
          return nil
        end
      end
      return vim.ui.select(menu_options, { prompt = "Choose to copy to clipboard:", format_item = _46_ }, _47_)
    end
  end
end
M._copy_path_apply = function(picker, opt, is_multi)
  local result = opt.value
  if opt.key == "content" then
    local all_contents = {}
    local total_lines = 0
    local file_count = 0
    local aborted = false
    for _, itm in ipairs(opt.items) do
      if aborted then
        break
      end
      if itm.dir or (vim.fn.isdirectory(itm.file) == 1) then
        local dir_files
        local function _51_(name)
          return (vim.fn.filereadable((itm.file .. "/" .. name)) == 1)
        end
        dir_files = vim.fn.readdir(itm.file, _51_)
        for _0, fname in ipairs(dir_files) do
          local fpath = (itm.file .. "/" .. fname)
          local content = vim.fn.readfile(fpath)
          local rel_path = vim.fn.fnamemodify(fpath, ":.")
          total_lines = (total_lines + #content)
          file_count = (file_count + 1)
          table.insert(all_contents, rel_path)
          table.insert(all_contents, ("--- " .. rel_path .. " ---"))
          table.insert(all_contents, table.concat(content, "\n"))
        end
      else
        if vim.fn.filereadable(itm.file) == 0 then
          vim.notify(("File not readable: " .. itm.file), vim.log.levels.ERROR)
          aborted = true
        else
          local content = vim.fn.readfile(itm.file)
          local rel_path = vim.fn.fnamemodify(itm.file, ":.")
          total_lines = (total_lines + #content)
          file_count = (file_count + 1)
          if is_multi then
            table.insert(all_contents, rel_path)
            table.insert(all_contents, ("--- " .. rel_path .. " ---"))
            table.insert(all_contents, table.concat(content, "\n"))
          else
            table.insert(all_contents, rel_path)
            table.insert(all_contents, table.concat(content, "\n"))
          end
        end
      end
    end
    if not aborted then
      if file_count == 0 then
        return vim.notify("No files to copy", vim.log.levels.WARN)
      else
        vim.fn.setreg("+", table.concat(all_contents, "\n"))
        return Snacks.notify.info(string.format("Copied %d file(s) to clipboard (%d lines)", file_count, total_lines))
      end
    else
      return nil
    end
  elseif opt.key == "tree" then
    return M._copy_tree(opt)
  elseif opt.key == "claude" then
    local claudecode = require("claudecode")
    local count = 0
    for _, itm in ipairs(opt.items) do
      if itm.file and not (itm.file == "") then
        claudecode.send_at_mention(itm.file, nil, nil, "snacks_picker")
        count = (count + 1)
      else
      end
    end
    return Snacks.notify.info(string.format("Added %d file(s) to Claude", count))
  else
    vim.fn.setreg("+", result)
    return Snacks.notify.info(("Yanked `" .. result .. "`"))
  end
end
M._copy_tree = function(opt)
  local items = opt.items
  local items_count = #items
  local single_dir = ((items_count == 1) and (items[1].dir or (vim.fn.isdirectory(items[1].file) == 1)))
  if single_dir then
    local tree_output = vim.fn.system(("tree " .. vim.fn.shellescape(items[1].file)))
    if not (vim.v.shell_error == 0) then
      return vim.notify("Failed to run tree command", vim.log.levels.ERROR)
    else
      vim.fn.setreg("+", tree_output)
      return Snacks.notify.info("Tree structure copied to clipboard")
    end
  else
    local file_paths = {}
    for _, itm in ipairs(items) do
      if not (itm.dir or (vim.fn.isdirectory(itm.file) == 1)) then
        table.insert(file_paths, vim.fn.fnamemodify(itm.file, ":."))
      else
      end
    end
    if #file_paths == 0 then
      return vim.notify("No files to show in tree", vim.log.levels.WARN)
    else
      local tree = {}
      for _, fpath in ipairs(file_paths) do
        local current = tree
        for _0, part in ipairs(vim.split(fpath, "/", { plain = true })) do
          if not current[part] then
            current[part] = {}
          else
          end
          current = current[part]
        end
      end
      local function render_tree(node, prefix)
        local lines = {}
        local keys = vim.tbl_keys(node)
        table.sort(keys)
        for idx, key in ipairs(keys) do
          local is_last = (idx == #keys)
          local connector
          if is_last then
            connector = "\226\148\148\226\148\128\226\148\128 "
          else
            connector = "\226\148\156\226\148\128\226\148\128 "
          end
          local child_prefix
          if is_last then
            child_prefix = "    "
          else
            child_prefix = "\226\148\130   "
          end
          local is_leaf = vim.tbl_isempty(node[key])
          local suffix
          if is_leaf then
            suffix = ""
          else
            suffix = "/"
          end
          table.insert(lines, (prefix .. connector .. key .. suffix))
          if not is_leaf then
            for _, line in ipairs(render_tree(node[key], (prefix .. child_prefix))) do
              table.insert(lines, line)
            end
          else
          end
        end
        return lines
      end
      local tree_lines = { "." }
      for _, line in ipairs(render_tree(tree, "")) do
        table.insert(tree_lines, line)
      end
      vim.fn.setreg("+", table.concat(tree_lines, "\n"))
      return Snacks.notify.info("Tree structure copied to clipboard")
    end
  end
end
local function action_count(picker)
  local n = 0
  if picker.opts and picker.opts.actions then
    for _, _0 in pairs(picker.opts.actions) do
      n = (n + 1)
    end
  else
  end
  return n
end
local function has_explorer_actions_3f(picker, ...)
  local and_69_ = picker.opts and picker.opts.actions
  if and_69_ then
    local names = { ... }
    local found = false
    for _, name in ipairs(names) do
      if found then
        break
      end
      if picker.opts.actions[name] then
        found = true
      else
      end
    end
    and_69_ = found
  end
  return and_69_
end
local contexts
local function _72_(picker)
  return (
    validate_picker(picker)
    and picker.opts
    and picker.opts.actions
    and picker.opts.actions.explorer_add
    and picker.opts.actions.list_down
    and (action_count(picker) < 10)
  )
end
local function _73_(picker)
  return (
    validate_picker(picker)
    and has_explorer_actions_3f(
      picker,
      "explorer_add",
      "explorer_del",
      "explorer_open",
      "explorer_rename",
      "explorer_close",
      "explorer_up",
      "explorer_focus"
    )
    and (action_count(picker) >= 5)
  )
end
local function _74_(picker)
  if not validate_picker(picker) then
    return false
  elseif (picker.opts and picker.opts.source) == "git_status" then
    return true
  elseif not has_explorer_actions_3f(picker, "explorer_add", "explorer_del", "explorer_open") then
    local cur, err = safe_call(picker, "current")
    return (not err and cur and cur.status and cur.file and not cur.dir and cur.status:match("^[MADRCU?!]") and true)
  else
    return false
  end
end
local function _76_(picker)
  if not validate_picker(picker) then
    return false
  else
    local source = (picker.opts and picker.opts.source)
    if (source == "files") or (source == "git_files") then
      return true
    elseif not has_explorer_actions_3f(picker, "explorer_add", "explorer_del") then
      local cur, err = safe_call(picker, "current")
      return (not err and cur and cur.file and not cur.dir and true)
    else
      return false
    end
  end
end
local function _79_(picker)
  if not validate_picker(picker) then
    return false
  elseif (picker.opts and picker.opts.source) == "buffers" then
    return true
  else
    local cur, err = safe_call(picker, "current")
    return (not err and cur and cur.bufnr and true)
  end
end
local function _81_(picker)
  if not validate_picker(picker) then
    return false
  else
    local source = (picker.opts and picker.opts.source)
    if (source == "lsp_symbols") or (source == "lsp_workspace_symbols") then
      return true
    else
      local cur, err = safe_call(picker, "current")
      return (not err and cur and (cur.kind or cur.symbol or cur.lnum) and true)
    end
  end
end
local function _84_(picker)
  if not validate_picker(picker) then
    return false
  else
    local source = (picker.opts and picker.opts.source)
    if (source == "grep") or (source == "grep_word") or (source == "grep_buffers") then
      return true
    else
      local cur, err = safe_call(picker, "current")
      return (not err and cur and cur.line and cur.file and cur.pos and true)
    end
  end
end
local function _87_(picker)
  if not validate_picker(picker) then
    return false
  elseif (picker.opts and picker.opts.source) == "git_branches" then
    return true
  else
    local cur, err = M.get_current_item(picker)
    if err or not cur or not (type(cur) == "table") then
      return false
    elseif cur.branch or cur.commit or not (cur.current == nil) or not (cur.detached == nil) then
      return true
    elseif cur.text then
      local commit_pat = string.rep("[a-z0-9]", 7)
      local patterns =
        { ("^(.)%s(%b())%s+(" .. commit_pat .. ")%s*(.*)$"), ("^(.)%s(%S+)%s+(" .. commit_pat .. ")%s*(.*)$") }
      local matched = false
      for _, pattern in ipairs(patterns) do
        if matched then
          break
        end
        if cur.text:match(pattern) then
          matched = true
        else
        end
      end
      return matched
    else
      return false
    end
  end
end
contexts = {
  sidebar_explorer = { detect = _72_ },
  explorer = { detect = _73_ },
  git_status = { detect = _74_ },
  files = { detect = _76_ },
  buffers = { detect = _79_ },
  lsp_symbols = { detect = _81_ },
  grep = { detect = _84_ },
  git_branches = { detect = _87_ },
}
local context_order =
  { "sidebar_explorer", "explorer", "git_branches", "git_status", "lsp_symbols", "grep", "buffers", "files" }
local function detect_context(picker)
  if not validate_picker(picker) then
    return "unknown", nil
  else
    local found_name = "unknown"
    local found_ctx = nil
    for _, name in ipairs(context_order) do
      if found_ctx then
        break
      end
      local ctx = contexts[name]
      if ctx and ctx.detect(picker) then
        found_name = name
        found_ctx = ctx
      else
      end
    end
    if found_ctx then
      return found_name, found_ctx
    else
      local cur, err = safe_call(picker, "current")
      if not err and cur and cur.bufnr then
        return "buffers", contexts.buffers
      elseif not err and cur and cur.file then
        return "files", contexts.files
      else
        return "unknown", nil
      end
    end
  end
end
local function confirm_rename(picker, item)
  local new_name = vim.fn.input("Rename to: ", vim.fn.fnamemodify(item.file, ":t"))
  if new_name and not (new_name == "") then
    local new_path = (vim.fn.fnamemodify(item.file, ":h") .. "/" .. new_name)
    local function _95_(to, from, ok)
      if ok then
        vim.notify(("Renamed to " .. new_name))
        if picker.refresh then
          return picker:refresh()
        else
          return nil
        end
      else
        return nil
      end
    end
    return Snacks.rename.rename_file({ from = item.file, to = new_path, on_rename = _95_ })
  else
    return nil
  end
end
M.context_menu = function(picker, item)
  if not item then
    return vim.notify("No item available", vim.log.levels.WARN)
  else
    local menu_title
    if item.dir then
      menu_title = ("\243\176\136\148 " .. vim.fn.fnamemodify(item.file, ":t") .. " (Directory)")
    else
      menu_title = ("\243\176\136\153 " .. vim.fn.fnamemodify(item.file, ":t"))
    end
    local options = {}
    local acts = {}
    table.insert(options, "\243\176\145\149 Rename")
    local function _100_()
      return confirm_rename(picker, item)
    end
    table.insert(acts, _100_)
    table.insert(options, "\243\176\134\180 Delete")
    local function _101_()
      if vim.fn.confirm("Delete 1 items?", "&Yes\n&No", 1) == 1 then
        if item.dir then
          vim.fn.delete(item.file, "rf")
        else
          os.remove(item.file)
        end
        vim.notify("Deleted 1 items")
        if picker.refresh then
          return picker:refresh()
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert(acts, _101_)
    do
      local selected = picker:selected()
      local claude_label
      if #selected > 1 then
        claude_label = (" Add " .. #selected .. " files to Claude")
      else
        claude_label = " Add to Claude"
      end
      table.insert(options, claude_label)
      local function _106_()
        return M.claude_add_tree(picker, item)
      end
      table.insert(acts, _106_)
    end
    local function _107_(i)
      return i
    end
    local function _108_(choice, idx)
      if choice and idx and acts[idx] then
        return acts[idx]()
      else
        return nil
      end
    end
    return vim.ui.select(options, { prompt = (menu_title .. " - Choose action:"), format_item = _107_ }, _108_)
  end
end
M.git_context_menu = function(picker, item)
  if not item then
    return vim.notify("No item available", vim.log.levels.WARN)
  else
    local menu_title = ("\243\176\136\153 " .. vim.fn.fnamemodify(item.file, ":t") .. " (Git)")
    local options = {}
    local acts = {}
    table.insert(options, "\243\176\138\162 Stage/Unstage")
    local function _111_()
      do
        local file = item.file
        if item.status and (item.status:match("^M") or item.status:match("^A") or item.status:match("^D")) then
          vim.system({ "git", "restore", "--staged", file })
        else
          vim.system({ "git", "add", file })
        end
      end
      vim.notify("Toggled stage status for 1 files")
      if picker.refresh then
        return picker:refresh()
      else
        return nil
      end
    end
    table.insert(acts, _111_)
    table.insert(options, "\243\176\134\143 Copy Path")
    local function _114_()
      vim.fn.setreg("+", item.file)
      return vim.notify("Copied 1 paths")
    end
    table.insert(acts, _114_)
    local function _115_(i)
      return i
    end
    local function _116_(choice, idx)
      if choice and idx and acts[idx] then
        return acts[idx]()
      else
        return nil
      end
    end
    return vim.ui.select(options, { prompt = (menu_title .. " - Choose action:"), format_item = _115_ }, _116_)
  end
end
M.buffer_context_menu = function(picker, item)
  if not item then
    return vim.notify("No item available", vim.log.levels.WARN)
  else
    local menu_title = (
      "\243\176\136\153 " .. (item.name or vim.fn.fnamemodify(vim.api.nvim_buf_get_name((item.bufnr or 0)), ":t"))
    )
    local buf_path
    local function _119_()
      if item.bufnr and vim.api.nvim_buf_is_loaded(item.bufnr) then
        local fp = vim.api.nvim_buf_get_name(item.bufnr)
        if fp and not (fp == "") then
          return fp
        else
          return nil
        end
      else
        return nil
      end
    end
    buf_path = _119_
    local options = {}
    local acts = {}
    table.insert(options, "\243\176\134\143 Copy Path")
    local function _122_()
      local fp = buf_path()
      vim.fn.setreg("+", (fp or ""))
      return vim.notify("Copied 1 paths")
    end
    table.insert(acts, _122_)
    table.insert(options, "\243\176\150\173 Delete Buffer")
    local function _123_()
      if item.bufnr then
        vim.api.nvim_buf_delete(item.bufnr, { force = false })
      else
      end
      vim.notify("Deleted 1 buffers")
      if picker.refresh then
        return picker:refresh()
      else
        return nil
      end
    end
    table.insert(acts, _123_)
    table.insert(options, "\243\176\134\147 Save Buffer")
    local function _126_()
      if item.bufnr and vim.api.nvim_buf_is_loaded(item.bufnr) then
        local function _127_()
          local function _128_()
            return vim.cmd("write")
          end
          return vim.api.nvim_buf_call(item.bufnr, _128_)
        end
        pcall(_127_)
      else
      end
      return vim.notify("Saved buffer")
    end
    table.insert(acts, _126_)
    local function _130_(i)
      return i
    end
    local function _131_(choice, idx)
      if choice and idx and acts[idx] then
        return acts[idx]()
      else
        return nil
      end
    end
    return vim.ui.select(options, { prompt = (menu_title .. " - Choose action:"), format_item = _130_ }, _131_)
  end
end
M.duplicate_file = function(picker, item)
  if not item then
    return vim.notify("No item provided", vim.log.levels.WARN)
  else
    local source = item.file
    local source_name = vim.fn.fnamemodify(source, ":t")
    local source_dir = vim.fn.fnamemodify(source, ":h")
    local source_ext = vim.fn.fnamemodify(source, ":e")
    local source_base = vim.fn.fnamemodify(source, ":t:r")
    local default_name
    if item.dir then
      default_name = (source_name .. "_copy")
    elseif not (source_ext == "") then
      default_name = (source_base .. "_copy." .. source_ext)
    else
      default_name = (source_name .. "_copy")
    end
    local new_name = vim.fn.input("Duplicate as: ", default_name)
    if new_name and not (new_name == "") then
      local target = (source_dir .. "/" .. new_name)
      if (vim.fn.filereadable(target) == 1) or (vim.fn.isdirectory(target) == 1) then
        return vim.notify(("Target already exists: " .. new_name), vim.log.levels.ERROR)
      else
        local cmd
        if item.dir then
          cmd = { "cp", "-r", source, target }
        else
          cmd = { "cp", source, target }
        end
        local result = vim.fn.system(cmd)
        local label
        if item.dir then
          label = "directory"
        else
          label = "file"
        end
        if vim.v.shell_error == 0 then
          vim.notify(("Duplicated " .. label .. ": " .. new_name))
          if picker.refresh then
            return picker:refresh()
          else
            return nil
          end
        else
          return vim.notify(
            ("Failed to duplicate " .. label .. ": " .. (result or "unknown error")),
            vim.log.levels.ERROR
          )
        end
      end
    else
      return nil
    end
  end
end
M.copy_references = function(picker)
  local selected = picker:selected()
  local items
  if selected and (#selected > 0) then
    items = selected
  else
    items = picker:items()
  end
  if not items or (#items == 0) then
    return vim.notify("No references to copy", vim.log.levels.WARN)
  else
    local full_refs = {}
    local short_refs = {}
    local paths_only = {}
    local seen_paths = {}
    for _, item in ipairs(items) do
      local rel_path = vim.fn.fnamemodify(item.file, ":~:.")
      if item.pos then
        table.insert(full_refs, string.format("%s:%d:%d", rel_path, item.pos[1], item.pos[2]))
        table.insert(short_refs, string.format("%s:%d", rel_path, item.pos[1]))
      else
        table.insert(full_refs, rel_path)
        table.insert(short_refs, rel_path)
      end
      if not seen_paths[item.file] then
        seen_paths[item.file] = true
        table.insert(paths_only, rel_path)
      else
      end
    end
    local copy_options = {
      { key = "full", icon = "\243\176\134\143", desc = "file:line:col", value = table.concat(full_refs, "\n") },
      { key = "short", icon = "\243\176\137\139", desc = "file:line", value = table.concat(short_refs, "\n") },
      { key = "paths", icon = "\243\176\136\148", desc = "unique paths", value = table.concat(paths_only, "\n") },
    }
    local menu_options = {}
    for i, opt in ipairs(copy_options) do
      menu_options[i] = string.format("%s %s (%s)", opt.icon, opt.key, opt.desc)
    end
    local function _145_(_, idx)
      if idx and copy_options[idx] then
        vim.fn.setreg("+", copy_options[idx].value)
        return vim.notify(
          string.format("Copied %d references (%s)", #items, copy_options[idx].key),
          vim.log.levels.INFO
        )
      else
        return nil
      end
    end
    return vim.ui.select(menu_options, { prompt = "Copy references:" }, _145_)
  end
end
local function get_symbol_path(item)
  local parts = {}
  local current = item
  while current do
    if current.text or current.name then
      table.insert(parts, 1, (current.text or current.name))
    else
    end
    current = current.parent
  end
  return table.concat(parts, ".")
end
local function get_copy_options(ctx, _picker, items)
  local is_multi = (#items > 1)
  if (ctx == "explorer") or (ctx == "files") then
    if is_multi then
      local paths_cwd = {}
      local paths_home = {}
      local filenames = {}
      local paths_abs = {}
      for _, item in ipairs(items) do
        table.insert(paths_cwd, vim.fn.fnamemodify(item.file, ":."))
        table.insert(paths_home, vim.fn.fnamemodify(item.file, ":~"))
        table.insert(filenames, vim.fn.fnamemodify(item.file, ":t"))
        table.insert(paths_abs, item.file)
      end
      return {
        { label = "Relative paths", value = table.concat(paths_cwd, "\n"), icon = "\243\176\137\139" },
        { label = "From home", value = table.concat(paths_home, "\n"), icon = "\243\176\139\156" },
        { label = "Filenames", value = table.concat(filenames, "\n"), icon = "\243\176\136\148" },
        { label = "Absolute paths", value = table.concat(paths_abs, "\n"), icon = "\243\176\134\143" },
      }
    else
      local f = items[1].file
      return {
        { label = "Relative path", value = vim.fn.fnamemodify(f, ":."), icon = "\243\176\137\139" },
        { label = "From home", value = vim.fn.fnamemodify(f, ":~"), icon = "\243\176\139\156" },
        { label = "Filename", value = vim.fn.fnamemodify(f, ":t"), icon = "\243\176\136\148" },
        { label = "Absolute path", value = f, icon = "\243\176\134\143" },
        { label = "Basename", value = vim.fn.fnamemodify(f, ":t:r"), icon = "\243\176\136\153" },
        { label = "Extension", value = vim.fn.fnamemodify(f, ":e"), icon = "\243\176\136\153" },
      }
    end
  elseif ctx == "lsp_symbols" then
    if is_multi then
      local names = {}
      local locations = {}
      for _, item in ipairs(items) do
        table.insert(names, (item.text or item.name or ""))
        if item.file and item.pos then
          table.insert(locations, string.format("%s:%d", vim.fn.fnamemodify(item.file, ":."), item.pos[1]))
        else
        end
      end
      return {
        { label = "Symbol names", value = table.concat(names, "\n"), icon = "\243\176\138\149" },
        { label = "File:line locations", value = table.concat(locations, "\n"), icon = "\243\176\134\143" },
      }
    else
      local item = items[1]
      local name = (item.text or item.name or "")
      local symbol_path = get_symbol_path(item)
      local options = { { label = "Symbol name", value = name, icon = "\243\176\138\149" } }
      if not (symbol_path == name) and not (symbol_path == "") then
        table.insert(options, { label = "Symbol path", value = symbol_path, icon = "\243\176\153\133" })
      else
      end
      if item.file and item.pos then
        table.insert(
          options,
          {
            label = "File:line",
            value = string.format("%s:%d", vim.fn.fnamemodify(item.file, ":."), item.pos[1]),
            icon = "\243\176\134\143",
          }
        )
        table.insert(
          options,
          {
            label = "File:symbol",
            value = string.format("%s:%s", vim.fn.fnamemodify(item.file, ":."), name),
            icon = "\243\176\136\148",
          }
        )
      else
      end
      return options
    end
  elseif ctx == "grep" then
    if is_multi then
      local locations = {}
      local lines = {}
      local paths = {}
      local seen_paths = {}
      for _, item in ipairs(items) do
        if item.file and item.pos then
          table.insert(locations, string.format("%s:%d", vim.fn.fnamemodify(item.file, ":."), item.pos[1]))
        else
        end
        if item.line then
          table.insert(lines, item.line)
        elseif item.text then
          table.insert(lines, item.text)
        else
        end
        if item.file and not seen_paths[item.file] then
          seen_paths[item.file] = true
          table.insert(paths, vim.fn.fnamemodify(item.file, ":."))
        else
        end
      end
      return {
        { label = "File:line locations", value = table.concat(locations, "\n"), icon = "\243\176\134\143" },
        { label = "Matched lines", value = table.concat(lines, "\n"), icon = "\243\176\136\153" },
        { label = "Unique paths", value = table.concat(paths, "\n"), icon = "\243\176\137\139" },
      }
    else
      local item = items[1]
      local options = {}
      if item.file and item.pos then
        table.insert(
          options,
          {
            label = "File:line",
            value = string.format("%s:%d", vim.fn.fnamemodify(item.file, ":."), item.pos[1]),
            icon = "\243\176\134\143",
          }
        )
      else
      end
      if item.line then
        table.insert(options, { label = "Matched line", value = item.line, icon = "\243\176\136\153" })
      elseif item.text then
        table.insert(options, { label = "Matched text", value = item.text, icon = "\243\176\136\153" })
      else
      end
      if item.file then
        table.insert(
          options,
          { label = "File path", value = vim.fn.fnamemodify(item.file, ":."), icon = "\243\176\137\139" }
        )
      else
      end
      return options
    end
  elseif ctx == "git_branches" then
    if is_multi then
      local names = {}
      for _, item in ipairs(items) do
        local branch = M.get_branch_name(item)
        if branch then
          table.insert(names, branch)
        else
        end
      end
      return { { label = "Branch names", value = table.concat(names, "\n"), icon = "" } }
    else
      local branch = M.get_branch_name(items[1])
      if branch then
        local options = { { label = "Branch name", value = branch, icon = "" } }
        if branch:match("/") then
          local remote, name = branch:match("^([^/]+)/(.+)$")
          if remote and name then
            table.insert(options, { label = "Remote branch", value = branch, icon = "\243\176\138\162" })
            table.insert(options, { label = "Branch only", value = name, icon = "" })
          else
          end
        else
        end
        return options
      else
        return {}
      end
    end
  elseif ctx == "git_status" then
    if is_multi then
      local paths = {}
      for _, item in ipairs(items) do
        table.insert(paths, vim.fn.fnamemodify(item.file, ":."))
      end
      return { { label = "File paths", value = table.concat(paths, "\n"), icon = "\243\176\137\139" } }
    else
      local item = items[1]
      local options =
        { { label = "File path", value = vim.fn.fnamemodify(item.file, ":."), icon = "\243\176\137\139" } }
      if item.status then
        table.insert(options, { label = "Status", value = item.status, icon = "\243\176\138\162" })
      else
      end
      return options
    end
  elseif ctx == "buffers" then
    if is_multi then
      local paths = {}
      local names = {}
      for _, item in ipairs(items) do
        local bufname = (item.file or (item.bufnr and vim.api.nvim_buf_get_name(item.bufnr)) or "")
        if not (bufname == "") then
          table.insert(paths, vim.fn.fnamemodify(bufname, ":."))
          table.insert(names, vim.fn.fnamemodify(bufname, ":t"))
        else
        end
      end
      return {
        { label = "File paths", value = table.concat(paths, "\n"), icon = "\243\176\137\139" },
        { label = "Buffer names", value = table.concat(names, "\n"), icon = "\243\176\136\148" },
      }
    else
      local item = items[1]
      local bufname = (item.file or (item.bufnr and vim.api.nvim_buf_get_name(item.bufnr)) or "")
      if not (bufname == "") then
        return {
          { label = "File path", value = vim.fn.fnamemodify(bufname, ":."), icon = "\243\176\137\139" },
          { label = "Buffer name", value = vim.fn.fnamemodify(bufname, ":t"), icon = "\243\176\136\148" },
          { label = "Absolute path", value = bufname, icon = "\243\176\134\143" },
        }
      else
        return {}
      end
    end
  else
    if is_multi then
      local texts = {}
      local files = {}
      local options = {}
      for _, item in ipairs(items) do
        if item.text then
          table.insert(texts, item.text)
        else
        end
        if item.file then
          table.insert(files, vim.fn.fnamemodify(item.file, ":."))
        else
        end
      end
      if #texts > 0 then
        table.insert(options, { label = "Text", value = table.concat(texts, "\n"), icon = "\243\176\136\153" })
      else
      end
      if #files > 0 then
        table.insert(options, { label = "Files", value = table.concat(files, "\n"), icon = "\243\176\137\139" })
      else
      end
      return options
    else
      local item = items[1]
      local options = {}
      if item.text then
        table.insert(options, { label = "Text", value = item.text, icon = "\243\176\136\153" })
      else
      end
      if item.file then
        table.insert(
          options,
          { label = "File", value = vim.fn.fnamemodify(item.file, ":."), icon = "\243\176\137\139" }
        )
      else
      end
      return options
    end
  end
end
M.copy = function(picker, item)
  local ctx, _context = detect_context(picker)
  local items
  do
    local its = picker_items(picker)
    if #its > 0 then
      items = its
    else
      if item then
        items = { item }
      else
        items = {}
      end
    end
  end
  if #items == 0 then
    return vim.notify("No items to copy", vim.log.levels.WARN)
  else
    local options = get_copy_options(ctx, picker, items)
    if #options == 0 then
      return vim.notify("No copy options available", vim.log.levels.WARN)
    else
      local menu_items = {}
      for i, opt in ipairs(options) do
        local preview = opt.value
        if #preview > 40 then
          preview = (preview:sub(1, 37) .. "...")
        else
        end
        preview = preview:gsub("\n", " \226\134\181 ")
        menu_items[i] = string.format("%s %s: %s", (opt.icon or "\243\176\134\143"), opt.label, preview)
      end
      local function _182_(_, idx)
        if idx and options[idx] then
          vim.fn.setreg("+", options[idx].value)
          local count_info
          if #items > 1 then
            count_info = string.format(" (%d items)", #items)
          else
            count_info = ""
          end
          return Snacks.notify.info(("Copied: " .. options[idx].label .. count_info))
        else
          return nil
        end
      end
      return vim.ui.select(menu_items, { prompt = string.format("Copy (%s):", ctx) }, _182_)
    end
  end
end
M.get_explorer_layout = function()
  return explorer_layout
end
M.toggle_layout = function(picker)
  local new_layout
  if explorer_layout == "sidebar" then
    new_layout = "default"
  else
    new_layout = "sidebar"
  end
  explorer_layout = new_layout
  vim.g.explorer_layout = new_layout
  local layout =
    Snacks.picker.config.layout({ layout = { preset = new_layout, preview = preview_for_layout(new_layout) } })
  picker:set_layout(layout)
  picker.opts.preview = preview_for_layout(new_layout)
  picker.opts.auto_close = (new_layout == "default")
  return nil
end
M.toggle_tree = function(picker)
  if picker and picker.opts then
    local new_tree = not picker.opts.tree
    picker.opts.tree = new_tree
    picker._tree_mode = new_tree
    picker.opts.formatters = (picker.opts.formatters or {})
    picker.opts.formatters.file = (picker.opts.formatters.file or {})
    picker.opts.formatters.file.filename_only = new_tree
    if not new_tree then
      local ok, Tree = pcall(require, "snacks.explorer.tree")
      if ok then
        local root = Tree:find(picker:cwd())
        if root then
          local function _188_(node)
            if node.dir then
              node.open = true
              return Tree:expand(node)
            else
              return nil
            end
          end
          Tree:walk(root, _188_, { all = true })
        else
        end
      else
      end
    else
    end
    picker.list:set_target()
    return picker:find()
  else
    return nil
  end
end
M.format_file_tree_aware = function(item, picker)
  local original_parent = item.parent
  if picker._tree_mode == false then
    item.parent = nil
  else
  end
  local ret = Snacks.picker.format.file(item, picker)
  item.parent = original_parent
  return ret
end
M.confirm_multi = function(picker, item, action)
  if item and item.dir then
    local Tree = require("snacks.explorer.tree")
    Tree:toggle(item.file)
    return require("snacks.explorer.actions").update(picker, { refresh = true })
  else
    local selected = picker:selected()
    if #selected > 1 then
      local files = {}
      for i, sel in ipairs(selected) do
        if i <= 5 then
          local _195_
          if sel.file then
            _195_ = vim.fn.fnamemodify(sel.file, ":t")
          else
            _195_ = sel.text
          end
          table.insert(files, ("  " .. _195_))
        else
        end
      end
      if #selected > 5 then
        table.insert(files, ("  ... and " .. (#selected - 5) .. " more"))
      else
      end
      local msg = ("Open " .. #selected .. " files?\n" .. table.concat(files, "\n"))
      local function _199_(choice)
        if choice == "Yes" then
          return Snacks.picker.actions.confirm(picker, item, (action or {}))
        else
          return nil
        end
      end
      return vim.ui.select({ "Yes", "No" }, { prompt = msg }, _199_)
    else
      local main_win = picker.main
      local has_winfixbuf = (main_win and vim.api.nvim_win_is_valid(main_win) and vim.wo[main_win].winfixbuf)
      if has_winfixbuf then
        picker:close()
        if item and item.file then
          return vim.cmd(("split " .. vim.fn.fnameescape(item.file)))
        else
          return nil
        end
      elseif explorer_layout == "default" then
        local file = (item and item.file)
        picker:close()
        if file then
          return vim.cmd(("edit " .. vim.fn.fnameescape(file)))
        else
          return nil
        end
      else
        return Snacks.picker.actions.confirm(picker, item, (action or {}))
      end
    end
  end
end
M.claude_add_tree = function(picker, _item)
  local claudecode = require("claudecode")
  for _, selected in ipairs(picker:selected({ fallback = true })) do
    local path = Snacks.picker.util.path(selected)
    if path then
      claudecode.send_at_mention(path, nil, nil, "snacks_picker")
    else
    end
  end
  return nil
end
M.actions = {
  open_multiple_buffers = M.open_multiple_buffers,
  copy_file_path = M.copy_file_path,
  copy = M.copy,
  copy_references = M.copy_references,
  search_in_directory = M.search_in_directory,
  diff_selected = M.diff_selected,
  handle_directory_expansion = M.handle_directory_expansion,
  duplicate_file = M.duplicate_file,
  claude_add_tree = M.claude_add_tree,
  context_menu = M.context_menu,
  git_context_menu = M.git_context_menu,
  buffer_context_menu = M.buffer_context_menu,
  toggle_tree = M.toggle_tree,
  toggle_layout = M.toggle_layout,
  confirm_multi = M.confirm_multi,
}
return M
