-- [nfnl] fnl/plugins/kulala.fnl
local yank_baseurl
local function _1_()
  require("kulala.ui.openapi_panel").yank()
  local fixed = string.gsub(vim.fn.getreg("+"), "https?://{host}:{port}", "{{baseUrl}}")
  vim.fn.setreg("+", fixed)
  return vim.fn.setreg("\"", fixed)
end
yank_baseurl = _1_
local function _2_()
  return require("kulala").run()
end
local function _3_()
  return require("kulala").open_openapi_explorer()
end
local function _4_()
  return require("kulala").scratchpad()
end
local function _5_()
  return require("kulala").set_selected_env()
end
local function _6_()
  return require("kulala").replay()
end
local function _7_()
  return require("kulala").copy()
end
local function _8_()
  return require("kulala").clear_cached_files()
end
local function _9_(_, opts)
  require("kulala").setup(opts)
  local function _10_(ev)
    local ss = require("smart-splits")
    local dirs = {["<C-h>"] = "move_cursor_left", ["<C-a>"] = "move_cursor_down", ["<C-e>"] = "move_cursor_up", ["<C-i>"] = "move_cursor_right"}
    for key, dir in pairs(dirs) do
      local function _11_()
        return ss[dir]()
      end
      vim.keymap.set("n", key, _11_, {buffer = ev.buf, nowait = true, desc = "Window nav"})
    end
    if (vim.bo[ev.buf].filetype == "kulala_ui") then
      for _0, key in ipairs({"<C-PageUp>", "<C-PageDown>"}) do
        local function _12_()
          return require("kulala.ui").close_kulala_buffer()
        end
        vim.keymap.set("n", key, _12_, {buffer = ev.buf, nowait = true, desc = "Close kulala results"})
      end
    else
    end
    if (vim.bo[ev.buf].filetype == "kulala_openapi") then
      local panel = require("kulala.ui.openapi_panel")
      local crmaps
      local function _14_()
        return panel.run()
      end
      local function _15_()
        return panel.close()
      end
      crmaps = {["<leader>crr"] = {_14_, "Run operation"}, ["<leader>cry"] = {yank_baseurl, "Yank as HTTP (baseUrl)"}, ["<leader>crq"] = {_15_, "Close explorer"}}
      for key, spec in pairs(crmaps) do
        vim.keymap.set("n", key, spec[1], {buffer = ev.buf, nowait = true, desc = spec[2]})
      end
      return nil
    else
      return nil
    end
  end
  vim.api.nvim_create_autocmd("FileType", {pattern = {"kulala_openapi", "kulala_ui"}, callback = _10_})
  local function _17_(args)
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
  local function _20_()
    return {"run", "run-all", "scratchpad", "openapi", "clear-openapi-cache"}
  end
  return vim.api.nvim_create_user_command("Kulala", _17_, {nargs = "?", complete = _20_, desc = "Kulala HTTP client"})
end
return {"mistweaverco/kulala.nvim", dev = true, ft = {"http", "rest"}, cmd = {"Kulala"}, keys = {{"<leader>crr", _2_, desc = "Run request"}, {"<leader>cro", _3_, ft = {"http", "rest"}, desc = "OpenAPI explorer"}, {"<leader>cr.", _4_, desc = "Scratchpad"}, {"<leader>cre", _5_, desc = "Select environment"}, {"<leader>crR", _6_, desc = "Replay last request"}, {"<leader>crc", _7_, desc = "Copy as cURL"}, {"<leader>crX", _8_, desc = "Clear cached files"}}, opts = {kulala_keymaps = {["Next tab"] = false, ["Previous tab"] = false}, openapi_panel_keymaps = {["Yank as HTTP"] = {"Y", yank_baseurl}, ["Edit try it out"] = false, ["Load from file"] = false, Refresh = false, ["Toggle fold"] = false}, global_keymaps = false}, config = _9_}
