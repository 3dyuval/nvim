;; onoma.nvim — symbol picker via snacks. Lazy-loaded on the :Onoma command
;; (onoma has no native command, so we register our own). The grs keymap is
;; declared on the spec so pressing it also triggers the load. grs overrides
;; the native/LSP document-symbols map (that binding was removed in lsp/setup).
{1 "ryanmab/onoma.nvim"
 :enabled true
 :version "*"
 :cmd "Onoma"
 :keys [{1 :grs 2 (fn [] (Snacks.picker.get_symbols {:layout :bottom})) :mode [:n]
         :desc :Symbols :silent true}]
 :config (fn []
           ((. (require :onoma) :setup) {:picker [:snacks]})
           (vim.api.nvim_create_user_command
             :Onoma
             (fn [] (Snacks.picker.get_symbols {:layout :bottom}))
             {:desc "Onoma symbols picker"}))}
