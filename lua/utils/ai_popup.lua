local popup = require("neogit.lib.popup")

local M = {}

-- Usage:
--   require("utils.ai_popup").create()       -- Open AI commit popup
--   require("utils.ai_popup").repeat_last()  -- Repeat with last settings
--
-- Single command setup (add to your config):
--   vim.api.nvim_create_user_command("AiCommit", function(opts)
--     if opts.args == "--preview" or opts.args == "-p" then
--       local settings = vim.g.AiCommitLastSettings or {}
--       settings.dry_run = true
--       require("utils.ai_popup").run_generate(settings)
--     elseif opts.args == "--repeat" or opts.args == "-r" then
--       require("utils.ai_popup").repeat_last()
--     else
--       require("utils.ai_popup").create()
--     end
--   end, { nargs = "?" })
--
-- Then use:
--   :AiCommit            -- Open popup
--   :AiCommit --preview  -- Dry run with last settings
--   :AiCommit --repeat   -- Repeat last commit generation

-- Store last used settings (persisted per session via persistence.nvim)
-- Must start with uppercase for persistence.nvim to save it
-- vim.g.AiCommitLastSettings = nil (initialized on first use)

-- Parse last commit for conventional commit format
-- opts: { include_type = bool, include_scope = bool }
-- Returns: { conventional = bool, type = string, scope = string }
local function get_conventional_defaults(opts)
  opts = opts or {}
  local include_type = opts.include_type or false
  local include_scope = opts.include_scope or false

  local result = vim.fn.systemlist({ "git", "log", "-1", "--format=%s" })
  if result and result[1] then
    local subject = result[1]
    local commit_type = subject:match("^(%w+)[%(:]")
    local scope = subject:match("^%w+%(([^%)]+)%)!?:") or ""
    return {
      conventional = commit_type ~= nil,
      type = include_type and (commit_type or "") or "",
      scope = include_scope and scope or "",
    }
  end
  return { conventional = false, type = "", scope = "" }
end

-- Run AI commit generation with given settings
function M.run_generate(settings)
  vim.notify("Generating AI commit message...", vim.log.levels.INFO)

  -- Save settings for repeat (persisted per session, excluding subject)
  local to_persist = vim.deepcopy(settings)
  to_persist.subject = nil -- subject is per-commit, don't persist
  vim.g.AiCommitLastSettings = to_persist

  local msg_opts = {
    conventional = settings.conventional,
    breaking = settings.breaking,
    body = settings.body,
    commit_type = settings.commit_type,
    scope = settings.scope,
    subject = settings.subject,
    extra_prompt = settings.extra_prompt,
    header_max = settings.header_max,
    body_max = settings.body_max,
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
    breaking = vim.tbl_contains(args, "--breaking"),
    dry_run = vim.tbl_contains(args, "--dry-run"),
    body = vim.tbl_contains(args, "--body"),
    body_format = get_switch("_body_format") or "bullets",
    preview_prompt = vim.tbl_contains(args, "--prompt"),
    commit_type = get_opt("type"),
    scope = get_opt("scope"),
    header_max = tonumber(get_opt("header-max")) or 100,
    body_max = tonumber(get_opt("body-max")) or 100,
    footer = vim.tbl_contains(args, "--footer"),
    extra_prompt = get_opt("guide") or (vim.g.AiCommitLastSettings or {}).extra_prompt or "",
  }
end

function M.create()
  local last = get_conventional_defaults({
    include_type = false,
    include_scope = false,
  })
  -- Get persisted extra prompt (truncate for display)
  local saved = vim.g.AiCommitLastSettings or {}
  local extra_prompt = saved.extra_prompt or ""
  local extra_prompt_display = #extra_prompt > 20 and extra_prompt:sub(1, 20) .. "…" or extra_prompt
  local p = popup
    .builder()
    :name("NeogitAIPopup")
    :switch("d", "full", "Diff in Prompt", {
      cli_suffix = "_format",
      options = {
        { display = "full", value = "full" },
        { display = "stat", value = "stat" },
        { display = "names", value = "names" },
      },
    })
    :switch("c", "conventional", "Conventional format", {
      enabled = last.conventional,
    })
    :option_if(last.conventional, "t", "type", last.type, "Type", {
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
    :option_if(last.conventional, "s", "scope", last.scope, "Scope", {
      choices = { "ui", "api", "core", "config", "deps", "docs", "test", "build", "ci" },
    })
    :switch_if(last.conventional, "!", "breaking", "Breaking change (!)", {
      enabled = false,
    })
    :arg_heading("Format")
    :switch("i", "body", "Include body", {
      enabled = false,
    })
    :switch("b", "bullets", "Body format", {
      cli_suffix = "_body_format",
      options = {
        { display = "bullets", value = "bullets" },
        { display = "paragraph", value = "paragraph" },
      },
    })
    :switch("p", "prompt", "Preview diffs pass to AI prompt", {
      enabled = false,
    })
    :switch("f", "footer", "Include footer", {
      enabled = false,
    })
    :option("g", "guide", extra_prompt_display, "Extra prompt guide")
    :option("h", "header-max", "100", "Header max length")
    :option("b", "body-max", "100", "Body line max length")
    :group_heading("Actions")
    :action("U", "Dry Run (Preview)", function(p)
      local settings = get_settings_from_popup(p)
      settings.dry_run = true
      M.run_generate(settings)
    end)
    :action("C", "Generate & commit", function(p)
      M.run_generate(get_settings_from_popup(p))
    end)
    :action("S", "Generate with subject", function(p)
      local subject = vim.fn.input("Subject: ")
      if subject ~= "" then
        local settings = get_settings_from_popup(p)
        settings.subject = subject
        M.run_generate(settings)
      end
    end)
    :build()
  p:show()
  return p
end

function M.repeat_last()
  if vim.g.AiCommitLastSettings then
    M.run_generate(vim.g.AiCommitLastSettings)
  else
    vim.notify("No previous AI commit settings to repeat", vim.log.levels.WARN)
  end
end

return M
