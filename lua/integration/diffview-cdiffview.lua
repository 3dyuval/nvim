-- [nfnl] fnl/integration/diffview-cdiffview.fnl
local M = {}
M["create-graph-view"] = function()
  local ok, CDiffView_module
  local function _1_()
    return require("diffview.api.views.diff.diff_view")
  end
  ok, CDiffView_module = pcall(_1_)
  if not ok then
    vim.notify(("Failed to load CDiffView: " .. CDiffView_module), vim.log.levels.WARN)
    return nil
  else
    local CDiffView = CDiffView_module.CDiffView
    if not CDiffView then
      vim.notify("CDiffView class not found in module", vim.log.levels.WARN)
      return nil
    else
      local gitgraph = require("gitgraph")
      local core = require("gitgraph.core")
      local git_root = vim.fn.getcwd()
      local graph_result = core.render_data(gitgraph.config, {}, {all = true, max_count = 256})
      local files = M["create-file-entries"](graph_result)
      local function _2_(view)
        return M["create-file-entries"](core.render_data(gitgraph.config, {}, {all = true, max_count = 256}))
      end
      local function _3_(path, split)
        return M["get-commit-content"](path, split)
      end
      return CDiffView({git_root = git_root, files = files, update_files = _2_, get_file_data = _3_})
    end
  end
end
M["create-file-entries"] = function(graph_result)
  local files = {}
  local commits = (graph_result.graph or {})
  for idx, row in ipairs(commits) do
    if (row.commit and row.commit.hash) then
      table.insert(files, {path = row.commit.hash, oldpath = nil, status = "M", selected = (idx == 1)})
    else
    end
  end
  return files
end
M["get-commit-content"] = function(hash, split)
  local cmd
  if (split == "left") then
    cmd = ("git show " .. hash .. "^")
  else
    cmd = ("git show " .. hash)
  end
  return vim.fn.systemlist(cmd)
end
M.open = function()
  local view = M["create-graph-view"]()
  if view then
    return view:open()
  else
    return nil
  end
end
return M
