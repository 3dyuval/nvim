-- [nfnl] fnl/plugins/auto-session.fnl
local function _1_()
  require("auto-session").setup({auto_session_enabled = true, auto_save = true, root_dir = (vim.fn.stdpath("data") .. "/sessions/"), bypass_save_filetypes = {"alpha", "dashboard", "slime", "git", "terminal"}, close_unsupported_windows = true, suppressed_dirs = {"/tmp", "~/Downloads", "/", "~/.config/nvim"}, git_use_branch_name = true, git_auto_restore_on_branch_change = true, session_lens = {picker = "snacks"}, auto_restore = false})
  local function _2_()
    return vim.cmd(":AutoSession save")
  end
  vim.api.nvim_create_user_command("SaveSession", _2_, {desc = "Save the current session"})
  local function _3_()
    return vim.cmd(":AutoSession restore")
  end
  vim.api.nvim_create_user_command("RestoreSession", _3_, {desc = "Restore the last saved session"})
  local function _4_(opts)
    if opts.args then
      return vim.cmd((":AutoSession delete " .. opts.args))
    else
      return vim.cmd(":AutoSession delete")
    end
  end
  return vim.api.nvim_create_user_command("DeleteSession", _4_, {nargs = "?", desc = "Delete a saved session"})
end
return {"rmagatti/auto-session", pin = true, branch = "fix/issue-516-branch-hash", config = _1_, lazy = false}
