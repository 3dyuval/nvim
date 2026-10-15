{1 "madmaxieee/fff-snacks.nvim"
 :dependencies ["dmtrKovalenko/fff.nvim" "folke/snacks.nvim"]
 :keys [{1 :<leader>ff
         2 (fn [] ((. (require :fff-snacks) :find_files)))
         :desc "Find files (cwd)"}
        {1 "<C-f>"
         2 (fn []
             (let [file (vim.api.nvim_buf_get_name 0)
                   dir (if (not= file "")
                           (vim.fn.fnamemodify file ":p:h")
                           (vim.fn.getcwd))]
               ((. (require :fff-snacks) :find_files) {:cwd dir})))
         :desc "Find files (buffer dir)"}]
 :opts {}}
