-- [nfnl] fnl/workspace/bug-template.fnl
local function _1_(opts)
  return require("utils.buffers").create_buffer_bug((opts.args or "X"))
end
vim.api.nvim_create_user_command("BugTemplate", _1_, { nargs = "?" })
local function _2_(opts)
  return require("utils.buffers").create_buffer_bug_snippet((opts.args or "X"))
end
vim.api.nvim_create_user_command("BugSnippet", _2_, { nargs = "?" })
return {}
