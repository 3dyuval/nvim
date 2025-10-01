local popup = require("neogit.lib.popup")

local M = {}

-- Reusable function to generate diny message and commit
local function generate_diny_and_commit()
  vim.notify("Generating diny commit message...", vim.log.levels.INFO)

  local message_output = {}
  vim.fn.jobstart("/home/yuval/proj/diny/diny message", {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data then
        vim.list_extend(message_output, data)
      end
    end,
    on_stderr = function(_, data)
      if data and data[1] and data[1] ~= "" then
        local error_msg = table.concat(data, "\n")
        vim.notify("Diny error: " .. error_msg, vim.log.levels.ERROR)
      end
    end,
    on_exit = function(_, exit_code)
      if exit_code == 0 and #message_output > 0 then
        local message = table.concat(message_output, "\n"):gsub("\n$", "")
        if message ~= "" then
          vim.notify("Diny message generated: " .. message, vim.log.levels.INFO)

          vim.schedule(function()
            -- Use plenary async to avoid C-call boundary issue
            local a = require("plenary.async")
            a.run(function()
              -- Write message to commit file right before opening editor
              local commit_file = ".git/COMMIT_EDITMSG"
              local file = io.open(commit_file, "w")
              if file then
                file:write(message .. "\n")
                file:close()
              end

              local commit_actions = require("neogit.popups.commit.actions")
              local mock_popup = {
                get_arguments = function() return {} end,
                state = { args = {} }
              }
              commit_actions.commit(mock_popup)
            end)
          end)
        end
      end
    end,
  })
end

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
          -- Write message directly to git's commit message file
          local commit_file = ".git/COMMIT_EDITMSG"
          local file = io.open(commit_file, "w")
          if file then
            file:write(message .. "\n")
            file:close()
            vim.notify("AI message generated: " .. message, vim.log.levels.INFO)

            -- Open the commit editor using direct API
            require("neogit").action("commit", "commit", {})
          else
            vim.notify("Error: Could not write to " .. commit_file, vim.log.levels.ERROR)
          end
        end,
        on_error = function(error_msg)
          vim.notify(error_msg, vim.log.levels.ERROR)
        end,
      })
    end)
    :action("d", "Diny Message", function(popup)
      -- Close the popup first
      popup:close()

      -- Use the reusable function
      generate_diny_and_commit()
    end)
    :build()

  p:show()
  return p
end

-- Export the reusable function
M.generate_diny_and_commit = generate_diny_and_commit

return M
