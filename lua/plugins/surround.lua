-- [nfnl] fnl/plugins/surround.fnl
local M = {}
local disable_surround
local function _1_()
  return not vim.bo.modifiable
end
disable_surround = {_1_}
M.get_input = function(prompt)
  return require("nvim-surround.config").get_input(prompt)
end
M.get_selection = function(args)
  if args.motion then
    return require("nvim-surround.config").get_selection({motion = args.motion})
  elseif args.query then
    local ok, ts_queries = pcall(require, "nvim-treesitter-textobjects.queries")
    if not ok then
      vim.notify("nvim-treesitter-textobjects not available", vim.log.levels.WARN)
      return nil
    else
      local bufnr = vim.api.nvim_get_current_buf()
      local node = ts_queries.get_node_at_cursor(bufnr, args.query.capture)
      if not node then
        return nil
      else
        local start_row, start_col, end_row, end_col = node:range()
        return {left = {first_pos = {(start_row + 1), (start_col + 1)}}, right = {last_pos = {(end_row + 1), end_col}}}
      end
    end
  else
    return nil
  end
end
local function ts_find(capture)
  local function _5_()
    return M.get_selection({query = {capture = capture}})
  end
  return {find = _5_}
end
local mirror_pairs = {["("] = ")", [")"] = "(", ["["] = "]", ["]"] = "[", ["{"] = "}", ["}"] = "{", ["<"] = ">", [">"] = "<"}
local function mirror(input)
  local right = ""
  for i = #input, 1, -1 do
    local char = input:sub(i, i)
    right = (right .. (mirror_pairs[char] or char))
  end
  return right
end
local function custom_delimiter()
  local input = M.get_input("Enter delimiter pair (left/right or tag): ")
  if input then
    local opening_tag = input:match("^<([^/>]+)>?$")
    if opening_tag then
      local tag_name = opening_tag:match("^([^%s>]+)")
      return {{("<" .. opening_tag .. ">")}, {("</" .. tag_name .. ">")}}
    else
      return {{input}, {mirror(input)}}
    end
  else
    return nil
  end
end
local function _8_()
  vim.g.nvim_surround_no_visual_mappings = true
  return nil
end
local function _9_()
  local lang = M.get_input("Language: ")
  local function _10_()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    vim.api.nvim_win_set_cursor(0, {(row + 1), 0})
    return vim.cmd("startinsert")
  end
  vim.schedule(_10_)
  return {{"```", ""}, {"", "```"}}
end
local function _11_()
  return M.get_selection({motion = "a`"})
end
local function _12_()
  return require("nvim-surround.config").get_selections({char = "`", pattern = "^(```.-\n)().*(```\n?)()$"})
end
local function _13_(_, opts)
  do
    local buffer = require("nvim-surround.buffer")
    local function _14_(motion)
      local curpos = buffer.get_curpos()
      local visual_marks = {buffer.get_mark("<"), buffer.get_mark(">")}
      buffer.del_marks({"[", "]"})
      vim.go.operatorfunc = "v:lua.require'nvim-surround.utils'.NOOP"
      vim.cmd.normal({args = {("g@" .. motion)}, bang = true})
      buffer.adjust_mark("[")
      buffer.adjust_mark("]")
      buffer.set_curpos(curpos)
      buffer.set_mark("<", visual_marks[1])
      return buffer.set_mark(">", visual_marks[2])
    end
    buffer.set_operator_marks = _14_
  end
  require("nvim-surround").setup(opts)
  local function _15_()
    local should_disable = false
    for _0, cond in ipairs(disable_surround) do
      if should_disable then break end
      if cond() then
        should_disable = true
      else
      end
    end
    if should_disable then
      for _0, key in ipairs({"s", "gS"}) do
        pcall(vim.keymap.set, "x", key, "<Nop>", {buffer = 0})
      end
      for _0, key in ipairs({"ys", "yss", "yS", "ySS", "ds", "cs", "cS"}) do
        pcall(vim.keymap.set, "n", key, "<Nop>", {buffer = 0})
      end
      return nil
    else
      return nil
    end
  end
  return vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {pattern = "*", callback = _15_})
end
return {"kylechui/nvim-surround", event = "VeryLazy", dependencies = {"nvim-treesitter/nvim-treesitter-textobjects"}, init = _8_, opts = {surrounds = {["("] = {add = {"(", ")"}}, [")"] = {add = {"( ", " )"}}, ["{"] = {add = {"{", "}"}}, ["}"] = {add = {"{ ", " }"}}, ["["] = {add = {"[", "]"}}, ["]"] = {add = {"[ ", " ]"}}, ["<"] = {add = {"<", ">"}}, [">"] = {add = {"< ", " >"}}, ["*"] = {add = {"**", "**"}}, _ = {add = {"_", "_"}}, ["~"] = {add = {"~", "~"}}, ["`"] = {add = _9_, find = _11_, delete = _12_}, tf = ts_find("@function.outer"), rf = ts_find("@function.inner"), tc = ts_find("@class.outer"), rc = ts_find("@class.inner"), tp = ts_find("@parameter.outer"), rp = ts_find("@parameter.inner"), tl = ts_find("@loop.outer"), rl = ts_find("@loop.inner"), ts = ts_find("@scope"), rs = ts_find("@scope"), tt = ts_find("@tag.outer"), rt = ts_find("@tag.inner"), i = {add = custom_delimiter}}, aliases = {b = {"(", "[", "{", "<"}}}, config = _13_}
