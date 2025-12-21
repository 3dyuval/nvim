-- Surround configuration for Graphite keyboard layout
-- Consolidates: plugin spec, nvim-surround config, and explicit keymaps
return {
  "kylechui/nvim-surround",
  version = "^3.0.0",
  event = "VeryLazy",
  opts = {
    keymaps = {
      -- Keep nvim-surround DEFAULTS (ds, cs, ys, yss, S)
      -- Then add Graphite translations via explicit keymaps below
      insert = "<C-g>s",
      insert_line = "<C-g>S",
      normal = "ys",
      normal_cur = "yss",
      normal_line = "yS",
      normal_cur_line = "ySS",

      visual = "S", -- Default capital S
      visual_line = "gS",
      delete = "ds", -- Default
      change = "cs", -- Default
      change_line = "cS",
    },

    surrounds = {
      -- CUSTOM SPACING BEHAVIOR (reversed from defaults):
      -- Opening brackets = non-spaced, Closing brackets = spaced
      -- This allows: ysw( → (text), ysw) → ( text )

      ["("] = { add = { "(", ")" } }, -- Custom: non-spaced (default was spaced)
      [")"] = { add = { "( ", " )" } }, -- Custom: spaced (default was non-spaced)
      ["{"] = { add = { "{", "}" } }, -- Custom: non-spaced (default was spaced)
      ["}"] = { add = { "{ ", " }" } }, -- Custom: spaced (default was non-spaced)
      ["<"] = { add = { "< ", " >" } },
      [">"] = { add = { "<", ">" } },
      ["["] = { add = { "[", "]" } }, -- Custom: always non-spaced (default was spaced)
      ["]"] = { add = { "[ ", " ]" } }, -- Custom: spaced (default was non-spaced)

      -- MARKDOWN ADDITIONS (not in defaults):
      ["*"] = { add = { "**", "**" } }, -- Bold: **text**
      ["_"] = { add = { "_", "_" } }, -- Italic: _text_
      ["~"] = { add = { "~", "~" } }, -- Strikethrough: ~text~
      ["`"] = {
        add = function()
          local lang = require("nvim-surround.config").get_input("Language: ")
          -- Schedule cursor move to inside the fence and enter insert mode
          vim.schedule(function()
            local row = vim.api.nvim_win_get_cursor(0)[1]
            vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
            vim.cmd("startinsert")
          end)
          -- Each array element is a line; empty string = blank line
          return { { "```" .. (lang or ""), "" }, { "", "```" } }
        end,
        find = function()
          local config = require("nvim-surround.config")
          return config.get_selection({ motion = "a`" })
        end,
        delete = function()
          local config = require("nvim-surround.config")
          return config.get_selections({
            char = "`",
            pattern = "^(```.-\n)().*(```\n?)()$",
          })
        end,
      },

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
  },

  config = function(_, opts)
    require("nvim-surround").setup(opts)

    -- Graphite layout: Direct mappings to <Plug> functions (bypasses global remaps)
    -- Set AFTER setup() so <Plug> mappings exist and take precedence over global w/x/c
    vim.keymap.set("n", "ws", "<Plug>(nvim-surround-change)", { desc = "Change surround" })
    vim.keymap.set("n", "xs", "<Plug>(nvim-surround-delete)", { desc = "Delete surround", nowait = true })
    vim.keymap.set("n", "xst", function()
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("dst", true, false, true), "m", false)
    end, { desc = "Delete surrounding tag", nowait = true })
    vim.keymap.set("x", "s", "<Plug>(nvim-surround-visual)", { desc = "Surround visual selection" })

    -- ys/yss don't need explicit mapping (no global 'y' → something conflict in normal mode)

    -- Disable nvim-surround for non-modifiable and special buffers
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
      pattern = "*",
      callback = function()
        local bufname = vim.api.nvim_buf_get_name(0)
        local should_disable = not vim.bo.modifiable
          or vim.bo.buftype ~= ""
          or bufname:match("^diffview://")
          or (bufname:match("^git://") and not bufname:match("^neogit://"))
          or bufname == ""

        if should_disable then
          -- Unmap nvim-surround keymaps for this buffer
          local keymaps_to_disable = { "s", "S", "ys", "yss", "yS", "ySS", "xs", "ws", "cS" }
          for _, key in ipairs(keymaps_to_disable) do
            pcall(vim.keymap.del, "v", key, { buffer = 0 })
            pcall(vim.keymap.del, "n", key, { buffer = 0 })
          end
        end
      end,
    })
  end,
}
