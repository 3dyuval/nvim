;; Remove kitty window padding while nvim is focused; restore it on exit.
(vim.defer_fn
  (fn []
    (when (and vim.env.KITTY_WINDOW_ID vim.env.KITTY_LISTEN_ON)
      (vim.fn.system (string.format "kitten @ --to %s set-spacing --match id:%s padding=0"
                                    vim.env.KITTY_LISTEN_ON
                                    vim.env.KITTY_WINDOW_ID))))
  100)

(vim.api.nvim_create_autocmd :VimLeavePre
  {:callback (fn []
               (when (and vim.env.KITTY_WINDOW_ID vim.env.KITTY_LISTEN_ON)
                 (vim.fn.system (string.format "kitten @ --to %s set-spacing --match id:%s padding=12"
                                               vim.env.KITTY_LISTEN_ON
                                               vim.env.KITTY_WINDOW_ID))))})

{}
