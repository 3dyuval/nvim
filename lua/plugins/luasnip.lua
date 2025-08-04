return {
  "L3MON4D3/LuaSnip",
  version = "v2.*",
  build = "make install_jsregexp",
  dependencies = {
    "rafamadriz/friendly-snippets",
  },
  event = "InsertEnter",
  config = function()
    local ls = require("luasnip")
    
    -- Load friendly-snippets
    require("luasnip.loaders.from_vscode").lazy_load()
    
    -- Basic setup
    ls.setup({
      history = true,
      delete_check_events = "TextChanged",
      update_events = "TextChanged,TextChangedI",
    })
    
    -- Custom snippets
    local s = ls.snippet
    local t = ls.text_node
    local i = ls.insert_node
    local f = ls.function_node
    
    -- React Functional Component snippet
    ls.add_snippets("typescriptreact", {
      s("reactf", {
        t({"import React from 'react'", "", ""}),
        t("interface "),
        f(function()
          local filename = vim.fn.expand("%:t:r")
          return filename:gsub("^%l", string.upper) .. "Props"
        end),
        t({" {", "  "}),
        i(1, "// Add props here"),
        t({"", "}", "", ""}),
        t("export const "),
        f(function()
          local filename = vim.fn.expand("%:t:r")
          return filename:gsub("^%l", string.upper)
        end),
        t(": React.FC<"),
        f(function()
          local filename = vim.fn.expand("%:t:r")
          return filename:gsub("^%l", string.upper) .. "Props"
        end),
        t({"> = () => {", "  return (", "    <div>", "      "}),
        i(2, "Component content"),
        t({"", "    </div>", "  )", "}"})
      })
    })
    
    -- Also add for regular React files
    ls.add_snippets("javascriptreact", {
      s("reactf", {
        t({"import React from 'react'", "", ""}),
        t("export const "),
        f(function()
          local filename = vim.fn.expand("%:t:r")
          return filename:gsub("^%l", string.upper)
        end),
        t({" = () => {", "  return (", "    <div>", "      "}),
        i(1, "Component content"),
        t({"", "    </div>", "  )", "}"})
      })
    })
    
    -- Key mappings for manual expansion and navigation
    vim.keymap.set("i", "<C-l>", function() 
      if ls.expandable() then
        ls.expand()
      end
    end, {silent = true, desc = "Expand snippet"})
    
    vim.keymap.set({"i", "s"}, "<C-j>", function() 
      if ls.jumpable(1) then
        ls.jump(1)
      end
    end, {silent = true, desc = "Jump to next snippet placeholder"})
    
    vim.keymap.set({"i", "s"}, "<C-k>", function() 
      if ls.jumpable(-1) then
        ls.jump(-1)
      end
    end, {silent = true, desc = "Jump to previous snippet placeholder"})
  end,
}