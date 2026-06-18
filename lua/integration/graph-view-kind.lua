-- [nfnl] fnl/integration/graph-view-kind.fnl
local M = {}
local function graph_render(self)
  if not self.graph_data then
    local ok_core, core
    local function _1_()
      return require("gitgraph.core")
    end
    ok_core, core = pcall(_1_)
    local ok_gitgraph, gitgraph
    local function _2_()
      return require("gitgraph")
    end
    ok_gitgraph, gitgraph = pcall(_2_)
    if (ok_core and ok_gitgraph) then
      local ok_render, render_result
      local function _3_()
        return core.render_data(gitgraph.config, {}, {all = true, max_count = 256})
      end
      ok_render, render_result = pcall(_3_)
      if ok_render then
        self.graph_data = render_result
      else
      end
    else
    end
  else
  end
  if self.graph_data then
    local bufnr = self.bufid
    if vim.api.nvim_buf_is_valid(bufnr) then
      vim.api.nvim_set_option_value("modifiable", true, {buf = bufnr})
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, self.graph_data.lines)
      for _, hl in ipairs(self.graph_data.highlights) do
        vim.api.nvim_buf_add_highlight(bufnr, -1, hl.hg, hl.row, hl.start, hl.stop)
      end
      return vim.api.nvim_set_option_value("modifiable", false, {buf = bufnr})
    else
      return nil
    end
  else
    return nil
  end
end
M["open-graph"] = function()
  do
    local lib = require("diffview.lib")
    local function _9_()
      local view = lib.get_current_view()
      if view then
        view.panel.graph_data = nil
        view.panel.render = graph_render
        return nil
      else
        return nil
      end
    end
    vim.api.nvim_create_autocmd("User", {pattern = "DiffviewViewOpened", once = true, callback = _9_})
  end
  return vim.cmd("DiffviewOpen main..HEAD")
end
return M
