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
    local Rev = CDiffView_module.Rev
    local RevType = CDiffView_module.RevType
    if not CDiffView then
      vim.notify("CDiffView class not found in module", vim.log.levels.WARN)
      return nil
    else
      local gitgraph = require("gitgraph")
      local core = require("gitgraph.core")
      local git_root = "/home/yuv/proj/gitgraph.nvim-snacks-api"
      local graph_result = core.render_data(gitgraph.config, {}, {all = true, max_count = 256})
      local commits = (graph_result.graph or {})
      local files = M["create-file-entries"](graph_result)
      local first_commit = ((#commits > 0) and commits[1].commit and commits[1].commit.hash)
      local function _2_(view)
        return M["create-file-entries"](core.render_data(gitgraph.config, {}, {all = true, max_count = 256}))
      end
      local function _3_(path, split)
        return M["get-commit-content"](path, split)
      end
      return CDiffView({git_root = git_root, files = files, left = Rev(RevType.COMMIT, ((first_commit or "HEAD") .. "^")), right = Rev(RevType.COMMIT, (first_commit or "HEAD")), update_files = _2_, get_file_data = _3_})
    end
  end
end
M["create-file-entries"] = function(graph_result)
  local files = {}
  local commits = (graph_result.graph or {})
  local first_commit = ((#commits > 0) and commits[1].commit and commits[1].commit.hash)
  if first_commit then
    local changed_files = vim.fn.systemlist(("git diff --name-only " .. first_commit .. "^.." .. first_commit))
    for idx, file in ipairs(changed_files) do
      table.insert(files, {path = file, oldpath = nil, status = "M", selected = (idx == 1)})
    end
  else
  end
  return files
end
M["get-commit-content"] = function(path, split)
  local cmd
  if (split == "left") then
    cmd = ("git show HEAD^:" .. path)
  else
    cmd = ("git show HEAD:" .. path)
  end
  return vim.fn.systemlist(cmd)
end
M.open = function()
  local cwd = vim.fn.getcwd()
  vim.cmd("cd /home/yuv/proj/gitgraph.nvim-snacks-api")
  vim.cmd("DiffviewOpen")
  return vim.cmd(("cd " .. cwd))
end
return M
