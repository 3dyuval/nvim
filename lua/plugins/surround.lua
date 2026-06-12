local M = {}

-- Each entry disables surround for a buffer when it returns true.
-- Uncomment conditions to re-enable them.
local disable_surround = {
  function() return not vim.bo.modifiable end,
  -- function() return vim.bo.buftype ~= "" end,
  -- function() return vim.api.nvim_buf_get_name(0):match("^diffview://") ~= nil end,
  -- function() return vim.api.nvim_buf_get_name(0):match("^git://") ~= nil and not vim.api.nvim_buf_get_name(0):match("^neogit://") end,
  -- function() return vim.api.nvim_buf_get_name(0) == "" end,
}


M.get_input = function(prompt)
  local config = require("nvim-surround.config")
  return config.get_input(prompt)
end

M.get_selection = function(args)
  if args.motion then
    return require("nvim-surround.config").get_selection({motion = args.motion})
  elseif args.query then
    local ok, ts_queries = pcall(require, "nvim-treesitter-textobjects.queries")
    if not ok then
      vim.notify("nvim-treesitter-textobjects not available", vim.log.levels.WARN)
      return nil
    end
    local bufnr = vim.api.nvim_get_current_buf()
    local node = ts_queries.get_node_at_cursor(bufnr, args.query.capture)
    if not node then
      return nil
    end
    local start_row, start_col, end_row, end_col = node:range()
    return {
      left = {first_pos = {start_row + 1, start_col + 1}},
      right = {last_pos = {end_row + 1, end_col}}
    }
  end
end

return {
  "kylechui/nvim-surround",
  event = "VeryLazy",
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects"
  },
  opts = {
    surrounds = {
      ["*"] = {add = {"**", "**"}},
      ["_"] = {add = {"_", "_"}},
      ["~"] = {add = {"~", "~"}},
      ["`"] = {
        add = function()
          local lang = M.get_input("Language: ")
          vim.schedule(
            function()
              local row = vim.api.nvim_win_get_cursor(0)[1]
              vim.api.nvim_win_set_cursor(0, {row + 1, 0})
              vim.cmd("startinsert")
            end
          )
          return {{"```" .. (lang or ""), ""}, {"", "```"}}
        end,
        find = function()
          return M.get_selection({motion = "a`"})
        end,
        delete = function()
          local config = require("nvim-surround.config")
          return config.get_selections(
            {
              char = "`",
              pattern = "^(```.-\n)().*(```\n?)()$"
            }
          )
        end
      },
      ["tf"] = {
        find = function()
          return M.get_selection({query = {capture = "@function.outer"}})
        end
      },
      ["rf"] = {
        find = function()
          return M.get_selection({query = {capture = "@function.inner"}})
        end
      },
      ["tc"] = {
        find = function()
          return M.get_selection({query = {capture = "@class.outer"}})
        end
      },
      ["rc"] = {
        find = function()
          return M.get_selection({query = {capture = "@class.inner"}})
        end
      },
      ["tp"] = {
        find = function()
          return M.get_selection({query = {capture = "@parameter.outer"}})
        end
      },
      ["rp"] = {
        find = function()
          return M.get_selection({query = {capture = "@parameter.inner"}})
        end
      },
      ["tl"] = {
        find = function()
          return M.get_selection({query = {capture = "@loop.outer"}})
        end
      },
      ["rl"] = {
        find = function()
          return M.get_selection({query = {capture = "@loop.inner"}})
        end
      },
      ["ts"] = {
        find = function()
          return M.get_selection({query = {capture = "@scope"}})
        end
      },
      ["rs"] = {
        find = function()
          return M.get_selection({query = {capture = "@scope"}})
        end
      },
      ["tt"] = {
        find = function()
          return M.get_selection({query = {capture = "@tag.outer"}})
        end
      },
      ["rt"] = {
        find = function()
          return M.get_selection({query = {capture = "@tag.inner"}})
        end
      },
      ["i"] = {
        add = function()
          local input = M.get_input("Enter delimiter pair (left/right or tag): ")
          if not input then
            return
          end

          -- Check if it looks like a tag: <Tag> or just Tag
          local opening_tag = input:match("^<([^/>]+)>?$")
          if opening_tag then
            local tag_name = opening_tag:match("^([^%s>]+)")
            return {{"<" .. opening_tag .. ">"}, {"</" .. tag_name .. ">"}}
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
            [">"] = "<"
          }

          -- Mirror and reverse the input to create closing delimiter
          -- e.g., "<'{" → "}'>", "{`" → "`}"
          local right = ""
          for i = #input, 1, -1 do
            local char = input:sub(i, i)
            right = right .. (pairs[char] or char)
          end

          return {{input}, {right}}
        end
      }

      -- Note: Other surrounds (quotes, HTML tags, function calls) use plugin defaults
    },
    aliases = {
      -- Standard aliases (kept for clarity):
      ["a"] = ">", -- a → angle brackets
      ["b"] = ")", -- b → parentheses (round brackets)
      ["B"] = "}", -- B → braces (curly brackets)
      ["q"] = {'"', "'", "`"}, -- q → any quote
      ["s"] = {"}", "]", ")", ">", '"', "'", "`"} -- s → any surround

      -- CUSTOM: Removed default "r" = "]" because r=inner in our Graphite layout
    }
  },
  config = function(_, opts)
    -- Patch set_operator_marks to use bang (normal!) so Graphite key remaps
    -- don't corrupt the g@ motion used to find surround positions
    local buffer = require("nvim-surround.buffer")
    local orig = buffer.set_operator_marks
    buffer.set_operator_marks = function(motion)
      local curpos = buffer.get_curpos()
      local visual_marks = { buffer.get_mark("<"), buffer.get_mark(">") }
      buffer.del_marks({ "[", "]" })
      vim.go.operatorfunc = "v:lua.require'nvim-surround.utils'.NOOP"
      vim.cmd.normal({ args = { "g@" .. motion }, bang = true })
      buffer.adjust_mark("[")
      buffer.adjust_mark("]")
      buffer.set_curpos(curpos)
      buffer.set_mark("<", visual_marks[1])
      buffer.set_mark(">", visual_marks[2])
    end

    vim.keymap.set("x", "s", "<Plug>(nvim-surround-visual)", {desc = "Surround visual selection"})

    require("nvim-surround").setup(opts)

    -- which-key group descriptions
    require("which-key").add(
      {
        {"ys", group = "Add surround"},
        {"yS", group = "Add surround (newlines)"},
        {"ds", group = "Delete surround"},
        {"cs", group = "Change surround"},
        {"cS", group = "Change surround (newlines)"},
        {"s", mode = "x", group = "Surround"},
        {"gS", mode = "x", group = "Surround (newlines)"}
      }
    )

    -- Disable nvim-surround for non-modifiable and special buffers
    vim.api.nvim_create_autocmd(
      {"BufEnter", "BufWinEnter"},
      {
        pattern = "*",
        callback = function()
          local should_disable = false
          for _, cond in ipairs(disable_surround) do
            if cond() then should_disable = true; break end
          end
          if should_disable then
            for _, key in ipairs({"s", "S", "ys", "yss", "yS", "ySS", "ds", "cs", "cS"}) do
              pcall(vim.keymap.del, "v", key, {buffer = 0})
            end
            for _, key in ipairs({"ys", "yss", "yS", "ySS", "ds", "cs", "cS"}) do
              pcall(vim.keymap.del, "n", key, {buffer = 0})
            end
          end
        end
      }
    )
  end
}
