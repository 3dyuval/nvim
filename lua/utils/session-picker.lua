local Session = {}
Session.decode = function(encoded_name)
  return string.gsub(string.gsub(string.gsub(string.gsub(encoded_name, "%%2F", "/"), "%%2f", "/"), "%%7C", "|"), "%%7c", "|")
end
Session.parse = function(session_name)
  local decoded = Session.decode(session_name)
  local pipe_idx = string.find(decoded, "|")
  local path
  if pipe_idx then
    path = string.sub(decoded, 1, (pipe_idx - 1))
  else
    path = decoded
  end
  local branch
  if pipe_idx then
    branch = string.sub(decoded, (pipe_idx + 1))
  else
    branch = "main"
  end
  return {path = path, branch = branch, encoded_name = session_name}
end
Session["display-name"] = function(path)
  return (string.match(path, "[^/]+$") or path)
end
Session["picker-item"] = function(session)
  local display = Session["display-name"](session.path)
  local decoded_session_name = (session.path .. "|" .. session.branch)
  return {text = ("  \243\176\129\175 " .. display .. " (" .. session.branch .. ") [" .. session.path .. "]"), path = session.path, branch = session.branch, session_name = decoded_session_name, encoded_name = session.encoded_name, display_name = display, file = session.path, _session = session}
end
Session.restore = function(session)
  local ok, auto_session = pcall(require, "auto-session")
  if ok then
    local decoded_name = (session.path .. "|" .. session.branch)
    return auto_session.autosave_and_restore(decoded_name)
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
        local session = Session.parse(f.session_name)
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
    local function _6_(picker, item)
      if (item and item._session) then
        Session.restore(item._session)
        return picker:close()
      else
        return nil
      end
    end
    local function _8_(item)
      return ("Path: " .. item.path .. "\n" .. "Branch: " .. item.branch .. "\n" .. "Session: " .. item.session_name)
    end
    return snacks.picker({title = "Sessions", items = items, format = "text", on_confirm = _6_, preview = _8_})
  end
end
return {open = open}
