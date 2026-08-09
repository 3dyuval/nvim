-- [nfnl] fnl/session/picker.fnl
local M = {}
local function build_items()
  local ok, session = pcall(require, "possession.session")
  if not ok then
    return {}
  else
    local items = {}
    for _, data in pairs(session.list()) do
      if data.name then
        table.insert(items, {text = data.name, name = data.name, cwd = data.cwd, file = data.cwd})
      else
      end
    end
    return items
  end
end
M.open = function()
  local items = build_items()
  if (#items == 0) then
    return vim.notify("No sessions found", vim.log.levels.INFO)
  else
    local function _3_(item, _)
      return {{item.name, "SnacksPickerLabel"}, {("  " .. (item.cwd or "")), "SnacksPickerComment"}}
    end
    local function _4_(picker, item)
      picker:close()
      if (item and item.name) then
        return require("possession.session").load(item.name)
      else
        return nil
      end
    end
    return Snacks.picker.pick({source = "sessions", items = items, format = _3_, confirm = _4_})
  end
end
return M
