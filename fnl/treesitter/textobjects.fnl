;; Single source of truth for all treesitter textobject bindings.
;; Each capture owns its keys — move, select, swap, and hud hints
;; are all derived from this table via collect/hud-hints below.

(local bindings
  {"@function.outer"  {:move-next      ["]f" "]c"]
                        :move-prev      ["[f" "[c"]
                        :move-end-next  ["]M"]
                        :move-end-prev  ["[M"]
                        :select         :tf
                        :swap-next      "]F"
                        :swap-prev      "[F"}
   "@function.inner"  {:select :rf}
   "@class.outer"     {:move-next ["]C"]
                        :move-prev ["[C"]}
   "@parameter.inner" {:move-next ["]p"]
                        :move-prev ["[p"]
                        :swap-next "]P"
                        :swap-prev "[A"}
   "@loop.*"          {:move-next ["]l"] :move-prev ["[l"]}
   "@scope"           {:move-next ["]s"] :move-prev ["[s"] :select :rs}
   "@fold"            {:move-next ["]u"] :move-prev ["[u"]}
   "@tag.inner"       {:select :rt}
   "@tag.outer"       {:select :tt}
   "@jsx_self_closing_element" {:select :te}})

(fn build-map [field]
  (local t {})
  (each [capture opts (pairs bindings)]
    (local v (. opts field))
    (when v
      (if (= (type v) :string)
        (tset t v capture)
        (each [_ k (ipairs v)]
          (tset t k capture)))))
  t)

(fn hud-hints []
  (local hints {})
  (each [capture opts (pairs bindings)]
    (local k (. opts :select))
    (when k
      (tset hints (.. "treesitter:" capture) k)))
  hints)

(fn setup []
  (let [TS (require :nvim-treesitter-textobjects)]
    (TS.setup
      {:move   {:enable    true
                :set_jumps true
                :goto_next_start     (build-map :move-next)
                :goto_next_end       (build-map :move-end-next)
                :goto_previous_start (build-map :move-prev)
                :goto_previous_end   (build-map :move-end-prev)}
       :select {:enable true
                :keymaps (build-map :select)}
       :swap   {:enable true
                :swap_next     (build-map :swap-next)
                :swap_previous (build-map :swap-prev)}})))

{: setup : hud-hints}
