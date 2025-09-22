local popup = require("neogit.lib.popup")

local M = {}

function M.create()
  local p = popup
    .builder()
    :name("NeogitAIPopup")
    :switch("D", "cached", "Use cached in message query", { enabled = false })
    :switch("s", "stat", "Show diffstat summary", { enabled = false })
    :switch("n", "name-only", "Show only file names", { enabled = false })
    :switch("w", "ignore-all-space", "Ignore whitespace changes", { enabled = false })
    :switch("M", "find-renames", "Detect renames", { enabled = false })
    :switch("C", "find-copies", "Detect copies", { enabled = false })
    :group_heading("AI Actions")
    :action("c", "Generate & Commit", function(popup)
      -- Show loading notification
      vim.notify("Generating AI commit message...", vim.log.levels.INFO)

      -- Build diff options from popup switches
      local diff_opts = {}
      for _, arg in ipairs(popup.state.args) do
        if arg.type == "switch" and arg.enabled then
          if arg.cli == "cached" then
            diff_opts.cached = true
          elseif arg.cli == "stat" then
            diff_opts.stat = true
          elseif arg.cli == "name-only" then
            diff_opts.name_only = true
          elseif arg.cli == "ignore-all-space" then
            diff_opts.ignore_whitespace = true
          elseif arg.cli == "find-renames" then
            diff_opts.find_renames = true
          elseif arg.cli == "find-copies" then
            diff_opts.find_copies = true
          end
        end
      end

      local ai = require("utils.ai_commit")
      ai.generateCommitMessage({
        diff_options = diff_opts,
        on_success = function(message)
          -- Store the message in a global variable for the autocmd to pick up
          vim.g.neogit_ai_message = message
          vim.notify("AI message generated: " .. message, vim.log.levels.INFO)

          -- Open the commit editor using direct API
          require("neogit").action("commit", "commit")
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
