local M = {}

---@param bug_num string
M.create_buffer_bug = function(bug_num)
  local buf = vim.api.nvim_create_buf(false, true)

  local lines = {
    "# bug " .. bug_num or 1 .. ": [title]",
    "",
    "context:",
    "[describe the context]",
    "@[file_path]",
    "",
    "reproduction:",
    "go to `[url]`",
    "",
    "what to find and where and how to find it:",
    "[description]",
    "",
    "the tricky part and why:",
    "[explanation]",
  }
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = "markdown"
  vim.bo[buf].buftype = ""
  vim.bo[buf].modifiable = true

  vim.api.nvim_set_current_buf(buf)
  vim.api.nvim_buf_set_name(buf, "bug.md")
end

---@param bug_num string
M.create_buffer_bug_snippet = function(bug_num)
  local buf = vim.api.nvim_create_buf(false, true)

  local num = (bug_num or "1")
  local markdown = {
    "# bug " .. num .. ": $1",
    "",
    "context:",
    "$2",
    "file: @[$3]",
    "",
    "reproduction:",
    "go to `$4`",
    "",
    "what to find and where and how to find it:",
    "$5",
    "",
    "the tricky part and why:",
    "$6",
  }
  vim.bo[buf].filetype = "markdown"
  vim.bo[buf].buftype = ""
  vim.bo[buf].modifiable = true

  vim.api.nvim_set_current_buf(buf)

  vim.api.nvim_buf_set_name(buf, "bug-" .. num .. ".md")
  vim.snippet.expand(table.concat(markdown, "\n"))
end

return M
