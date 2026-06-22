local Session = {}
Session.new = function(encoded_filename)
  local decoded = string.gsub(string.gsub(string.gsub(string.gsub(encoded_filename, "%%2F", "/"), "%%2f", "/"), "%%7C", "|"), "%%7c", "|")
  local pipe_idx = string.find(decoded, "|")
  local path_with_ext
  if pipe_idx then
    path_with_ext = string.sub(decoded, 1, (pipe_idx - 1))
  else
    path_with_ext = decoded
  end
  local path = string.gsub(path_with_ext, "%.vim$", "")
  local branch
  if pipe_idx then
    branch = string.sub(decoded, (pipe_idx + 1))
  else
    branch = "main"
  end
  return {_path = path, _branch = branch, _encoded = encoded_filename}
end
Session.path = function(self)
  return self._path
end
Session.branch = function(self)
  return self._branch
end
Session.encoded = function(self)
  return self._encoded
end
Session.decoded = function(self)
  return (self._path .. "|" .. self._branch)
end
Session["display-name"] = function(self)
  return (string.match(self._path, "[^/]+$") or self._path)
end
Session["picker-item"] = function(self)
  local display = Session["display-name"](self)
  return {text = ("  \243\176\129\175 " .. display .. " (" .. self._branch .. ") [" .. self._path .. "]"), path = self._path, branch = self._branch, session_name = Session.decoded(self), encoded_name = self._encoded, display_name = display, file = self._path, _session = self}
end
Session["get-files"] = function(self)
  local session_dir = (vim.fn.stdpath("data") .. "/sessions/")
  local session_file = (session_dir .. Session.encoded(self))
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
      if (f and f.session_name) then
        local session = Session.new(f.session_name)
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
    local function _8_(picker, item)
      if (item and item._session) then
        Session.restore(item._session)
        return picker:close()
      else
        return nil
      end
    end
    local function _10_(item)
      if (item and item._session and item.path and item.branch) then
        local session = item._session
        local files = Session["get-files"](session)
        local files_text
        if (#files > 0) then
          local _11_
          do
            local tbl_26_ = {}
            local i_27_ = 0
            for _, f in ipairs(files) do
              local val_28_ = ("  " .. f.file .. " +" .. f.line)
              if (nil ~= val_28_) then
                i_27_ = (i_27_ + 1)
                tbl_26_[i_27_] = val_28_
              else
              end
            end
            _11_ = tbl_26_
          end
          files_text = ("\nFiles:\n" .. table.concat(_11_, "\n"))
        else
          files_text = ""
        end
        return ("Path: " .. item.path .. "\n" .. "Branch: " .. item.branch .. files_text)
      else
        return nil
      end
    end
    return snacks.picker({title = "Sessions", items = items, format = "text", on_confirm = _8_, preview = _10_})
  end
end
return {open = open, Session = Session}
