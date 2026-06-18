-- [nfnl] fnl/integration/diffview-cdiffview.fnl
local M = {}
local graph_win = nil
local src_win = nil
local graph_buf = nil
local graph_data = nil
local function graph_open_3f()
  return (graph_win and vim.api.nvim_win_is_valid(graph_win))
end
M.open = function()
  local cwd = vim.fn.getcwd()
  local ok
  local function _1_()
    return vim.cmd("cd /home/yuv/proj/gitgraph.nvim-snacks-api")
  end
  ok = pcall(_1_)
  if ok then
    local ok_gitgraph, gitgraph
    local function _2_()
      return require("gitgraph")
    end
    ok_gitgraph, gitgraph = pcall(_2_)
    if not ok_gitgraph then
      vim.notify("Failed to load gitgraph", vim.log.levels.WARN)
    else
      local ok_core, core
      local function _3_()
        return require("gitgraph.core")
      end
      ok_core, core = pcall(_3_)
      local render_result = core.render_data(gitgraph.config, {}, {all = true, max_count = 256})
      src_win = vim.api.nvim_get_current_win()
      if not graph_open_3f() then
        vim.cmd("topleft vertical split")
        graph_win = vim.api.nvim_get_current_win()
        graph_buf = vim.api.nvim_get_current_buf()
        vim.api.nvim_win_set_width(graph_win, 60)
      else
      end
      vim.api.nvim_set_current_win(graph_win)
      vim.api.nvim_set_option_value("modifiable", true, {buf = graph_buf})
      vim.api.nvim_buf_set_lines(graph_buf, 0, -1, false, render_result.lines)
      for _, hl in ipairs(render_result.highlights) do
        vim.api.nvim_buf_add_highlight(graph_buf, -1, hl.hg, hl.row, hl.start, hl.stop)
      end
      vim.api.nvim_set_option_value("modifiable", false, {buf = graph_buf})
      graph_data = render_result
      if (src_win and vim.api.nvim_win_is_valid(src_win)) then
        vim.api.nvim_set_current_win(src_win)
      else
      end
      vim.cmd("DiffviewOpen main..HEAD")
    end
  else
  end
  local function _8_()
    return vim.cmd(("cd " .. cwd))
  end
  return pcall(_8_)
end
return M
