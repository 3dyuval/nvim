local Job = require("plenary.job")

local M = {}

function M.generateCommitMessage(opts)
  opts = opts or {}
  local diff_options = opts.diff_options or { cached = true } -- default to cached
  local on_success = opts.on_success or function(message) end
  local on_error = opts.on_error or function(error_msg) end

  -- Build git diff arguments
  local diff_args = { "diff" }

  if diff_options.cached then
    table.insert(diff_args, "--cached")
  end

  if diff_options.stat then
    table.insert(diff_args, "--stat")
  end

  if diff_options.name_only then
    table.insert(diff_args, "--name-only")
  end

  if diff_options.ignore_whitespace then
    table.insert(diff_args, "--ignore-all-space")
  end

  if diff_options.find_renames then
    table.insert(diff_args, "-M")
  end

  if diff_options.find_copies then
    table.insert(diff_args, "-C")
  end

  -- First get the diff
  Job:new({
    command = "git",
    args = diff_args,
    on_exit = function(diff_job, return_val)
      if return_val ~= 0 then
        vim.schedule(function()
          on_error("No staged changes to generate commit message for")
        end)
        return
      end

      local diff = table.concat(diff_job:result(), "\n")
      if diff == "" then
        vim.schedule(function()
          on_error("No staged changes to generate commit message for")
        end)
        return
      end

      -- Build the prompt
      local prompt = "write a basic commit message with 10 words max based on this diff"

      -- Now call claude with the diff
      Job:new({
        command = "claude",
        args = { "-p", prompt },
        writer = diff,
        on_exit = function(claude_job, claude_return_val)
          vim.schedule(function()
            if claude_return_val ~= 0 then
              on_error("Failed to generate AI commit message")
              return
            end

            local message = table.concat(claude_job:result(), "\n"):gsub("[\n\r]+$", "")
            if message and message ~= "" then
              on_success(message)
            else
              on_error("Failed to generate AI commit message")
            end
          end)
        end,
      }):start()
    end,
  }):start()
end

return M
