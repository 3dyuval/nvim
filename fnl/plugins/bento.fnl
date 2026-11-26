(local menu-actions
  [[:open   :<CR> :DiagnosticVirtualTextHint]
    [:delete :<BS> :DiagnosticVirtualTextError]
    [:vsplit "|"   :DiagnosticVirtualTextInfo]
    [:split  :_    :DiagnosticVirtualTextInfo]
    [:lock   "*"   :DiagnosticVirtualTextWarn]])

[{1 "serhez/bento.nvim" :enabled true
  :dev false
  :lazy false
  :opts {:lock_char "🔒"
         :max_open_buffers nil
         :buffer_deletion_metric "frecency_access"
         :buffer_notify_on_delete true
         :ordering_metric "access"
         :locked_first false
         :map_last_accessed false
         :ui {:mode "floating" ; "floating" | "tabline"
              :floating {:position "middle-right"
                         :offset_x 0
                         :offset_y 0
                         :dash_char "─"
                         :border "none"
                         :label_padding 1
                         :minimal_menu nil ; nil | "dashed" | "filename" | "full"
                         :max_rendered_buffers nil} ; nil = auto-paginate on screen height
              :tabline {:left_page_symbol "❮"
                        :right_page_symbol "❯"
                        :separator_symbol "│"}}
         :highlights {:current :Bold
                      :active :Normal
                      :inactive :Comment
                      :modified :DiagnosticWarn
                      :inactive_dash :Comment
                      :previous :Search
                      :label :DiagnosticVirtualTextHint
                      :label_minimal :Visual
                      :window_bg :BentoNormal
                      :page_indicator :Comment
                      :separator :Normal}}
  :config (fn [_ opts]
            ((. (require :bento) :setup) opts)
            (let [api (require :bento.api)]
              (api.register_expand_key "<C-;>")
              (api.register_last_buffer_key "<C-;>")
              (api.register_collapse_key "<Esc>")
              (api.register_prev_page_key "[")
              (api.register_next_page_key "]")
              (each [_ [name key hl] (ipairs menu-actions)]
                (api.register_action name {:key key
                                           :action (. api.actions name)
                                           :hl hl}))
              (api.set_default_action :open)))}]
