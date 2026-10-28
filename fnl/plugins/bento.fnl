(local menu-actions
  [[:open   :<CR> :DiagnosticVirtualTextHint]
   [:delete :<BS> :DiagnosticVirtualTextError]
   [:vsplit "|"   :DiagnosticVirtualTextInfo]
   [:split  :_    :DiagnosticVirtualTextInfo]
   [:lock   "*"   :DiagnosticVirtualTextWarn]])

[{1 "akinsho/bufferline.nvim" :enabled false}
 {1 "3dyuval/bento.nvim"
  :dev true
  :enabled true
  :lazy false
  :opts {:floating {:toggle_on_reexpand true ; re-pressing expand key closes the menu
                    :minimal_menu "dashed"} ; always-on minimal menu (dashed)
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
              (api.register_expand_key ";")
              (api.register_collapse_key :<Esc>)
              (each [_ [name key hl] (ipairs menu-actions)]
                (api.register_action name {:key key
                                           :action (. api.actions name)
                                           :hl hl}))
              (api.set_default_action :open)))}]
