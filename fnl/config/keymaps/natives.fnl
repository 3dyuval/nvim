(local lset vim.keymap.set)

;; g-prefix restores native commands the Graphite/HAEI layer displaced.
;; X = delete operator, K = till-backward — so the natives move to g*.
(lset [:n :x] :gX :X {:desc "Delete before cursor"})
(lset [:n :x] :gK :K {:desc "Lookup keyword"})
(lset [:n :x] :gh :K {:desc "Lookup keyword"})

;; Deletes never touch the yank. Bare d/D/c/C/x route to the black hole so a
;; yank survives any delete; use y to grab text, d purely to remove.
(lset [:n :x] :d "\"_d" {:desc "Delete (black hole)"})
(lset :n :dd "\"_dd" {:desc "Delete line (black hole)"})
(lset [:n :x] :D "\"_D" {:desc "Delete to EOL (black hole)"})
(lset [:n :x] :x "\"_x" {:desc "Delete char (black hole)"})
(lset [:n :x] :c "\"_c" {:desc "Change (black hole)"})
(lset :n :cc "\"_cc" {:desc "Change line (black hole)"})
(lset [:n :x] :C "\"_C" {:desc "Change to EOL (black hole)"})

;; Paste over a visual selection without the selection clobbering the register.
(lset :x :p "\"_dP" {:desc "Paste over selection (keep yank)"})
(lset :x :P "\"_dp" {:desc "Paste over selection (keep yank)"})
