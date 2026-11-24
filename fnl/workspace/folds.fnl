;; Keep foldlevel at 99 (UFO manages actual folding), except in gitcommit.
(vim.api.nvim_create_autocmd [:BufWinEnter :WinEnter :TabEnter]
  {:callback (fn []
               (vim.defer_fn (fn []
                               (when (and (< vim.wo.foldlevel 99)
                                          (not= vim.bo.filetype :gitcommit))
                                 (set vim.wo.foldlevel 99)))
                             100))})

{}
