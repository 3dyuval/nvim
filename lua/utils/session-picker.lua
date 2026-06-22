-- [nfnl] fnl/utils/session-picker.fnl
local Session = {}
Session.new = function(filename, session_name)
  local pipe_idx = string.find(session_name, "|")
  local path
  if pipe_idx then
    path = string.sub(session_name, 1, (pipe_idx - 1))
  else
    path = session_name
  end
  local branch
  if pipe_idx then
    branch = string.sub(session_name, (pipe_idx + 1))
  else
    branch = "main"
  end
  return {_filename = filename, _path = path, _branch = branch}
end
Session.path = function(self)
  return self._path
end
Session.branch = function(self)
  return self._branch
end
Session.filename = function(self)
  return self._filename
end
Session.decoded = function(self)
  return (self._path .. "|" .. self._branch)
end
Session["display-name"] = function(self)
  return (string.match(self._path, "[^/]+$") or self._path)
end
Session["picker-item"] = function(self)
  local display = Session["display-name"](self)
  local preview_text = Session.preview(self)
  return {text = ("  \243\176\129\175 " .. display .. " (" .. self._branch .. ") [" .. self._path .. "]"), path = self._path, branch = self._branch, session_name = Session.decoded(self), filename = self._filename, display_name = display, file = self._path, _session = self, preview = {text = preview_text, ft = "text"}}
end
Session["get-files"] = function(self)
  local session_dir = (vim.fn.stdpath("data") .. "/sessions/")
  local session_file = (session_dir .. self._filename)
  local files = {}
  if vim.fn.filereadable(session_file) then
    for line in io.lines(session_file) do
      local line_num, match_file = string.match(line, "^badd%s+%+(%d+)%s+(.+)$")
      if line_num then
        table.insert(files, {file = match_file, line = tonumber(line_num)})
      else
      end
    end
  else
  end
  return files
end
Session.preview = function(self)
  local files = Session["get-files"](self)
  local lines = {("Path: " .. Session.path(self)), ("Branch: " .. Session.branch(self))}
  if (#files > 0) then
    table.insert(lines, "")
    table.insert(lines, "Files:")
    for _, f in ipairs(files) do
      table.insert(lines, ("  " .. f.file .. " +" .. f.line))
    end
  else
    table.insert(lines, "(no files in session)")
  end
  return table.concat(lines, "\n")
end
Session.restore = function(self)
  local ok, auto_session = pcall(require, "auto-session")
  if ok then
    return auto_session.autosave_and_restore(Session.decoded(self))
  else
    return nil
  end
end
local function build_session_items()
  local ok, auto_session = pcall(require, "auto-session")
  if not ok then
    return {}
  else
    local Lib = require("auto-session.lib")
    local root_dir = auto_session.get_root_dir()
    local items = {}
    for _, f in ipairs(Lib.get_session_list(root_dir)) do
      if (f and f.file_name) then
        local session = Session.new(f.file_name, f.session_name)
        table.insert(items, Session["picker-item"](session))
      else
      end
    end
    return items
  end
end
local function open()
  local snacks = require("snacks")
  local items = build_session_items()
  if (#items == 0) then
    return vim.notify("No sessions found", vim.log.levels.WARN)
  else
    local function _9_(picker, item)
      if (item and item._session) then
        Session.restore(item._session)
        return picker:close()
      else
        return nil
      end
    end
    return snacks.picker({title = "Sessions", items = items, format = "text", on_confirm = _9_})
  end
end
return {open = open, Session = Session}
