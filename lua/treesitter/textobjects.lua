-- [nfnl] fnl/treesitter/textobjects.fnl
local bindings = {["@function.outer"] = {["move-next"] = {"]f", "]c"}, ["move-prev"] = {"[f", "[c"}, ["move-end-next"] = {"]M"}, ["move-end-prev"] = {"[M"}, select = "tf", ["swap-next"] = "]F", ["swap-prev"] = "[F"}, ["@function.inner"] = {select = "rf"}, ["@class.outer"] = {["move-next"] = {"]C"}, ["move-prev"] = {"[C"}}, ["@parameter.inner"] = {["move-next"] = {"]p"}, ["move-prev"] = {"[p"}, ["swap-next"] = "]P", ["swap-prev"] = "[A"}, ["@loop.*"] = {["move-next"] = {"]l"}, ["move-prev"] = {"[l"}}, ["@scope"] = {["move-next"] = {"]s"}, ["move-prev"] = {"[s"}, select = "rs"}, ["@fold"] = {["move-next"] = {"]u"}, ["move-prev"] = {"[u"}}, ["@tag.inner"] = {select = "rt"}, ["@tag.outer"] = {select = "tt"}, ["@block.inner"] = {select = "rb"}, ["@block.outer"] = {select = "tb"}, ["@jsx_self_closing_element"] = {select = "te"}}
local function build_map(field)
  local t = {}
  for capture, opts in pairs(bindings) do
    local v = opts[field]
    if v then
      if (type(v) == "string") then
        t[v] = capture
      else
        for _, k in ipairs(v) do
          t[k] = capture
        end
      end
    else
    end
  end
  return t
end
local function hud_hints()
  local hints = {}
  for capture, opts in pairs(bindings) do
    local k = opts.select
    if k then
      hints[("treesitter:" .. capture)] = k
    else
    end
  end
  return hints
end
local function setup()
  local TS = require("nvim-treesitter-textobjects")
  return TS.setup({move = {enable = true, set_jumps = true, goto_next_start = build_map("move-next"), goto_next_end = build_map("move-end-next"), goto_previous_start = build_map("move-prev"), goto_previous_end = build_map("move-end-prev")}, select = {enable = true, keymaps = build_map("select")}, swap = {enable = true, swap_next = build_map("swap-next"), swap_previous = build_map("swap-prev")}})
end
return {setup = setup, ["hud-hints"] = hud_hints}
