-- [nfnl] fnl/lsp/vue-symbols.fnl
local query_src = "(lexical_declaration (variable_declarator name: (identifier) @name))\n   (function_declaration name: (identifier) @name)\n   (class_declaration name: (type_identifier) @name)"
local function gather_symbols(buf)
  local ok, parser = pcall(vim.treesitter.get_parser, buf)
  local items = {}
  if (ok and parser) then
    parser:parse(true)
    for lang, child in pairs(parser:children()) do
      if ((lang == "typescript") or (lang == "tsx") or (lang == "javascript")) then
        local qok, query = pcall(vim.treesitter.query.parse, lang, query_src)
        if qok then
          for _, tree in ipairs(child:trees()) do
            for _0, node in query:iter_captures(tree:root(), buf, 0, -1) do
              local srow, scol = node:range()
              table.insert(items, {text = vim.treesitter.get_node_text(node, buf), buf = buf, pos = {(srow + 1), scol}})
            end
          end
        else
        end
      else
      end
    end
  else
  end
  return items
end
local function pick(layout)
  local items = gather_symbols(vim.api.nvim_get_current_buf())
  return require("snacks").picker.pick({items = items, format = "text", layout = (layout or "bottom"), title = "Vue script symbols"})
end
return {symbols = gather_symbols, pick = pick}
