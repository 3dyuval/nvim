-- [nfnl] fnl/config/keymaps/search.fnl
local lset = vim.keymap.set
local function _1_()
  return require("utils.picker-extensions").open_explorer({layout = {preset = "fullscreen"}, focus = "list"})
end
lset("n", "<leader>of", _1_, {desc = "Explorer (fullscreen)"})
local function _2_()
  return require("utils.picker-extensions").open_explorer({layout = {preset = "fullscreen"}, focus = "input"})
end
lset("n", "<leader>ff", _2_, {desc = "Explorer (fullscreen, focus input)"})
local function _3_()
  return Snacks.picker.buffers({layout = {preset = "fullscreen"}})
end
lset("n", "<leader>fF", _3_, {desc = "Buffers (fullscreen)"})
local function _4_()
  return Snacks.picker.grep()
end
lset("n", "<C-/>", _4_, {desc = "Grep (top level)"})
local function _5_()
  return require("workspace.grep")["grep-current-buffer-dir"]()
end
return lset("n", "<leader>/", _5_, {desc = "Grep (current buffer's dir)"})
