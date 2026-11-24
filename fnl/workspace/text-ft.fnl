;; Text-like filetypes: wrap on, spell off by default (toggle with <leader>us).
(vim.api.nvim_create_autocmd :FileType
  {:pattern [:text :plaintex :typst :gitcommit :markdown]
   :callback (fn []
               (set vim.opt_local.wrap true)
               (set vim.opt_local.spell false))})

{}
