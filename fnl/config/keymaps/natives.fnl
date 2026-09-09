(local lset vim.keymap.set)

;; g-prefix restores native commands the Graphite/HAEI layer displaced.
;; X = delete operator, U = undo, K = till-backward — so the natives move to g*.
(lset [:n :x] :gX :X {:desc "Delete before cursor"})
(lset [:n :x] :gU :U {:desc "Uppercase"})
(lset [:n :x] :gK :K {:desc "Lookup keyword"})
(lset [:n :x] :gh :K {:desc "Lookup keyword"})
