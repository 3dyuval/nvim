local popup = require("neogit.lib.popup")

local M = {}

function M.create()
  local p = popup
    .builder()
    :name("NeogitAIPopup")
    :group_heading("Diff Options")
    :switch("D", "cached", "Use staged changes", { enabled = true })
    :switch("s", "stat", "Show diffstat summary", { enabled = false })
    :switch("n", "name-only", "Show only file names", { enabled = false })
    :switch("w", "ignore-all-space", "Ignore whitespace changes", { enabled = false })
    :switch("M", "find-renames", "Detect renames", { enabled = false })
    :switch("C", "find-copies", "Detect copies", { enabled = false })
    :group_heading("Message Format")
    :switch("c", "conventional", "Conventional commit format", { enabled = false })
    :switch("b", "body", "Include detailed body", { enabled = false })
    :switch("S", "short", "Short message (10 words max)", { enabled = true, incompatible = { "detailed" } })
    :switch("d", "detailed", "Detailed message", { enabled = false, incompatible = { "short" } })
    :option("t", "type", "", "Commit type (feat/fix/docs/etc)")
    :option("o", "scope", "", "Commit scope")
    :option("f", "footer", "", "Footer (issue refs, etc)")
    :group_heading("Actions")
    :action("g", "Generate", function(popup)
      vim.notify("Generating AI commit message...", vim.log.levels.INFO)

      local args = popup:get_arguments()
      local has = function(flag)
        return vim.tbl_contains(args, "--" .. flag)
      end

      local msg_opts = {
        conventional = has("conventional"),
        body = has("body"),
        short = has("short"),
        detailed = has("detailed"),
        commit_type = popup.state.env.type,
        scope = popup.state.env.scope,
        footer = popup.state.env.footer,
      }

      -- Get diff directly via git command
      local diff_args = { "diff", "--cached" }
      local result = vim.fn.systemlist(diff_args)
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
          local commit_file = vim.fn.getcwd() .. "/.git/COMMIT_EDITMSG"
          vim.fn.mkdir(vim.fn.fnamemodify(commit_file, ":h"), "p")
          local file = io.open(commit_file, "w")
          if file then
            file:write(message .. "\n")
            file:close()
            vim.schedule(function()
              vim.cmd("edit " .. commit_file)
            end)
          else
            vim.notify("Error: Could not write to " .. commit_file, vim.log.levels.ERROR)
          end
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
