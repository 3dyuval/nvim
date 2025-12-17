local popup = require("neogit.lib.popup")

local M = {}

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
    :action("g", "Generate & commit", function(popup)
      vim.notify("Generating AI commit message...", vim.log.levels.INFO)

      -- Helper to get cycling switch value
      local get_switch = function(suffix)
        for _, arg in ipairs(popup.state.args) do
          if arg.cli_suffix == suffix and arg.value and arg.value ~= "" then
            return arg.value
          end
        end
        return nil
      end

      -- Helper to get option value
      local get_opt = function(cli)
        for _, arg in ipairs(popup.state.args) do
          if arg.cli == cli and arg.value and arg.value ~= "" then
            return arg.value
          end
        end
        return nil
      end

      local length = get_switch("_length") or ""
      local diff_format = get_switch("_format") or "full"
      local args = popup:get_arguments()

      local dry_run = vim.tbl_contains(args, "--dry-run")
      local commit_type = get_opt("type")
      local scope = get_opt("scope")
      local msg_opts = {
        conventional = commit_type ~= nil or scope ~= nil,
        short = length == "short",
        detailed = length == "detailed",
        commit_type = commit_type,
        scope = scope,
      }

      -- Get diff based on format
      local diff_cmd = { "git", "diff", "--cached" }
      if diff_format == "stat" then
        table.insert(diff_cmd, "--stat")
      elseif diff_format == "names" then
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
            if dry_run then
              -- Show message in a scratch buffer
              vim.cmd("enew")
              local buf = vim.api.nvim_get_current_buf()
              vim.bo[buf].buftype = "nofile"
              vim.bo[buf].bufhidden = "wipe"
              vim.bo[buf].filetype = "gitcommit"
              vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(message, "\n"))
              vim.notify("Dry run: commit message preview", vim.log.levels.INFO)
            else
              -- Write message to temp file and use -t (template)
              local template_file = vim.fn.tempname()
              local file = io.open(template_file, "w")
              if file then
                file:write(message .. "\n")
                file:close()
                -- Open terminal in current buffer with git commit -t <template>
                vim.cmd("enew | terminal git commit -t " .. vim.fn.shellescape(template_file))
                vim.cmd("startinsert")
                -- Clean up after terminal closes
                vim.api.nvim_create_autocmd("TermClose", {
                  once = true,
                  callback = function()
                    os.remove(template_file)
                  end,
                })
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
    end)
    :build()
  p:show()
  return p
end

return M
