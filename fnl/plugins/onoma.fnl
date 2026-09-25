;; onoma.nvim — symbol picker via snacks. Lazy-loaded on the :Onoma command
;; (onoma has no native command, so we register our own). The <M-f> keymap is
;; declared on the spec so pressing it also triggers the load.
{1 "ryanmab/onoma.nvim"
 :enabled true
 :version "*"
 :cmd "Onoma"
 :keys [{1 :<leader>sf 2 (fn [] (Snacks.picker.get_symbols)) :mode [:n :v :x]
         :desc :Symbols :silent true}]
 :config (fn []
           ((. (require :onoma) :setup) {:picker [:snacks]})
           (vim.api.nvim_create_user_command
             :Onoma
             (fn [] (Snacks.picker.get_symbols))
             {:desc "Onoma symbols picker"}))}
