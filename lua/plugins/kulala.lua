-- [nfnl] fnl/plugins/kulala.fnl
local function _1_()
  return require("kulala").run()
end
local function _2_()
  return require("kulala")["run-all"]()
end
local function _3_()
  return require("kulala").scratchpad()
end
local function _4_(_, opts)
  require("kulala").setup(opts)
  local function _5_(args)
    local kulala = require("kulala")
    local action
    if (args.args == "") then
      action = "run"
    else
      action = args.args
    end
    if (action == "run") then
      return kulala.run()
    elseif (action == "run-all") then
      return kulala["run-all"]()
    elseif (action == "scratchpad") then
      return kulala.scratchpad()
    else
      local _0 = action
      return vim.notify(("Kulala: unknown action " .. action), vim.log.levels.ERROR)
    end
  end
  local function _8_()
    return {"run", "run-all", "scratchpad"}
  end
  return vim.api.nvim_create_user_command("Kulala", _5_, {nargs = "?", complete = _8_, desc = "Kulala HTTP client"})
end
return {"mistweaverco/kulala.nvim", ft = {"http", "rest"}, cmd = {"Kulala"}, keys = {{"<leader>at", _1_, desc = "Send request"}, {"<leader>aT", _2_, desc = "Send all requests"}, {"<leader>ar", _3_, desc = "Open scratchpad"}}, opts = {keymaps = {}, global_keymaps = false}, config = _4_}
