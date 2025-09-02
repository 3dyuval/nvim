local M = {}

function M.show()
  local items = {
    -- Main actions
    { label = "󰚔  Issues", desc = "List repository issues", action = "issue list" },
    { label = "  Pull Requests", desc = "List repository PRs", action = "pr list" },
    {
      label = "  Notifications",
      desc = "View GitHub notifications",
      action = "notification list",
    },
    {
      label = "󰚔  My Issues",
      desc = "Search my issues across repos",
      action = "issue search author:@me",
    },
    {
      label = "󰚔  All Issues",
      desc = "Search all issues across repos",
      action = "issue search",
    },
    { label = "  Search PRs", desc = "Search pull requests across repos", action = "pr search" },
    { label = "󰚔  Create Issue", desc = "Create a new issue", action = "issue create" },
    { label = "  Create PR", desc = "Create a new pull request", action = "pr create" },
    { label = "󰊢  List Repos", desc = "List your repositories", action = "repo list" },
    { label = "  Start Review", desc = "Start a code review", action = "review start" },
    { label = "󰁯  Resume Review", desc = "Resume a code review", action = "review resume" },
  }

  -- Add context-aware items if in octo buffer
  local buftype = vim.bo.filetype
  if buftype == "octo" then
    local ok, utils = pcall(require, "octo.utils")
    if ok then
      local buffer = utils.get_current_buffer()
      if buffer then
        if buffer:isPullRequest() then
          -- Add PR-specific actions at the beginning
          table.insert(
            items,
            1,
            { label = "󰗡  PR Checks", desc = "View checks status", action = "pr checks" }
          )
          table.insert(
            items,
            1,
            { label = "󰈙  PR Files", desc = "View changed files", action = "pr changes" }
          )
          table.insert(
            items,
            1,
            { label = "  PR Commits", desc = "View commits in this PR", action = "pr commits" }
          )
        elseif buffer:isIssue() then
          -- Add issue-specific action at the beginning
          table.insert(items, 1, {
            label = "  Convert to PR",
            desc = "Convert issue to pull request",
            action = "issue pr",
          })
        end
      end
    end
  end

  local picker_items = {}
  for _, item in ipairs(items) do
    table.insert(picker_items, {
      text = item.label .. (item.desc and (" - " .. item.desc) or ""),
      action = item.action,
      label = item.label,
      desc = item.desc,
    })
  end

  require("snacks").picker.pick({
    source = "select",
    items = picker_items,
    prompt = "Octo menu",
    layout = { preset = "vscode" },
    actions = {
      confirm = function(picker, item)
        picker:close()
        if item and item.action then
          vim.cmd("Octo " .. item.action)
        end
      end,
    },
  })
end

return M
