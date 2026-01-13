vim.api.nvim_create_user_command("BugTemplate", function(opts)
  local bug_num = opts.args or "X"
  require("utils.buffers").create_buffer_bug(bug_num)
end, { nargs = "?" })

vim.api.nvim_create_user_command("BugSnippet", function(opts)
  local bug_num = opts.args or "X"
  require("utils.buffers").create_buffer_bug_snippet(bug_num)
end, { nargs = "?" })
