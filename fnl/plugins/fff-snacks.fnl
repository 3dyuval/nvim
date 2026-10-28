{1 "madmaxieee/fff-snacks.nvim"
 :dependencies ["dmtrKovalenko/fff.nvim" "folke/snacks.nvim"]
 :keys [{1 :<leader>ff
         2 (fn [] ((. (require :fff-snacks) :find_files)))
         :desc "Find files (cwd)"}
        {1 "<C-f>"
         2 (fn []
             ;; git repo root of the current buffer, else its dir, else cwd.
             ;; fff indexes from base_path (fixed at setup), so passing :cwd is
             ;; not enough — reindex the Rust core at the root first.
             (let [file (vim.api.nvim_buf_get_name 0)
                   buf-dir (if (not= file "")
                               (vim.fn.fnamemodify file ":p:h")
                               (vim.fn.getcwd))
                   root (or (Snacks.git.get_root buf-dir) buf-dir)]
               ((. (require :fff) :change_indexing_directory) root)
               ((. (require :fff-snacks) :find_files) {:cwd root})))
         :desc "Find files (git root)"}]
 ;; setup() does tbl_deep_extend on opts.find_files / opts.live_grep, so an
 ;; empty {} crashes on the nil sub-keys — pass the sub-tables explicitly.
 :opts {:find_files {} :live_grep {}}}
