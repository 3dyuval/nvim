;; Disable swap for snacks windows; disable swap/undo/backup under network mounts.
(vim.api.nvim_create_autocmd :FileType
  {:pattern [:snacks_win :snacks_picker :snacks_explorer]
   :callback (fn [] (set vim.opt_local.swapfile false))})

(vim.api.nvim_create_autocmd :BufReadPre
  {:pattern [(.. (vim.fn.expand "~") "/mnt/*")
             (.. (vim.fn.expand "~") "/.sshfs/*")]
   :callback (fn []
               (set vim.opt_local.swapfile false)
               (set vim.opt_local.undofile false)
               (set vim.opt_local.backup false)
               (set vim.opt_local.writebackup false))})

{}
