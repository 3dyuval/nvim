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
local function _4_()
  return require("kulala").open_openapi_explorer()
end
local function _5_(_, opts)
  require("kulala").setup(opts)
  local function _6_(args)
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
    elseif (action == "openapi") then
      return kulala.open_openapi_explorer()
    elseif (action == "clear-openapi-cache") then
      return kulala.clear_openapi_schema_cache()
    else
      local _0 = action
      return vim.notify(("Kulala: unknown action " .. action), vim.log.levels.ERROR)
    end
  end
  local function _9_()
    return {"run", "run-all", "scratchpad", "openapi", "clear-openapi-cache"}
  end
  return vim.api.nvim_create_user_command("Kulala", _6_, {nargs = "?", complete = _9_, desc = "Kulala HTTP client"})
end
return {"mistweaverco/kulala.nvim", dev = true, ft = {"http", "rest"}, cmd = {"Kulala"}, keys = {{"<leader>at", _1_, desc = "Send request"}, {"<leader>aT", _2_, desc = "Send all requests"}, {"<leader>ar", _3_, desc = "Open scratchpad"}, {"<leader>ao", _4_, ft = {"http", "rest"}, desc = "OpenAPI explorer (spec ref under cursor)"}}, opts = {keymaps = {}, openapi_panel = {win_opts = {wo = {winbar = ""}}}, openapi_panel_keymaps = {["Edit try it out"] = false, ["Load from file"] = false, Refresh = false}, global_keymaps = false}, config = _5_}
