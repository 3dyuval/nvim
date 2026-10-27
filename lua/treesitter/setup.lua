-- [nfnl] fnl/treesitter/setup.fnl
_G.vue_indent = function(lnum)
  local lnum0 = (lnum or vim.v.lnum)
  local l = (lnum0 - 1)
  local found = nil
  while ((l > 0) and not found) do
    do
      local s = vim.fn.getline(l)
      if s:find("</script") then
        found = "out"
      elseif s:find("<script") then
        found = "in"
      else
      end
    end
    l = (l - 1)
  end
  if (found ~= "in") then
    return vim.fn.HtmlIndent()
  else
    local prev = vim.fn.prevnonblank((lnum0 - 1))
    if (prev == 0) then
      return 0
    else
      local sw = vim.fn.shiftwidth()
      local ind = vim.fn.indent(prev)
      if vim.fn.getline(prev):match("[%({%[]%s*$") then
        ind = (ind + sw)
      else
      end
      if vim.fn.getline(lnum0):match("^%s*[%)}%]]") then
        ind = (ind - sw)
      else
      end
      return ind
    end
  end
end
local function setup()
  vim.filetype.add({extension = {ab = "amber", heex = "heex", kcl = "kcl"}})
  local function _6_(ev)
    local lang = (vim.treesitter.language.get_lang(ev.match) or ev.match)
    if (lang and (lang ~= "")) then
      pcall(vim.treesitter.start, ev.buf, lang)
      vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
      if (ev.match == "vue") then
        local function _7_()
          vim.bo[ev.buf]["indentexpr"] = "v:lua.vue_indent()"
          return nil
        end
        return vim.schedule(_7_)
      else
        return nil
      end
    else
      return nil
    end
  end
  return vim.api.nvim_create_autocmd("FileType", {callback = _6_})
end
return {setup = setup}
