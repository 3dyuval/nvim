;; SPEC.md Layer 4 — the buffer line whose visibility (showtabline, toggled by
;; <C-;>, P1). Replaces bufferline.nvim (disabled below).
;;
;; bento v2 BREAKING CHANGE: setup() no longer registers any keymaps/actions
;; (v1 did, via `main_keymap` + a default action set). A carried-over v1 config
;; loads without error but shows no menu and answers no keys — which is why `;`
;; stopped working. We re-register the v1 defaults explicitly through bento.api.

;; Menu actions (label-local keys inside the expanded menu): name, key, highlight.
;; Registered in a loop below — the declarative register pattern.
(local menu-actions
  [[:open   :<CR> :DiagnosticVirtualTextHint]
   [:delete :<BS> :DiagnosticVirtualTextError]
   [:vsplit "|"   :DiagnosticVirtualTextInfo]
   [:split  :_    :DiagnosticVirtualTextInfo]
   [:lock   "*"   :DiagnosticVirtualTextWarn]])

[{1 "akinsho/bufferline.nvim" :enabled false}
 {1 "serhez/bento.nvim"
  :enabled true
  :lazy false
  :opts {:ui {:mode :tabline
              :tabline {:separator_symbol " "}}
         :highlights {:current :Bold
                      :active :Normal
                      :inactive :Comment
                      :modified :DiagnosticWarn
                      :label_minimal :Comment
                      :window_bg :Normal
                      :separator :Comment}}
  :config (fn [_ opts]
            ((. (require :bento) :setup) opts)
            (let [api (require :bento.api)]
              ;; `;` opens the menu and labels the last-accessed buffer
              ;; (README pro-tip: same key = fast switch-to-last-buffer).
              (api.register_expand_key ";")
              (api.register_last_buffer_key ";")
              (api.register_collapse_key :<Esc>)
              (api.register_prev_page_key "[")
              (api.register_next_page_key "]")
              (each [_ [name key hl] (ipairs menu-actions)]
                (api.register_action name {:key key
                                           :action (. api.actions name)
                                           :hl hl}))
              (api.set_default_action :open)))}]
