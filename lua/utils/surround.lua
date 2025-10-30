-- Surround configuration layer: defines custom nvim-surround behaviors
-- Interface layer: ~/.config/nvim/lua/config/keymaps.lua translates Graphite layout to surround inputs
local M = {}

---@type user_options
M.opts = {
  keymaps = {
    -- Standard nvim-surround defaults (kept for clarity)
    insert = "<C-g>s",
    insert_line = "<C-g>S",
    normal = "ks", -- Add surround: ks{motion}{char} (changed from ys)
    normal_cur = "kss", -- Add surround to current line (changed from yss)
    normal_line = "kS", -- Changed from yS
    normal_cur_line = "kSS", -- Changed from ySS

    -- CUSTOM GRAPHITE LAYOUT CHANGES:
    visual = "s", -- Visual surround: s instead of S (Graphite convenience)
    visual_line = "gS", -- Default
    delete = "xs", -- Delete surround: xs instead of ds (Graphite X=delete)
    change = "ws", -- Change surround: ws instead of cs (Graphite W=change)
    change_line = "cS", -- Default
  },

  surrounds = {
    -- CUSTOM SPACING BEHAVIOR (reversed from defaults):
    -- Opening brackets = non-spaced, Closing brackets = spaced
    -- This allows: ysw( → (text), ysw) → ( text )

    ["("] = { add = { "(", ")" } }, -- Custom: non-spaced (default was spaced)
    [")"] = { add = { "( ", " )" } }, -- Custom: spaced (default was non-spaced)
    ["{"] = { add = { "{", "}" } }, -- Custom: non-spaced (default was spaced)
    ["}"] = { add = { "{ ", " }" } }, -- Custom: spaced (default was non-spaced)
    ["<"] = { add = { "<", ">" } }, -- Custom: non-spaced (default was spaced)
    [">"] = { add = { "< ", " >" } }, -- Custom: spaced (default was non-spaced)
    ["["] = { add = { "[", "]" } }, -- Custom: always non-spaced (default was spaced)
    ["]"] = { add = { "[ ", " ]" } }, -- Custom: spaced (default was non-spaced)

    -- MARKDOWN ADDITIONS (not in defaults):
    ["*"] = { add = { "**", "**" } }, -- Bold: **text**
    ["_"] = { add = { "_", "_" } }, -- Italic: _text_
    ["~"] = { add = { "~~", "~~" } }, -- Strikethrough: ~~text~~

    -- CUSTOM INPUT SURROUND: Prompt for custom delimiter pair
    ["i"] = {
      add = function()
        local config = require("nvim-surround.config")
        local input = config.get_input("Enter delimiter pair (left/right or tag): ")
        if not input then
          return
        end

        -- Check if it looks like a tag: <Tag> or just Tag
        local opening_tag = input:match("^<([^/>]+)>?$")
        if opening_tag then
          local tag_name = opening_tag:match("^([^%s>]+)")
          return { { "<" .. opening_tag .. ">" }, { "</" .. tag_name .. ">" } }
        end

        -- Mapping of opening to closing delimiters (bidirectional)
        local pairs = {
          ["("] = ")",
          [")"] = "(",
          ["["] = "]",
          ["]"] = "[",
          ["{"] = "}",
          ["}"] = "{",
          ["<"] = ">",
          [">"] = "<",
        }

        -- Mirror and reverse the input to create closing delimiter
        -- e.g., "<'{" → "}'>", "{`" → "`}"
        local right = ""
        for i = #input, 1, -1 do
          local char = input:sub(i, i)
          right = right .. (pairs[char] or char)
        end

        return { { input }, { right } }
      end,
    },

    -- Note: Other surrounds (quotes, HTML tags, function calls) use plugin defaults
  },

  aliases = {
    -- Standard aliases (kept for clarity):
    ["a"] = ">", -- a → angle brackets
    ["b"] = ")", -- b → parentheses (round brackets)
    ["B"] = "}", -- B → braces (curly brackets)
    ["q"] = { '"', "'", "`" }, -- q → any quote
    ["s"] = { "}", "]", ")", ">", '"', "'", "`" }, -- s → any surround

    -- CUSTOM: Removed default "r" = "]" because r=inner in our Graphite layout
  },
}

return M
