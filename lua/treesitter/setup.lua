-- [nfnl] fnl/treesitter/setup.fnl
local function setup()
  vim.filetype.add({extension = {ab = "amber", heex = "heex", kcl = "kcl"}})
  local function _1_(ev)
    local lang = (vim.treesitter.language.get_lang(ev.match) or ev.match)
    if (lang and (lang ~= "")) then
      pcall(vim.treesitter.start, ev.buf, lang)
      vim.bo[ev.buf]["indentexpr"] = "v:lua.vim.treesitter.foldexpr()"
      vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
      return nil
    else
      return nil
    end
  end
  return vim.api.nvim_create_autocmd("FileType", {callback = _1_})
end
return {setup = setup}
