-- [nfnl] fnl/plugins/dial.fnl
local function key(lhs, mode, dir, dial_mode, desc)
  local function _1_()
    return require("dial.map").manipulate(dir, dial_mode)
  end
  return {lhs, _1_, mode = mode, desc = desc}
end
local function _2_()
  local augend = require("dial.augend")
  local cyclic
  local function _3_(words)
    return augend.constant.new({elements = words, word = true, cyclic = true})
  end
  cyclic = _3_
  local symbol
  local function _4_(words)
    return augend.constant.new({elements = words, cyclic = true, word = false})
  end
  symbol = _4_
  return require("dial.config").augends:register_group({default = {augend.integer.alias.decimal_int, augend.integer.alias.hex, augend.constant.alias.bool, augend.date.alias["%Y-%m-%d"], augend.date.alias["%H:%M"], augend.semver.alias.semver, augend.constant.new({elements = {"True", "False"}, word = true, cyclic = true}), cyclic({"and", "or"}), cyclic({"yes", "no"}), cyclic({"on", "off"}), cyclic({"let", "const"}), cyclic({"enable", "disable"}), symbol({"&&", "||"}), symbol({"==", "!="}), symbol({"<", ">"})}})
end
return {"monaqa/dial.nvim", enabled = true, keys = {key("ge", "n", "increment", "normal", "Increment"), key("ga", "n", "decrement", "normal", "Decrement"), key("ge", "v", "increment", "visual", "Increment"), key("ga", "v", "decrement", "visual", "Decrement"), key("gge", "v", "increment", "gvisual", "Increment (sequence)"), key("gga", "v", "decrement", "gvisual", "Decrement (sequence)")}, config = _2_}
