local popup = require("neogit.lib.popup")

local M = {}

-- Store last used settings
local last_settings = nil

-- Get type from the last commit (if conventional format)
local function get_last_type()
  local result = vim.fn.systemlist({ "git", "log", "-1", "--format=%s" })
  if result and result[1] then
    local commit_type = result[1]:match("^(%w+)[%(:]")
    return commit_type or ""
  end
  return ""
end

-- Get scope from the last commit (if conventional format)
local function get_last_scope()
  local result = vim.fn.systemlist({ "git", "log", "-1", "--format=%s" })
  if result and result[1] then
    local scope = result[1]:match("^%w+%(([^%)]+)%)!?:")
    return scope or ""
  end
  return ""
end

-- Run AI commit generation with given settings
local function run_generate(settings)
  vim.notify("Generating AI commit message...", vim.log.levels.INFO)

  -- Save settings for repeat
  last_settings = vim.deepcopy(settings)

  local msg_opts = {
    conventional = settings.commit_type ~= nil or settings.scope ~= nil,
    short = settings.length == "short",
    detailed = settings.length == "detailed",
    commit_type = settings.commit_type,
    scope = settings.scope,
  }

  -- Get diff based on format
  local diff_cmd = { "git", "diff", "--cached" }
  if settings.diff_format == "stat" then
    table.insert(diff_cmd, "--stat")
  elseif settings.diff_format == "names" then
    table.insert(diff_cmd, "--name-only")
  end
  local result = vim.fn.systemlist(diff_cmd)
  local diff = table.concat(result, "\n")

  if diff == "" then
    vim.notify("No staged changes. Run `git add` first.", vim.log.levels.ERROR)
    return
  end

  local ai = require("utils.ai_commit")
  ai.generateCommitMessage({
    diff = diff,
    msg_options = msg_opts,
    on_success = function(message)
      vim.schedule(function()
        if settings.dry_run then
          -- Show message in a scratch buffer
          vim.cmd("enew")
          local buf = vim.api.nvim_get_current_buf()
          vim.bo[buf].buftype = "nofile"
          vim.bo[buf].bufhidden = "wipe"
          vim.bo[buf].filetype = "gitcommit"
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(message, "\n"))
          vim.notify("Dry run: commit message preview", vim.log.levels.INFO)
        else
          -- Use Neogit's native commit with message pre-filled
          local git = require("neogit.lib.git")
          local client = require("neogit.client")
          local config = require("neogit.config")
          local a = require("plenary.async")

          a.run(function()
            client.wrap(git.cli.commit.with_message(message).edit, {
              autocmd = "NeogitCommitComplete",
              msg = {
                success = "Committed",
                fail = "Commit failed",
              },
              interactive = true,
              show_diff = config.values.commit_editor.show_staged_diff,
            })
          end)
        end
      end)
    end,
    on_error = function(error_msg)
      vim.notify(error_msg, vim.log.levels.ERROR)
    end,
  })
end

-- Extract settings from popup state
local function get_settings_from_popup(p)
  local get_switch = function(suffix)
    for _, arg in ipairs(p.state.args) do
      if arg.cli_suffix == suffix and arg.value and arg.value ~= "" then
        return arg.value
      end
    end
    return nil
  end

  local get_opt = function(cli)
    for _, arg in ipairs(p.state.args) do
      if arg.cli == cli and arg.value and arg.value ~= "" then
        return arg.value
      end
    end
    return nil
  end

  local args = p:get_arguments()
  return {
    length = get_switch("_length") or "",
    diff_format = get_switch("_format") or "full",
    dry_run = vim.tbl_contains(args, "--dry-run"),
    commit_type = get_opt("type"),
    scope = get_opt("scope"),
  }
end

function M.create()
  local p = popup
    .builder()
    :name("NeogitAIPopup")
    :arg_heading("Diff")
    :switch("d", "full", "Format", {
      cli_suffix = "_format",
      options = {
        { display = "full", value = "full" },
        { display = "stat", value = "stat" },
        { display = "names", value = "names" },
      },
    })
    :arg_heading("Message")
    :switch("l", "", "Length", {
      cli_suffix = "_length",
      options = {
        { display = "", value = "" },
        { display = "short", value = "short" },
        { display = "detailed", value = "detailed" },
      },
    })
    :switch("n", "dry-run", "Dry run", {
      enabled = false,
    })
    :option("t", "type", get_last_type(), "Type", {
      choices = {
        "build",
        "chore",
        "ci",
        "docs",
        "feat",
        "fix",
        "perf",
        "refactor",
        "revert",
        "style",
        "test",
      },
    })
    :option("s", "scope", get_last_scope(), "Scope", {
      choices = { "ui", "api", "core", "config", "deps", "docs", "test", "build", "ci" },
    })
    :group_heading("Actions")
    :action("c", "Generate & commit", function(p)
      run_generate(get_settings_from_popup(p))
    end)
    :build()
  p:show()
  return p
end

function M.repeat_last()
  if last_settings then
    run_generate(last_settings)
  else
    vim.notify("No previous AI commit settings to repeat", vim.log.levels.WARN)
  end
end

return M
