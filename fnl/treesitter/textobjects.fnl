;; Single source of truth for all treesitter textobject bindings.
;; Each capture owns its keys — move, select, swap, and hud hints
;; are all derived from this table via the binders below.
;;
;; nvim-treesitter-textobjects `main` branch: setup() only takes light
;; config; every select/move/swap key must be bound manually via
;; vim.keymap.set calling the module functions. (The old `master`
;; setup({select={keymaps=...}}) form is silently ignored here.)

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
   "@block.inner"     {:select :rb}
   "@block.outer"     {:select :tb}
   "@jsx_self_closing_element" {:select :te}})

;; Query group per capture. Everything lives in textobjects.scm except
;; folds, which the plugin reads from folds.scm.
(fn query-group [capture]
  (if (capture:match "fold") :folds :textobjects))

;; A glob capture like "@loop.*" expands to its .inner/.outer variants
;; (move accepts a list of queries; select/swap take a single query).
(fn expand-query [capture]
  (if (capture:match "%*$")
      [(capture:gsub "%*" "inner") (capture:gsub "%*" "outer")]
      capture))

;; Normalize a binding value (string or list) into a list of keys.
(fn as-keys [v]
  (if (= (type v) :string) [v] v))

(fn map-select [keys capture]
  (let [select (require :nvim-treesitter-textobjects.select)
        query (expand-query capture)
        group (query-group capture)]
    (each [_ k (ipairs (as-keys keys))]
      (vim.keymap.set [:x :o] k
        #(select.select_textobject query group)
        {:desc (.. "Select " capture)}))))

(fn map-move [keys capture fname desc]
  (let [move (require :nvim-treesitter-textobjects.move)
        query (expand-query capture)
        group (query-group capture)]
    (each [_ k (ipairs (as-keys keys))]
      (vim.keymap.set [:n :x :o] k
        #((. move fname) query group)
        {:desc (.. desc " " capture)}))))

(fn map-swap [keys capture fname desc]
  (let [swap (require :nvim-treesitter-textobjects.swap)
        query (expand-query capture)]
    (each [_ k (ipairs (as-keys keys))]
      (vim.keymap.set :n k
        #((. swap fname) query)
        {:desc (.. desc " " capture)}))))

(fn hud-hints []
  (local hints {})
  (each [capture opts (pairs bindings)]
    (local k (. opts :select))
    (when k
      (tset hints (.. "treesitter:" capture) k)))
  hints)

(fn setup []
  (let [TS (require :nvim-treesitter-textobjects)]
    (TS.setup {}))
  (each [capture opts (pairs bindings)]
    (when opts.select     (map-select opts.select capture))
    (when opts.move-next  (map-move opts.move-next capture :goto_next_start "Next start of"))
    (when opts.move-prev  (map-move opts.move-prev capture :goto_previous_start "Prev start of"))
    (when opts.move-end-next (map-move opts.move-end-next capture :goto_next_end "Next end of"))
    (when opts.move-end-prev (map-move opts.move-end-prev capture :goto_previous_end "Prev end of"))
    (when opts.swap-next  (map-swap opts.swap-next capture :swap_next "Swap next"))
    (when opts.swap-prev  (map-swap opts.swap-prev capture :swap_previous "Swap prev"))))

{: setup : hud-hints}
