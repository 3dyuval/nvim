local M = {}
local current_file = nil
local current_rev = nil
local gitgraph_open = false
local function get_selected_file(view)
  if (view and view.panel) then
    local selected = view.panel.selected_files
    if (selected and next(selected)) then
      return next(selected)
    else
      return nil
    end
  else
    return nil
  end
end
M["open-graph"] = function()
  if current_file then
    local ok, gitgraph = pcall(require, "gitgraph")
    if ok then
      gitgraph.draw({}, {})
      gitgraph_open = true
      return nil
    else
      return vim.notify("gitgraph.nvim not installed", vim.log.levels.WARN)
    end
  else
    return nil
  end
end
M["on-selection-changed"] = function(view)
  local file = get_selected_file(view)
  if (file and (file ~= current_file)) then
    current_file = file
    return M["open-graph"]()
  else
    return nil
  end
end
M["on-view-opened"] = function(view)
  if (view and view.panel and view.panel.selected_files) then
    current_file = get_selected_file(view)
    return M["open-graph"]()
  else
    return nil
  end
end
M["on-files-staged"] = function(view)
  if gitgraph_open then
    return M["open-graph"]()
  else
    return nil
  end
end
M["on-view-closed"] = function(view)
  current_file = nil
  current_rev = nil
  gitgraph_open = false
  return nil
end
M["create-command"] = function()
  local function _8_(opts)
    local ok, gitgraph = pcall(require, "gitgraph")
    if ok then
      return gitgraph.draw({}, {all = true})
    else
      return vim.notify("gitgraph.nvim not installed", vim.log.levels.WARN)
    end
  end
  return vim.api.nvim_create_user_command("DiffviewGraph", _8_, {nargs = "*", desc = "Open gitgraph"})
end
M.setup = function()
  M["create-command"]()
  return {selection_changed = M["on-selection-changed"], files_staged = M["on-files-staged"], view_opened = M["on-view-opened"], view_closed = M["on-view-closed"]}
end
return M
