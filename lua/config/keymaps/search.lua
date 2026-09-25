-- [nfnl] fnl/config/keymaps/search.fnl
local lset = vim.keymap.set
local function _1_()
  local grug_far = require("grug-far")
  local entry = grug_far.get_last_history_entry()
  return grug_far.open({prefills = entry})
end
lset("n", "<leader>rg", _1_, {desc = "Find and replace - last search (GrugFar)"})
local function _2_()
  return require("grug-far").open({prefills = {paths = vim.fn.expand("%")}})
end
lset("n", "<leader>rG", _2_, {desc = "Find and replace - current file (GrugFar)"})
local function _3_()
  return require("workspace.grug-history").pick()
end
lset("n", "<leader>rt", _3_, {desc = "Find and replace - history picker (GrugFar)"})
local function _4_()
  return require("grug-far").with_visual_selection({visualSelectionUsage = "prefill-search"})
end
lset("v", "<leader>rg", _4_, {desc = "Find and replace - selection as search (GrugFar)"})
local function _5_()
  return require("grug-far").with_visual_selection({visualSelectionUsage = "operate-within-range"})
end
lset("v", "<leader>rG", _5_, {desc = "Find and replace - within selection (GrugFar)"})
local function _6_()
  return require("utils.picker-extensions").open_explorer({layout = {preset = "fullscreen"}, focus = "list"})
end
lset("n", "<leader>of", _6_, {desc = "Explorer (fullscreen)"})
local function _7_()
  return require("utils.picker-extensions").open_explorer({layout = {preset = "fullscreen"}, focus = "input"})
end
lset("n", "<leader>ff", _7_, {desc = "Explorer (fullscreen, focus input)"})
local function _8_()
  return require("utils.picker-extensions").open_explorer({layout = {preset = "sidebar"}, focus = "list", auto_close = false})
end
lset("n", "<leader>fE", _8_, {desc = "Explorer (persistent, no auto-close)"})
local function _9_()
  return Snacks.picker.buffers({layout = {preset = "fullscreen"}})
end
lset("n", "<leader>fF", _9_, {desc = "Buffers (fullscreen)"})
local function _10_()
  return Snacks.picker.grep()
end
lset("n", "<C-/>", _10_, {desc = "Grep (top level)"})
local function _11_()
  return require("workspace.grep")["grep-current-buffer-dir"]()
end
return lset("n", "<leader>/", _11_, {desc = "Grep (current buffer's dir)"})
