-- [nfnl] fnl/integration/diffview-cdiffview.fnl
local M = {}
local graph_data = nil
local function render_graph()
  local ok_core, core
  local function _1_()
    return require("gitgraph.core")
  end
  ok_core, core = pcall(_1_)
  if not ok_core then
    vim.notify("Failed to load gitgraph.core", vim.log.levels.WARN)
    return nil
  else
  end
  local ok_gitgraph, gitgraph
  local function _3_()
    return require("gitgraph")
  end
  ok_gitgraph, gitgraph = pcall(_3_)
  if not ok_gitgraph then
    vim.notify("Failed to load gitgraph", vim.log.levels.WARN)
    return nil
  else
  end
  local ok_render, render_result
  local function _5_()
    return core.render_data(gitgraph.config, {}, {all = true, max_count = 256})
  end
  ok_render, render_result = pcall(_5_)
  if not ok_render then
    vim.notify(("Failed to render graph: " .. tostring(render_result)), vim.log.levels.ERROR)
    return nil
  else
  end
  return render_result
end
local function setup_panel_for_graph(bufnr)
  vim.api.nvim_buf_set_option(bufnr, "filetype", "DiffviewGraph")
  vim.opt_local.number = false
  vim.opt_local.relativenumber = false
  vim.opt_local.signcolumn = "no"
  vim.opt_local.wrap = false
  return nil
end
M["inject-graph"] = function(view)
  local render_result = render_graph()
  if not render_result then
    return vim.notify("No graph data to inject", vim.log.levels.WARN)
  else
    local panel = view.panel
    local bufnr = (panel and panel.bufid)
    if not bufnr then
      return vim.notify("No file panel found", vim.log.levels.WARN)
    else
      vim.api.nvim_set_option_value("modifiable", true, {buf = bufnr})
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, render_result.lines)
      for _, hl in ipairs(render_result.highlights) do
        vim.api.nvim_buf_add_highlight(bufnr, -1, hl.hg, hl.row, hl.start, hl.stop)
      end
      vim.api.nvim_set_option_value("modifiable", false, {buf = bufnr})
      setup_panel_for_graph(bufnr)
      graph_data = render_result
      return nil
    end
  end
end
M.open = function()
  return vim.cmd("DiffviewOpen main..HEAD")
end
return M
