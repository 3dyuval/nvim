local M = {}
---@type user_options
M.opts = {
  keymaps = {
    insert = "<C-g>s",
    insert_line = "<C-g>S",
    normal = "ys",
    normal_cur = "yss",
    normal_line = "yS",
    normal_cur_line = "ySS",
    visual = "s",
    visual_line = "gS",
    delete = "xs",
    change = "ws",
    change_line = "cS",
  },
  surrounds = {
    ["("] = {
      add = { "( ", " )" },
      find = function()
        return M.get_selection({ motion = "a(" })
      end,
      delete = "^(. ?)().-( ?.)()$",
    },
    [")"] = {
      add = { "(", ")" },
      find = function()
        return M.get_selection({ motion = "a)" })
      end,
      delete = "^(.)().-(.)()$",
    },
    ["{"] = {
      add = { "{ ", " }" },
      find = function()
        return M.get_selection({ motion = "a{" })
      end,
      delete = "^(. ?)().-( ?.)()$",
    },
    ["}"] = {
      add = { "{", "}" },
      find = function()
        return M.get_selection({ motion = "a}" })
      end,
      delete = "^(.)().-(.)()$",
    },
    ["<"] = {
      add = { "< ", " >" },
      find = function()
        return M.get_selection({ motion = "a<" })
      end,
      delete = "^(. ?)().-( ?.)()$",
    },
    [">"] = {
      add = { "<", ">" },
      find = function()
        return M.get_selection({ motion = "a>" })
      end,
      delete = "^(.)().-(.)()$",
    },
    ["["] = {
      add = function()
        -- Check if we're in an Angular HTML file
        if vim.bo.filetype == "htmlangular" then
          return { "[", "]" }
        else
          return { "[ ", " ]" }
        end
      end,
      find = function()
        return M.get_selection({ motion = "a[" })
      end,
      delete = "^(. ?)().-( ?.)()$",
    },
    ["]"] = {
      add = { "[", "]" },
      find = function()
        return M.get_selection({ motion = "a]" })
      end,
      delete = "^(.)().-(.)()$",
    },
    ["'"] = {
      add = { "'", "'" },
      find = function()
        return M.get_selection({ motion = "a'" })
      end,
      delete = "^(.)().-(.)()$",
    },
    ['"'] = {
      add = { '"', '"' },
      find = function()
        return M.get_selection({ motion = 'a"' })
      end,
      delete = "^(.)().-(.)()$",
    },
    ["`"] = {
      add = { "`", "`" },
      find = function()
        return M.get_selection({ motion = "a`" })
      end,
      delete = "^(.)().-(.)()$",
    },
    ["i"] = {
      add = function()
        local left_delimiter = M.get_input("Enter the left delimiter: ")
        local right_delimiter = left_delimiter and M.get_input("Enter the right delimiter: ")
        if right_delimiter then
          return { { left_delimiter }, { right_delimiter } }
        end
      end,
      find = function() end,
      delete = function() end,
    },
    ["t"] = {
      add = function()
        local user_input = M.get_input("Enter the HTML tag: ")
        if user_input then
          local element = user_input:match("^<?([^%s>]*)")
          local attributes = user_input:match("^<?[^%s>]*%s+(.-)>?$")

          local open = attributes and element .. " " .. attributes or element
          local close = element

          return { { "<" .. open .. ">" }, { "</" .. close .. ">" } }
        end
      end,
      find = function()
        return M.get_selection({ motion = "at" })
      end,
      delete = "^(%b<>)().-(%b<>)()$",
      change = {
        target = "^<([^%s<>]*)().-([^/]*)()>$",
        replacement = function()
          local user_input = M.get_input("Enter the HTML tag: ")
          if user_input then
            local element = user_input:match("^<?([^%s>]*)")
            local attributes = user_input:match("^<?[^%s>]*%s+(.-)>?$")

            local open = attributes and element .. " " .. attributes or element
            local close = element

            return { { open }, { close } }
          end
        end,
      },
    },
    ["T"] = {
      add = function()
        local user_input = M.get_input("Enter the HTML tag: ")
        if user_input then
          local element = user_input:match("^<?([^%s>]*)")
          local attributes = user_input:match("^<?[^%s>]*%s+(.-)>?$")

          local open = attributes and element .. " " .. attributes or element
          local close = element

          return { { "<" .. open .. ">" }, { "</" .. close .. ">" } }
        end
      end,
      find = function()
        return M.get_selection({ motion = "at" })
      end,
      delete = "^(%b<>)().-(%b<>)()$",
      change = {
        target = "^<([^>]*)().-([^/]*)()>$",
        replacement = function()
          local user_input = M.get_input("Enter the HTML tag: ")
          if user_input then
            local element = user_input:match("^<?([^%s>]*)")
            local attributes = user_input:match("^<?[^%s>]*%s+(.-)>?$")

            local open = attributes and element .. " " .. attributes or element
            local close = element

            return { { open }, { close } }
          end
        end,
      },
    },
    -- Markdown-specific surrounds
    ["*"] = {
      add = { "**", "**" },
      find = function()
        return M.get_selection({ pattern = "%*%*.-*%*" })
      end,
      delete = "^(%*%*)().-()(%*%*)$",
    },
    ["_"] = {
      add = { "_", "_" },
      find = function()
        return M.get_selection({ pattern = "_.-_" })
      end,
      delete = "^(_)().-()(_)$",
    },
    ["~"] = {
      add = { "~~", "~~" },
      find = function()
        return M.get_selection({ pattern = "~~.-~~" })
      end,
      delete = "^(~~)().-()(~~)$",
    },
    invalid_key_behavior = {
      add = function(char)
        if not char or char:find("%c") then
          return nil
        end
        return { { char }, { char } }
      end,
      find = function(char)
        if not char or char:find("%c") then
          return nil
        end
        return M.get_selection({
          pattern = vim.pesc(char) .. ".-" .. vim.pesc(char),
        })
      end,
      delete = function(char)
        if not char then
          return nil
        end
        return M.get_selections({
          char = char,
          pattern = "^(.)().-(.)()$",
        })
      end,
    },
  },
  aliases = {
    ["a"] = ">",
    ["b"] = ")",
    ["B"] = "}",
    ["q"] = { '"', "'", "`" },
    ["s"] = { "}", "]", ")", ">", '"', "'", "`" },
  },
  highlight = {
    duration = 0,
  },
  move_cursor = "begin",
  indent_lines = function(start, stop)
    local b = vim.bo
    if
      start < stop
      and (b.equalprg ~= "" or b.indentexpr ~= "" or b.cindent or b.smartindent or b.lisp)
    then
      vim.cmd(string.format("silent normal! %dG=%dG", start, stop))
      require("nvim-surround.cache").set_callback("")
    end
  end,
}

M.get_input = function(prompt)
  local input = require("nvim-surround.input")
  return input.get_input(prompt)
end

M.get_selection = function(args)
  if args.char then
    return M.get_find(args.char)(args.char)
  elseif args.motion then
    return require("nvim-surround.motions").get_selection(args.motion)
  elseif args.node then
    return require("nvim-surround.treesitter").get_selection(args.node)
  elseif args.pattern then
    return require("nvim-surround.patterns").get_selection(args.pattern)
  elseif args.query then
    return require("nvim-surround.queries").get_selection(args.query.capture, args.query.type)
  else
    vim.notify(
      "Invalid key provided for `:h nvim-surround.config.get_selection()`.",
      vim.log.levels.ERROR
    )
  end
end

M.get_selections = function(args)
  local selection = M.get_selection({ char = args.char })
  if not selection then
    return nil
  end
  if args.pattern then
    return require("nvim-surround.patterns").get_selections(selection, args.pattern)
  else
    vim.notify(
      "Invalid key provided for `:h nvim-surround.config.get_selections()`.",
      vim.log.levels.ERROR
    )
  end
end

return M
