-- [nfnl] fnl/plugins/dial.fnl
local function _1_()
  return require("dial.map").manipulate("increment", "normal")
end
local function _2_()
  return require("dial.map").manipulate("decrement", "normal")
end
local function _3_()
  return require("dial.map").manipulate("increment", "visual")
end
local function _4_()
  return require("dial.map").manipulate("decrement", "visual")
end
local function _5_()
  return require("dial.map").manipulate("increment", "gvisual")
end
local function _6_()
  return require("dial.map").manipulate("decrement", "gvisual")
end
local function _7_()
  local augend = require("dial.augend")
  local cyclic
  local function _8_(words)
    return augend.constant.new({elements = words, word = true, cyclic = true})
  end
  cyclic = _8_
  local symbol
  local function _9_(words)
    return augend.constant.new({elements = words, cyclic = true, word = false})
  end
  symbol = _9_
  return require("dial.config").augends:register_group({default = {augend.integer.alias.decimal_int, augend.integer.alias.hex, augend.constant.alias.bool, augend.date.alias["%Y-%m-%d"], augend.date.alias["%H:%M"], augend.semver.alias.semver, augend.constant.new({elements = {"True", "False"}, word = true, cyclic = true}), cyclic({"and", "or"}), cyclic({"yes", "no"}), cyclic({"on", "off"}), cyclic({"let", "const"}), cyclic({"enable", "disable"}), symbol({"&&", "||"}), symbol({"==", "!="}), symbol({"<", ">"})}})
end
return {"monaqa/dial.nvim", enabled = true, keys = {{"<C-a>", _1_, mode = "n", desc = "Increment"}, {"<C-x>", _2_, mode = "n", desc = "Decrement"}, {"<C-a>", _3_, mode = "v", desc = "Increment"}, {"<C-x>", _4_, mode = "v", desc = "Decrement"}, {"g<C-a>", _5_, mode = "v", desc = "Increment (sequence)"}, {"g<C-x>", _6_, mode = "v", desc = "Decrement (sequence)"}}, config = _7_}
