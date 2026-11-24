-- [nfnl] fnl/workspace/tutor.fnl
local M = {}
M.setup = function()
  local function _1_(opts)
    vim.api.nvim_del_user_command("Tutor")
    vim.cmd("source $VIMRUNTIME/plugin/tutor.vim")
    return vim.cmd(("Tutor " .. opts.args))
  end
  local function _2_()
    return {}
  end
  return vim.api.nvim_create_user_command(
    "Tutor",
    _1_,
    { nargs = "?", complete = _2_, desc = "Open the Neovim tutor (lazy-sources the runtime plugin)" }
  )
end
M.setup()
return M
