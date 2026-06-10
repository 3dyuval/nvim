(fn setup []
  (vim.filetype.add {:extension {:ab :amber :heex :heex :kcl :kcl}})
  (vim.api.nvim_create_autocmd :FileType
    {:callback
     (fn [ev]
       (local lang (or (vim.treesitter.language.get_lang ev.match) ev.match))
       (when (and lang (not= lang ""))
         (pcall vim.treesitter.start ev.buf lang)
         (set vim.wo.foldexpr "v:lua.vim.treesitter.foldexpr()")))}))

{: setup}
