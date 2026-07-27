{1 
 "ryanmab/onoma.nvim" 
 :version "*"
 :event :VeryLazy
 :config (fn [] ((. (require :onoma) :setup)   {:picker [:snacks]})
            (vim.keymap.set [:n :v :x] :ss Snacks.picker.get_symbols
           {:desc :Symbols  :silent true })
            )

}
