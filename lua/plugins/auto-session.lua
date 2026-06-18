-- [nfnl] fnl/plugins/auto-session.fnl
local function _1_()
  require("auto-session").setup({auto_session_enabled = true, auto_save = true, auto_restore = true, root_dir = (vim.fn.stdpath("data") .. "/sessions/"), bypass_save_filetypes = {"alpha", "dashboard", "slime", "git", "terminal"}, git_use_branch_name = true, git_auto_restore_on_branch_change = true})
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
return {"rmagatti/auto-session", config = _1_, lazy = false}
