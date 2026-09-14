;; dial.nvim — enhanced <C-a>/<C-x> increment/decrement.
;; Normal <C-a>/<C-x> and visual g<C-a>/g<C-x> are free (HAEI window-nav
;; only claims terminal-mode <C-a>). Augends grouped as :default; add
;; filetype-specific groups later if needed.
{1 "monaqa/dial.nvim"
 :enabled true
 :keys
 [{1 "<C-a>"  2 (fn [] ((. (require :dial.map) :manipulate) "increment" "normal"))
   :mode :n :desc "Increment"}
  {1 "<C-x>"  2 (fn [] ((. (require :dial.map) :manipulate) "decrement" "normal"))
   :mode :n :desc "Decrement"}
  {1 "<C-a>"  2 (fn [] ((. (require :dial.map) :manipulate) "increment" "visual"))
   :mode :v :desc "Increment"}
  {1 "<C-x>"  2 (fn [] ((. (require :dial.map) :manipulate) "decrement" "visual"))
   :mode :v :desc "Decrement"}
  {1 "g<C-a>" 2 (fn [] ((. (require :dial.map) :manipulate) "increment" "gvisual"))
   :mode :v :desc "Increment (sequence)"}
  {1 "g<C-x>" 2 (fn [] ((. (require :dial.map) :manipulate) "decrement" "gvisual"))
   :mode :v :desc "Decrement (sequence)"}]
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
