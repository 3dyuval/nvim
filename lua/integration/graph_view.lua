--- GraphView: DiffView variant that shows gitgraph instead of file tree
--- Registered as a custom view kind for composition

local oop = require("diffview.oop")
local DiffView = require("diffview.scene.views.diff.diff_view")
local GraphPanel = require("integration.graph_panel")

---@class GraphView : DiffView
---@field graph_panel GraphPanel
---@field graph_data table Gitgraph render result
local GraphView = oop.create_class("GraphView", DiffView)

--- Factory function: Create a GraphView with gitgraph rendering
---@param adapter VCSAdapter
---@param rev_arg string?
---@param path_args string[]
---@param opts table Options from diffview_options
---@return GraphView
function GraphView.create(adapter, rev_arg, path_args, opts)
  -- Render gitgraph data
  local ok_core, core = pcall(require, "gitgraph.core")
  if not ok_core then
    vim.notify("Failed to load gitgraph.core", vim.log.levels.WARN)
    return nil
  end

  local ok_gitgraph, gitgraph = pcall(require, "gitgraph")
  if not ok_gitgraph then
    vim.notify("Failed to load gitgraph", vim.log.levels.WARN)
    return nil
  end

  local ok_render, render_data = pcall(core.render_data, gitgraph.config, {}, {
    all = true,
    max_count = 256,
  })
  if not ok_render then
    vim.notify("Failed to render graph: " .. tostring(render_data), vim.log.levels.ERROR)
    return nil
  end

  -- Create GraphView instance
  local view = GraphView({
    adapter = adapter,
    rev_arg = rev_arg,
    path_args = path_args,
    left = opts.left,
    right = opts.right,
    options = opts.options,
  })

  if not view:is_valid() then
    return nil
  end

  -- Store graph data and set up custom panel
  view.graph_data = render_data
  view.graph_panel = GraphPanel(render_data)
  view.panel = view.graph_panel

  return view
end

--- GraphView constructor
function GraphView:init(opt)
  GraphView.super(self, opt)
  self.graph_data = nil
  self.graph_panel = nil
end

--- Override post_open to render the graph panel
---@override
function GraphView:post_open()
  GraphView.super(self)
  if self.graph_panel then
    self.graph_panel:render()
    self.graph_panel:redraw()
  end
end

return GraphView
