-- [nfnl] fnl/plugins/claude.fnl
local function _1_()
  local function _2_(self)
    return self:hide()
  end
  require("claudecode").setup({focus_after_send = true, terminal = {snacks_win_opts = {position = "right", width = 0.35, enter = true, keys = {toggle = {"<C-Space>", _2_, mode = "t", desc = "Toggle Claude"}}}}})
  local function _3_()
    return vim.cmd("ClaudeCode")
  end
  return vim.api.nvim_create_autocmd("User", {pattern = "ClaudeCodeDiffOpened", callback = _3_})
end
return {"coder/claudecode.nvim", enabled = true, config = _1_}
