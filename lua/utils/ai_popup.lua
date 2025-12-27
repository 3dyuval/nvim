local popup = require("neogit.lib.popup")

local M = {}

-- Store last used settings
local last_settings = nil

-- Parse last commit for conventional format info
-- Returns: { conventional = bool, type = string, scope = string }
local function get_last_commit_info()
  local result = vim.fn.systemlist({ "git", "log", "-1", "--format=%s" })
  if result and result[1] then
    local subject = result[1]
    local commit_type = subject:match("^(%w+)[%(:]")
    local scope = subject:match("^%w+%(([^%)]+)%)!?:") or ""
    return {
      conventional = commit_type ~= nil,
      type = commit_type or "",
      scope = scope,
    }
  end
  return { conventional = false, type = "", scope = "" }
end

-- Run AI commit generation with given settings
local function run_generate(settings)
  vim.notify("Generating AI commit message...", vim.log.levels.INFO)

  -- Save settings for repeat
  last_settings = vim.deepcopy(settings)

  local msg_opts = {
    conventional = settings.conventional,
    body = settings.body,
    commit_type = settings.commit_type,
    scope = settings.scope,
    subject = settings.subject,
    wrap = settings.wrap,
    subject_wrap = settings.subject_wrap,
    footer = settings.footer,
    preview_prompt = settings.preview_prompt,
  }

  -- Get diff based on format
  local ai = require("utils.ai_commit")
  local diff_cmd = { "git", "diff", "--cached" }
  if settings.diff_format == "stat" then
    table.insert(diff_cmd, "--stat")
  elseif settings.diff_format == "names" then
    table.insert(diff_cmd, "--name-only")
  end
  -- Exclude noisy files
  table.insert(diff_cmd, "--")
  table.insert(diff_cmd, ".")
  for _, file in ipairs(ai.ignored_files) do
    table.insert(diff_cmd, ":!" .. file)
  end
  local result = vim.fn.systemlist(diff_cmd)
  local diff = table.concat(result, "\n")

  if diff == "" then
    vim.notify("No staged changes. Run `git add` first.", vim.log.levels.ERROR)
    return
  end

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
          -- Write message to temp file, use Neogit's native commit
          local git = require("neogit.lib.git")
          local client = require("neogit.client")
          local neogit_config = require("neogit.config")
          local a = require("plenary.async")

          local template_file = vim.fn.tempname()
          local file = io.open(template_file, "w")
          if file then
            file:write(message .. "\n")
            file:close()

            a.run(function()
              -- Use -F file with --edit: reads from file, opens editor, quit=cancel, save=commit
              client.wrap(git.cli.commit.edit.args("-F", template_file), {
                autocmd = "NeogitCommitComplete",
                msg = {
                  success = "Committed",
                  fail = "Commit failed",
                },
                interactive = true,
                show_diff = neogit_config.values.commit_editor.show_staged_diff,
              })
              os.remove(template_file)
            end)
          else
            vim.notify("Error: Could not write template file", vim.log.levels.ERROR)
          end
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
    diff_format = get_switch("_format") or "full",
    conventional = vim.tbl_contains(args, "--conventional"),
    dry_run = vim.tbl_contains(args, "--dry-run"),
    body = vim.tbl_contains(args, "--body"),
    body_format = get_switch("_body_format") or "bullets",
    preview_prompt = vim.tbl_contains(args, "--prompt"),
    commit_type = get_opt("type"),
    scope = get_opt("scope"),
    wrap = tonumber(get_opt("wrap")) or 72,
    subject_wrap = tonumber(get_opt("subject-wrap")) or 50,
    footer = get_opt("footer"),
  }
end

function M.create()
  local last = get_last_commit_info()
  local p = popup
    .builder()
    :name("NeogitAIPopup")
    :arg_heading("Conventional")
    :switch("c", "conventional", "Conventional format", {
      enabled = last.conventional,
    })
    :option("t", "type", last.type, "Type", {
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
    :option("s", "scope", last.scope, "Scope", {
      choices = { "ui", "api", "core", "config", "deps", "docs", "test", "build", "ci" },
    })
    :arg_heading("Options")
    :switch("d", "full", "Diff format", {
      cli_suffix = "_format",
      options = {
        { display = "full", value = "full" },
        { display = "stat", value = "stat" },
        { display = "names", value = "names" },
      },
    })
    :switch("b", "body", "Include body", {
      enabled = false,
    })
    :switch("B", "bullets", "Body format", {
      cli_suffix = "_body_format",
      options = {
        { display = "bullets", value = "bullets" },
        { display = "paragraph", value = "paragraph" },
      },
    })
    :switch("n", "dry-run", "Dry run", {
      enabled = false,
    })
    :switch("P", "prompt", "Preview prompt", {
      enabled = false,
    })
    :option("f", "footer", "", "Footer")
    :arg_heading("Limits")
    :option("w", "wrap", "72", "Body wrap")
    :option("W", "subject-wrap", "50", "Subject wrap")
    :group_heading("Actions")
    :action("i", "Generate & commit", function(p)
      run_generate(get_settings_from_popup(p))
    end)
    :action("I", "Generate with subject", function(p)
      local subject = vim.fn.input("Subject: ")
      if subject ~= "" then
        local settings = get_settings_from_popup(p)
        settings.subject = subject
        run_generate(settings)
      end
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
