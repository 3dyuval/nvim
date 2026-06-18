-- [nfnl] fnl/integration/gitgraph-diffview.fnl
local M = {}
local graph_win = nil
local src_win = nil
local graph_buf = nil
local function graph_open_3f()
  return (graph_win and vim.api.nvim_win_is_valid(graph_win))
end
M["open-graph"] = function()
  local ok, gitgraph = pcall(require, "gitgraph")
  local ok_core, core = pcall(require, "gitgraph.core")
  if not ok then
    return vim.notify("gitgraph.nvim not installed", vim.log.levels.WARN)
  else
    src_win = vim.api.nvim_get_current_win()
    if not graph_open_3f() then
      vim.cmd("botright split")
      graph_win = vim.api.nvim_get_current_win()
      graph_buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_win_set_buf(graph_win, graph_buf)
      vim.api.nvim_win_set_height(graph_win, 16)
    else
    end
    vim.api.nvim_set_current_win(graph_win)
    vim.api.nvim_set_option_value("modifiable", true, {buf = graph_buf})
    do
      local ok_render, render_result = pcall(core.render_data, gitgraph.config, {}, {all = true, max_count = 256})
      if ok_render then
        vim.api.nvim_buf_set_lines(graph_buf, 0, -1, false, render_result.lines)
        for _, hl in ipairs(render_result.highlights) do
          vim.api.nvim_buf_add_highlight(graph_buf, -1, hl.hg, hl.row, hl.start, hl.stop)
        end
      else
        vim.notify(("Failed to render graph: " .. render_result), vim.log.levels.ERROR)
      end
    end
    vim.api.nvim_set_option_value("modifiable", false, {buf = graph_buf})
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
M["on-selection-changed"] = function(view)
end
M["on-files-staged"] = function(view)
end
M["create-command"] = function()
  local function _6_(_opts)
    return M["open-graph"]()
  end
  return vim.api.nvim_create_user_command("DiffviewGraph", _6_, {nargs = "*", desc = "Open gitgraph in a split"})
end
M.setup = function()
  M["create-command"]()
  return {view_closed = M["on-view-closed"]}
end
return M
