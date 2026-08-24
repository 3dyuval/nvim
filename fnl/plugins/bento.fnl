;; SPEC.md Layer 4 — the buffer line whose visibility (showtabline, toggled by
;; <C-;>, P1) gates <C-PageUp/Down> buffer-vs-tab paging (P2). Replaces
;; bufferline.nvim (disabled below).
;;
;; UPSTREAM BUG (serhez/bento.nvim):
;;   Title: main_keymap emits "No buffers to display" INFO toast instead of
;;          silently no-op'ing when no buffers are open
;;   Repro: press main_keymap (";") on an empty dashboard / cwd with no listed
;;          buffers. toggle_menu -> #marks == 0 -> vim.notify(...) in ui.lua.
;;   Expected: silent no-op when there's nothing to display.
;;   Workaround: TODO (guard the ";" keymap to only invoke bento when a real
;;               listed buffer exists).
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
