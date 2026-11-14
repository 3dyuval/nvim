-- [nfnl] fnl/plugins/surround.fnl
local M = {}
local disable_surround
local function _1_()
  return not vim.bo.modifiable
end
disable_surround = { _1_ }
M.get_input = function(prompt)
  return require("nvim-surround.config").get_input(prompt)
end
local function ts_find(capture)
  local function _2_()
    return require("nvim-surround.config").get_selection({ query = { capture = capture, type = "textobjects" } })
  end
  return { find = _2_ }
end
local mirror_pairs =
  { ["("] = ")", [")"] = "(", ["["] = "]", ["]"] = "[", ["{"] = "}", ["}"] = "{", ["<"] = ">", [">"] = "<" }
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
      return { { ("<" .. opening_tag .. ">") }, { ("</" .. tag_name .. ">") } }
    else
      return { { input }, { mirror(input) } }
    end
  else
    return nil
  end
end
local function _5_()
  vim.g.nvim_surround_no_visual_mappings = true
  return nil
end
local function _6_(_, opts)
  do
    local buffer = require("nvim-surround.buffer")
    local function _7_(motion)
      local curpos = buffer.get_curpos()
      local visual_marks = { buffer.get_mark("<"), buffer.get_mark(">") }
      buffer.del_marks({ "[", "]" })
      vim.go.operatorfunc = "v:lua.require'nvim-surround.utils'.NOOP"
      vim.cmd.normal({ args = { ("g@" .. motion) }, bang = true })
      buffer.adjust_mark("[")
      buffer.adjust_mark("]")
      buffer.set_curpos(curpos)
      buffer.set_mark("<", visual_marks[1])
      return buffer.set_mark(">", visual_marks[2])
    end
    buffer.set_operator_marks = _7_
  end
  require("nvim-surround").setup(opts)
  local function _8_()
    local should_disable = false
    for _0, cond in ipairs(disable_surround) do
      if should_disable then
        break
      end
      if cond() then
        should_disable = true
      else
      end
    end
    if should_disable then
      for _0, key in ipairs({ "s", "gS" }) do
        pcall(vim.keymap.set, "x", key, "<Nop>", { buffer = 0 })
      end
      for _0, key in ipairs({ "ys", "yss", "yS", "ySS", "ds", "cs", "cS" }) do
        pcall(vim.keymap.set, "n", key, "<Nop>", { buffer = 0 })
      end
      return nil
    else
      return nil
    end
  end
  return vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, { pattern = "*", callback = _8_ })
end
return {
  "kylechui/nvim-surround",
  event = "VeryLazy",
  dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
  init = _5_,
  opts = {
    surrounds = {
      ["("] = { add = { "(", ")" } },
      [")"] = { add = { "( ", " )" } },
      ["{"] = { add = { "{", "}" } },
      ["}"] = { add = { "{ ", " }" } },
      ["["] = { add = { "[", "]" } },
      ["]"] = { add = { "[ ", " ]" } },
      ["<"] = { add = { "<", ">" } },
      [">"] = { add = { "< ", " >" } },
      ["*"] = { add = { "**", "**" } },
      _ = { add = { "_", "_" } },
      ["~"] = { add = { "~", "~" } },
      tf = ts_find("@function.outer"),
      rf = ts_find("@function.inner"),
      tc = ts_find("@class.outer"),
      rc = ts_find("@class.inner"),
      tp = ts_find("@parameter.outer"),
      rp = ts_find("@parameter.inner"),
      tl = ts_find("@loop.outer"),
      rl = ts_find("@loop.inner"),
      ts = ts_find("@scope"),
      rs = ts_find("@scope"),
      tt = ts_find("@tag.outer"),
      rt = ts_find("@tag.inner"),
      i = { add = custom_delimiter },
    },
    aliases = { b = { "(", "[", "{", "<" } },
  },
  config = _6_,
}
