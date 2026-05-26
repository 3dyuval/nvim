return function()
  vim.filetype.add({ extension = { ab = "amber", heex = "heex", kcl = "kcl" } })

  vim.api.nvim_create_autocmd("FileType", {
    callback = function(ev)
      local lang = vim.treesitter.language.get_lang(ev.match) or ev.match
      if not lang or lang == "" then
        return
      end

      pcall(vim.treesitter.start, ev.buf, lang)

      vim.bo[ev.buf].indentexpr = "v:lua.vim.treesitter.foldexpr()"
      vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    end,
  })
end
