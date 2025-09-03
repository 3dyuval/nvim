local M = {}

function M.search_issues_involving_me(state)
  local query = "is:issue involves:@me"

  if state then
    query = query .. " is:" .. (state == true and "open" or state)
  end

  local git_root = Snacks.git.get_root()
  if not git_root then
    return "Octo search " .. query
  end

  local result = vim.fn.system(
    "cd "
      .. vim.fn.shellescape(git_root)
      .. " && gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null"
  )
  local owner_repo = vim.trim(result)

  if vim.v.shell_error == 0 and owner_repo ~= "" then
    return "Octo search " .. query .. " repo:" .. owner_repo
  else
    return "Octo search " .. query
  end
end

function M.search_open_issues_involving_me()
  return M.search_issues_involving_me(true)
end

function M.search_open_prs_involving_me()
  return M.search_prs_involving_me(true)
end

M.search_all_issues = "Octo issue search"

function M.search_prs_involving_me(state)
  local query = "is:pr involves:@me"

  if state then
    query = query .. " is:" .. (state == true and "open" or state)
  end

  local git_root = Snacks.git.get_root()
  if not git_root then
    return "Octo search " .. query
  end

  local result = vim.fn.system(
    "cd "
      .. vim.fn.shellescape(git_root)
      .. " && gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null"
  )
  local owner_repo = vim.trim(result)

  if vim.v.shell_error == 0 and owner_repo ~= "" then
    return "Octo search " .. query .. " repo:" .. owner_repo
  else
    return "Octo search " .. query
  end
end

M.search_my_issues = "Octo issue search author:@me"

function M.search_all_prs()
  return "Octo pr search"
end

M.create_issue = "Octo issue create"
M.create_pr = "Octo pr create"
M.list_repo_issues = "Octo issue list"
M.list_repo_prs = "Octo pr list"
M.list_notifications = "Octo notification list"
M.list_repos = "Octo repo list"
M.start_review = "Octo review start"
M.resume_review = "Octo review resume"

M.menu_items = {
  {
    label = "󰚔 Repo Issues",
    desc = "List issues in current repository", 
    action = M.list_repo_issues,
  },
  { label = " Pull Requests", desc = "List repository PRs", action = M.list_repo_prs },
  {
    label = "  Notifications",
    desc = "View GitHub notifications",
    action = M.list_notifications,
  },
  {
    label = "󰚔 My Issues", 
    desc = "Search my issues across repos",
    action = M.search_my_issues,
  },
  {
    label = "󰚔 All Issues",
    desc = "Search all issues across repos", 
    action = M.search_all_issues,
  },
  {
    label = "  Search PRs",
    desc = "Search pull requests across repos",
    action = M.search_all_prs,
  },
  { label = " Create PR", desc = "Create a new pull request", action = M.create_pr },
  { label = "󰚔 Create Issue", desc = "Create a new issue", action = M.create_issue },
  { label = "󰊢 List Repos", desc = "List your repositories", action = M.list_repos },
  { label = " Start Review", desc = "Start a code review", action = M.start_review },
  { label = "󰁯 Resume Review", desc = "Resume a code review", action = M.resume_review },
}

function M.show_menu()
  local items = vim.deepcopy(M.menu_items)

  local buftype = vim.bo.filetype
  if buftype == "octo" then
    local ok, utils = pcall(require, "octo.utils")
    if ok then
      local buffer = utils.get_current_buffer()
      if buffer then
        if buffer:isPullRequest() then
          table.insert(
            items,
            1,
            { label = "󰗡 PR Checks", desc = "View checks status", action = "pr checks" }
          )
          table.insert(
            items,
            1,
            { label = "󰈙 PR Files", desc = "View changed files", action = "pr changes" }
          )
          table.insert(
            items,
            1,
            { label = " PR Commits", desc = "View commits in this PR", action = "pr commits" }
          )
        elseif buffer:isIssue() then
          table.insert(items, 1, {
            label = " Convert to PR",
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
          if type(item.action) == "function" then
            local result = item.action()
            if type(result) == "string" then
              vim.cmd(result)
            end
          else
            vim.cmd("Octo " .. item.action)
          end
        end
      end,
    },
  })
end

return M
