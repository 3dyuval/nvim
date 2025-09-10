local M = {}

function M.generateCommitMessage(opts)
  opts = opts or {}
  local diff_cmd = opts.diff_cmd or "git diff --cached"

  -- Get the diff
  local diff = vim.fn.system(diff_cmd)

  if diff == "" or diff:match("^%s*$") then
    vim.notify("No staged changes to generate commit message for", vim.log.levels.WARN)
    return nil
  end

  -- Call claude with the diff to generate commit message
  local prompt = "write a basic commit message with 10 words max based on this diff"
  local claude_cmd = string.format('echo %s | claude -p "%s"', vim.fn.shellescape(diff), prompt)

  local result = vim.fn.system(claude_cmd)

  if vim.v.shell_error ~= 0 then
    vim.notify("Failed to generate commit message: " .. result, vim.log.levels.ERROR)
    return nil
  end

  -- Clean up the result (remove trailing newlines)
  result = result:gsub("[\n\r]+$", "")

  return result
end

return M