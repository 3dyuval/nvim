-- [nfnl] fnl/plugins/claude.fnl
local function _1_()
  require("claudecode").setup({terminal = {snacks_win_opts = {position = "right", width = 0.35, keys = {toggle = {"<C-Space>", "hide", mode = "t", desc = "Toggle Claude"}}}}})
  local function _2_()
    return vim.cmd("ClaudeCode")
  end
  return vim.api.nvim_create_autocmd("User", {pattern = "ClaudeCodeDiffOpened", callback = _2_})
end
return {"coder/claudecode.nvim", enabled = true, config = _1_}
