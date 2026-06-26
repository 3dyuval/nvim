-- [nfnl] fnl/plugins/claude.fnl
local function _1_()
  local function _2_(self)
    self:hide()
    local function _3_()
      if (self.win and vim.api.nvim_win_is_valid(self.win) and (vim.api.nvim_get_current_win() == self.win)) then
        pcall(vim.cmd, "wincmd p")
      else
      end
      if (vim.fn.mode() == "t") then
        return pcall(vim.cmd, "stopinsert")
      else
        return nil
      end
    end
    return vim.schedule(_3_)
  end
  require("claudecode").setup({terminal = {snacks_win_opts = {position = "float", width = 0.95, height = 0.88, border = "rounded", enter = true, keys = {toggle = {"<C-Space>", _2_, mode = "t", desc = "Toggle Claude"}}, backdrop = false}}})
  local function _6_()
    return vim.cmd("ClaudeCode")
  end
  return vim.api.nvim_create_autocmd("User", {pattern = "ClaudeCodeDiffOpened", callback = _6_})
end
return {"coder/claudecode.nvim", enabled = true, config = _1_}
