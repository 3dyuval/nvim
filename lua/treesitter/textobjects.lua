-- [nfnl] fnl/treesitter/textobjects.fnl
local bindings = {["@function.outer"] = {["move-next"] = {"]f", "]c"}, ["move-prev"] = {"[f", "[c"}, ["move-end-next"] = {"]M"}, ["move-end-prev"] = {"[M"}, select = "tf", ["swap-next"] = "]F", ["swap-prev"] = "[F"}, ["@function.inner"] = {select = "rf"}, ["@class.outer"] = {["move-next"] = {"]C"}, ["move-prev"] = {"[C"}}, ["@parameter.inner"] = {["move-next"] = {"]p"}, ["move-prev"] = {"[p"}, ["swap-next"] = "]P", ["swap-prev"] = "[A"}, ["@loop.*"] = {["move-next"] = {"]l"}, ["move-prev"] = {"[l"}}, ["@scope"] = {["move-next"] = {"]s"}, ["move-prev"] = {"[s"}, select = "rs"}, ["@fold"] = {["move-next"] = {"]u"}, ["move-prev"] = {"[u"}}, ["@tag.inner"] = {select = "rt"}, ["@tag.outer"] = {select = "tt"}, ["@block.inner"] = {select = "rb"}, ["@block.outer"] = {select = "tb"}, ["@jsx_self_closing_element"] = {select = "te"}}
local function query_group(capture)
  if capture:match("fold") then
    return "folds"
  else
    return "textobjects"
  end
end
local function expand_query(capture)
  if capture:match("%*$") then
    return {capture:gsub("%*", "inner"), capture:gsub("%*", "outer")}
  else
    return capture
  end
end
local function as_keys(v)
  if (type(v) == "string") then
    return {v}
  else
    return v
  end
end
local function map_select(keys, capture)
  local select = require("nvim-treesitter-textobjects.select")
  local query = expand_query(capture)
  local group = query_group(capture)
  for _, k in ipairs(as_keys(keys)) do
    local function _4_()
      return select.select_textobject(query, group)
    end
    vim.keymap.set({"x", "o"}, k, _4_, {desc = ("Select " .. capture)})
  end
  return nil
end
local function map_move(keys, capture, fname, desc)
  local move = require("nvim-treesitter-textobjects.move")
  local query = expand_query(capture)
  local group = query_group(capture)
  for _, k in ipairs(as_keys(keys)) do
    local function _5_()
      return move[fname](query, group)
    end
    vim.keymap.set({"n", "x", "o"}, k, _5_, {desc = (desc .. " " .. capture)})
  end
  return nil
end
local function map_swap(keys, capture, fname, desc)
  local swap = require("nvim-treesitter-textobjects.swap")
  local query = expand_query(capture)
  for _, k in ipairs(as_keys(keys)) do
    local function _6_()
      return swap[fname](query)
    end
    vim.keymap.set("n", k, _6_, {desc = (desc .. " " .. capture)})
  end
  return nil
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
  do
    local TS = require("nvim-treesitter-textobjects")
    TS.setup({})
  end
  for capture, opts in pairs(bindings) do
    if opts.select then
      map_select(opts.select, capture)
    else
    end
    if opts["move-next"] then
      map_move(opts["move-next"], capture, "goto_next_start", "Next start of")
    else
    end
    if opts["move-prev"] then
      map_move(opts["move-prev"], capture, "goto_previous_start", "Prev start of")
    else
    end
    if opts["move-end-next"] then
      map_move(opts["move-end-next"], capture, "goto_next_end", "Next end of")
    else
    end
    if opts["move-end-prev"] then
      map_move(opts["move-end-prev"], capture, "goto_previous_end", "Prev end of")
    else
    end
    if opts["swap-next"] then
      map_swap(opts["swap-next"], capture, "swap_next", "Swap next")
    else
    end
    if opts["swap-prev"] then
      map_swap(opts["swap-prev"], capture, "swap_previous", "Swap prev")
    else
    end
  end
  return nil
end
return {setup = setup, ["hud-hints"] = hud_hints}
