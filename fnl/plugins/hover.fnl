{1 "lewis6991/hover.nvim"
 :event :VeryLazy
 :config
 (fn []
   ((. (require :hover) :config)
    {:providers ["hover.providers.diagnostic"
                 "hover.providers.lsp"
                 "hover.providers.fold_preview"
                 "hover.providers.man"
                 "hover.providers.highlight"]
     :preview_opts {:border :single}
     :preview_window false
     :title true})
   ;; K = hover (set here at VeryLazy so it wins over keymaps-old's K mapping,
   ;; which loads earlier; that motion now lives on >). normal mode only.
   (vim.keymap.set :n :K (fn [] ((. (require :hover) :open)))
                   {:desc "Hover"})
   (vim.keymap.set :n :gH (fn [] ((. (require :hover) :select)))
                   {:desc "Hover (pick provider)"}))}
