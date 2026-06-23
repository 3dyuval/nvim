{1 "lewis6991/hover.nvim"
 :dev false
 :event :VeryLazy
 :dependencies ["3dyuval/colortweak.nvim"]
 :config
 (fn []
   (local tweak (require :colortweak.tweak))
   ((. (require :hover) :config)
    {:providers ["hover.providers.diagnostic"
                 "hover.providers.lsp"
                 "hover-mdn"
                 "hover.providers.fold_preview"
                 "hover.providers.man"
                 "hover.providers.highlight"]
     :preview_opts {:border :rounded}
     :preview_window false
     :title true})
   ;; HoverWindow bg from Normal at reduced lightness. HoverBorder: fg = a
   ;; highly saturated NormalFloat color (tweak.get returns it without applying),
   ;; bg = Normal's bg so the band blends in and only the line is colored.
   (tweak.hl {:HoverWindow ["Normal" {:l 0.9}]})
   (vim.api.nvim_set_hl 0 :HoverBorder
                        {:fg (. (tweak.get :NormalFloat {:l .5 :s 1.25}) :fg)
                         :bg (. (vim.api.nvim_get_hl 0 {:name :Normal}) :bg)})
   )}
