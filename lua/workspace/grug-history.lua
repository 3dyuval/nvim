-- [nfnl] fnl/workspace/grug-history.fnl
local M = {}
local function history_file()
  return (require("grug-far.opts").getGlobalOptions().history.historyDir .. "/history")
end
local function entries()
  local path = history_file()
  if (vim.fn.filereadable(path) == 0) then
    return {}
  else
    local text = table.concat(vim.fn.readfile(path), "\n")
    local hist = require("grug-far.history")
    local out = {}
    for _, block in ipairs(vim.split(text, "\n\n+", {trimempty = true})) do
      if block:match("Engine:") then
        table.insert(out, hist.getHistoryEntryFromLines(vim.split(block, "\n")))
      else
      end
    end
    return out
  end
end
M.pick = function()
  local items = {}
  for i, entry in ipairs(entries()) do
    table.insert(items, {idx = i, entry = entry, text = (((entry.search ~= "") and entry.search) or entry.paths or "(empty)")})
  end
  if (#items == 0) then
    return vim.notify("grug-far: no history yet", vim.log.levels.INFO)
  else
    local function _3_(item, _)
      return {{item.text, "SnacksPickerLabel"}, {("  " .. (item.entry.paths or "")), "SnacksPickerComment"}}
    end
    local function _4_(picker, item)
      picker:close()
      if (item and item.entry) then
        return require("grug-far").open({prefills = item.entry})
      else
        return nil
      end
    end
    return Snacks.picker.pick({source = "grug_history", items = items, format = _3_, confirm = _4_})
  end
end
return M
