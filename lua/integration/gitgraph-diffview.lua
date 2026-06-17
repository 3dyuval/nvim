local M = {}
local graph_win = nil
local src_win = nil
local function graph_open_3f()
  return (graph_win and vim.api.nvim_win_is_valid(graph_win))
end
M["open-graph"] = function()
  local ok, gitgraph = pcall(require, "gitgraph")
  if not ok then
    return vim.notify("gitgraph.nvim not installed", vim.log.levels.WARN)
  else
    src_win = vim.api.nvim_get_current_win()
    if not graph_open_3f() then
      vim.cmd("botright split")
      graph_win = vim.api.nvim_get_current_win()
      vim.api.nvim_win_set_height(graph_win, 16)
    else
    end
    vim.api.nvim_set_current_win(graph_win)
    gitgraph.draw({}, {all = true, max_count = 256})
    if (src_win and vim.api.nvim_win_is_valid(src_win)) then
      return vim.api.nvim_set_current_win(src_win)
    else
      return nil
    end
  end
end
M["close-graph"] = function()
  if graph_open_3f() then
    vim.api.nvim_win_close(graph_win, true)
  else
  end
  graph_win = nil
  return nil
end
M["on-view-opened"] = function(view)
  return M["open-graph"]()
end
M["on-view-closed"] = function(view)
  return M["close-graph"]()
end
M["create-command"] = function()
  local function _5_(_opts)
    return M["open-graph"]()
  end
  return vim.api.nvim_create_user_command("DiffviewGraph", _5_, {nargs = "*", desc = "Open gitgraph in a split"})
end
M.setup = function()
  M["create-command"]()
  return {view_opened = M["on-view-opened"], view_closed = M["on-view-closed"]}
end
return M
