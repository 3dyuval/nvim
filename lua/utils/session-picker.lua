local function decode_session_name(encoded_name)
  return string.gsub(string.gsub(string.gsub(string.gsub(encoded_name, "%%2F", "/"), "%%2f", "/"), "%%7C", "|"), "%%7c", "|")
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
        local decoded_name = decode_session_name(f.session_name)
        local pipe_idx = string.find(decoded_name, "|")
        local session_path_part
        if pipe_idx then
          session_path_part = string.sub(decoded_name, 1, (pipe_idx - 1))
        else
          session_path_part = decoded_name
        end
        local branch_name
        if pipe_idx then
          branch_name = string.sub(decoded_name, (pipe_idx + 1))
        else
          branch_name = "main"
        end
        local display_name = (string.match(session_path_part, "[^/]+$") or session_path_part)
        table.insert(items, {text = ("  \243\176\129\175 " .. display_name .. " (" .. branch_name .. ") [" .. session_path_part .. "]"), path = session_path_part, branch = branch_name, session_name = f.session_name, display_name = display_name, file = session_path_part})
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
    local function _5_(picker, item)
      if (item and item.session_name) then
        vim.cmd((":AutoSession restore " .. item.session_name))
        return picker:close()
      else
        return nil
      end
    end
    local function _7_(item)
      return ("Path: " .. item.path .. "\n" .. "Branch: " .. item.branch .. "\n" .. "Session: " .. item.session_name)
    end
    return snacks.picker({title = "Sessions", items = items, format = "text", on_confirm = _5_, preview = _7_})
  end
end
return {open = open}
