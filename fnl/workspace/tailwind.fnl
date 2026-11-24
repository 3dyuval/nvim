;; Auto-start the Tailwind CSS LSP when a tailwind config is present.
(vim.api.nvim_create_autocmd [:BufEnter :BufWinEnter]
  {:pattern ["*.ts" "*.tsx" "*.js" "*.jsx"]
   :callback (fn []
               (when (not vim.b.tailwind_checked)
                 (set vim.b.tailwind_checked true)
                 (var found false)
                 (each [_ cfg (ipairs [:tailwind.config.js
                                       :tailwind.config.ts
                                       :tailwind.config.cjs
                                       :tailwind.config.mjs])
                        :until found]
                   (when (= (vim.fn.filereadable cfg) 1)
                     (vim.defer_fn #(vim.cmd "LspStart tailwindcss") 200)
                     (set found true)))))})

{}
