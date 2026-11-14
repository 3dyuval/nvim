-- [nfnl] fnl/workspace/ai-commit.fnl
do
  local ai_popup = require("utils.ai_popup")
  local function _1_(opts)
    if (opts.args == "--preview") or (opts.args == "-p") then
      return ai_popup.run_generate((vim.g.AiCommitLastSettings or {}))
    elseif (opts.args == "--repeat") or (opts.args == "-r") then
      return ai_popup.repeat_last()
    else
      return ai_popup.create()
    end
  end
  vim.api.nvim_create_user_command("AiCommit", _1_, { nargs = "?", desc = "AI commit popup" })
end
return {}
