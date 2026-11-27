{1 "Isrothy/neominimap.nvim"
 :version "v3.*.*"
 :lazy false
 :keys [{1 :<leader>uM 2 "<cmd>Neominimap Toggle<cr>" :desc "Toggle minimap"}]
 :init (fn []
         (set vim.opt.wrap false)
         (set vim.opt.sidescrolloff 36)
         (set vim.g.neominimap {:auto_enable true
                                :layout "float"
                                :float {:minimap_width 10
                                        :max_minimap_height 12
                                        :window_border "rounded"
                                        :margin {:right 1 :top 1}}}))}
