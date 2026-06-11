-- [nfnl] fnl/plugins/smart-splits.fnl
local function _1_()
  return require("smart-splits").move_cursor_left()
end
local function _2_()
  return require("smart-splits").move_cursor_down()
end
local function _3_()
  return require("smart-splits").move_cursor_up()
end
local function _4_()
  return require("smart-splits").move_cursor_right()
end
local function _5_()
  return require("smart-splits").resize_left()
end
local function _6_()
  return require("smart-splits").resize_down()
end
local function _7_()
  return require("smart-splits").resize_up()
end
local function _8_()
  return require("smart-splits").resize_right()
end
return {"mrjones2014/smart-splits.nvim", opts = {at_edge = "stop", multiplexer_integration = "kitty"}, keys = {{"<C-h>", _1_, desc = "Window left"}, {"<C-a>", _2_, desc = "Window down"}, {"<C-e>", _3_, desc = "Window up"}, {"<C-i>", _4_, desc = "Window right"}, {"<C-M-h>", _5_, desc = "Resize left"}, {"<C-M-a>", _6_, desc = "Resize down"}, {"<C-M-e>", _7_, desc = "Resize up"}, {"<C-M-i>", _8_, desc = "Resize right"}}, lazy = false}
