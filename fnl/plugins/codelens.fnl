{1 "oribarilan/lensline.nvim"
 :event :LspAttach
 :dependencies ["3dyuval/colortweak.nvim"]
 :config
 (fn []
   ((. (require :colortweak.tweak) :hl)
    {:LensLine ["Comment" {:l 0.9}]
     :LensLineZero ["DiagnosticWarn" {:l 9}]
     :LensLineLow ["DiagnosticHint" {:l 0.9}]
     :LensLineHigh ["DiagnosticInfo" {:l 0.9}]
     :LensLineComplexity ["DiagnosticWarn" {:l 0.9}]})

   (local refs-provider
     {:name "references_with_warning"
      :enabled true
      :event ["LspAttach" "BufWritePost"]
      :handler
      (fn [bufnr func-info _provider-config callback]
        (let [utils (require :lensline.utils)]
          (utils.get_lsp_references
            bufnr func-info
            (fn [references]
              (if references
                  (let [count (length references)
                        [text hl] (if (= count 0)
                                      [(.. (utils.if_nerdfont_else "󰌸 " "") " No references")
                                       :LensLineZero]
                                      (= count 1)
                                      [(.. (utils.if_nerdfont_else "󰌷 " "") count " references")
                                       :LensLineLow]
                                      [(.. (utils.if_nerdfont_else "" "") count " references")
                                       :LensLineHigh])]
                    (callback {:line func-info.line :text text :highlight hl}))
                  (callback nil))))))})

   (local complexity-provider
     {:name "complexity_score"
      :enabled true
      :event ["BufWritePost" "TextChanged"]
      :handler
      (fn [bufnr func-info _provider-config callback]
        (let [utils (require :lensline.utils)
              lines (utils.get_function_lines bufnr func-info)]
          (if (or (not lines) (= (length lines) 0))
              (callback nil)
              (let [code (table.concat lines "\n")
                    patterns ["if%s" "elseif%s" "else%s" "for%s" "while%s" "repeat%s"
                              "and%s" "or%s" "switch" "case%s" "try" "catch" "finally"
                              "%?" "&&" "||"]]
                (var score 1)
                (each [_ pattern (ipairs patterns)]
                  (each [_ (code:gmatch pattern)]
                    (set score (+ score 1))))
                (let [[icon label hl]
                      (if (<= score 3) [(utils.if_nerdfont_else "󰔶 " "") "simple" :LensLineLow]
                          (<= score 8) [(utils.if_nerdfont_else "󰔷 " "") "moderate" :LensLine]
                          (<= score 15) [(utils.if_nerdfont_else "󰔸 " "") "complex" :LensLineHigh]
                          [(utils.if_nerdfont_else "󰀦 " "!") "very complex" :LensLineComplexity])]
                  (callback {:line func-info.line
                             :text (.. icon score " " label)
                             :highlight hl}))))))})

   (local style {:highlight "LensLine" :placement "inline" :prefix ""})

   ((. (require :lensline) :setup)
    {:profiles [{:name "default" :style style :providers [refs-provider complexity-provider]}
                {:name "complexity" :style style :providers [complexity-provider]}
                {:name "references" :style style :providers [refs-provider]}]}))}
