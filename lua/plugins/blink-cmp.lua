return {
  "saghen/blink.cmp",
  dependencies = {
    "L3MON4D3/LuaSnip",
  },
  opts = {
    snippets = {
      expand = function(snippet)
        require("luasnip").lsp_expand(snippet)
      end,
      active = function(filter)
        if filter and filter.direction then
          return require("luasnip").jumpable(filter.direction)
        end
        return require("luasnip").in_snippet()
      end,
      jump = function(direction)
        require("luasnip").jump(direction)
      end,
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
    completion = {
      accept = {
        auto_brackets = {
          enabled = true,
          default_brackets = { "(", ")" },
          kind_resolution = {
            enabled = true,
            blocked_filetypes = { "typescriptreact", "javascriptreact", "typescript", "javascript" },
          },
          semantic_token_resolution = {
            enabled = true,
            blocked_filetypes = { "typescriptreact", "javascriptreact", "typescript", "javascript" },
            timeout_ms = 400,
          },
        },
      },
    },
    keymap = {
      preset = "default",
      ["<Tab>"] = {
        function(cmp)
          -- If completion menu is visible, select next item
          if cmp.is_visible() then
            return cmp.select_next()
          -- If we're in a snippet, jump forward
          elseif cmp.is_in_snippet() then
            return cmp.snippet_forward()
          -- Otherwise, insert actual tab/spaces
          else
            -- Insert spaces based on shiftwidth
            local spaces = string.rep(" ", vim.bo.shiftwidth)
            vim.api.nvim_put({spaces}, "c", true, true)
            return true
          end
        end,
        "fallback",
      },
      ["<S-Tab>"] = {
        function(cmp)
          if cmp.is_visible() then
            return cmp.select_prev()
          elseif cmp.is_in_snippet() then
            return cmp.snippet_backward()
          else
            return false
          end
        end,
        "fallback",
      },
      ["<CR>"] = {
        "accept",
        "fallback",
      },
    },
  },
}
