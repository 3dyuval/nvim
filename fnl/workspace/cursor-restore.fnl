;; Restore cursor to its last position when reopening a file.
(vim.api.nvim_create_autocmd :BufReadPost
  {:callback (fn [args]
               (local mark (vim.api.nvim_buf_get_mark args.buf "\""))
               (local lines (vim.api.nvim_buf_line_count args.buf))
               (when (and (> (. mark 1) 0) (<= (. mark 1) lines))
                 (vim.api.nvim_buf_call args.buf #(vim.cmd "normal! g`\"zz"))))})

{}
