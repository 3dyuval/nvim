;; dial.nvim — enhanced increment/decrement. <C-a>/<C-x> belong to smart-splits
;; window-nav (HAEI), so dial uses ge/ga: e=up=increment, a=down=decrement.
;; Augends grouped as :default; add filetype-specific groups later if needed.

;; One lazy key spec: `lhs` in `mode` runs dial.manipulate(dir, dial-mode).
(fn key [lhs mode dir dial-mode desc]
  {1 lhs
   2 (fn [] ((. (require :dial.map) :manipulate) dir dial-mode))
   :mode mode :desc desc})

{1 "monaqa/dial.nvim"
 :enabled true
 :keys
 [(key "ge"  :n "increment" "normal"  "Increment")
  (key "ga"  :n "decrement" "normal"  "Decrement")
  (key "ge"  :v "increment" "visual"  "Increment")
  (key "ga"  :v "decrement" "visual"  "Decrement")
  (key "gge" :v "increment" "gvisual" "Increment (sequence)")
  (key "gga" :v "decrement" "gvisual" "Decrement (sequence)")]
 :config
 (fn []
   (let [augend (require :dial.augend)
         cyclic (fn [words] (augend.constant.new {:elements words :word true :cyclic true}))
         symbol (fn [words] (augend.constant.new {:elements words :word false :cyclic true}))]
     (: (. (require :dial.config) :augends) :register_group
      {:default
       [augend.integer.alias.decimal_int
        augend.integer.alias.hex
        augend.constant.alias.bool
        (. augend.date.alias "%Y-%m-%d")
        (. augend.date.alias "%H:%M")
        augend.semver.alias.semver
        (augend.constant.new {:elements ["True" "False"] :word true :cyclic true})
        (cyclic ["and" "or"])
        (cyclic ["yes" "no"])
        (cyclic ["on" "off"])
        (cyclic ["let" "const"])
        (cyclic ["enable" "disable"])
        (symbol ["&&" "||"])
        (symbol ["==" "!="])
        (symbol ["<" ">"])]})))}
