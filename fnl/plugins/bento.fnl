;; bento.nvim — buffer manager rendered as a tabline (the open-buffers bar).
;; Replaces bufferline.nvim (disabled below). Main key ";" opens the menu.
[{1 "akinsho/bufferline.nvim" :enabled false}
 {1 "serhez/bento.nvim"
  :enabled true
  :lazy false
  :opts {:main_keymap ";"
         :ui {:mode :tabline
              :tabline {:separator_symbol " "}}
         :highlights {:current :Bold
                      :active :Normal
                      :inactive :Comment
                      :modified :DiagnosticWarn
                      :label_minimal :Comment
                      :window_bg :Normal
                      :separator :Comment}}}]
