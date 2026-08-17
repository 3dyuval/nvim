(local lset vim.keymap.set)
(local ufo (require :ufo))

;; Structural movement (Treewalker) = capital HAEI, same 4 directions as
;; lowercase h/a/e/i. Left/Right walk out/in a level (parent/child);
;; Up/Down walk prev/next sibling.
(lset :n :H "<cmd>Treewalker Left<cr>"
      {:desc "Treewalk out (parent)" :silent true})
(lset :n :I "<cmd>Treewalker Right<cr>"
      {:desc "Treewalk in (child)" :silent true})
(lset :n :E
      (fn []
        ;; prev sibling; if move_up doesn't move (no prev sibling), walk out to
        ;; the parent. Treewalker moves by row (anchor.current uses line('.')),
        ;; so an unchanged row means move_up found no target. Guard on a parser
        ;; first so a parserless buffer no-ops once instead of double-notifying.
        (when (pcall vim.treesitter.get_parser 0)
          (let [tw (require :treewalker)
                row (vim.fn.line ".")]
            (tw.move_up)
            (when (= row (vim.fn.line "."))
              (tw.move_out)))))
      {:desc "Treewalk prev sibling (else out)" :silent true})
(lset :n :A "<cmd>Treewalker Down<cr>"
      {:desc "Treewalk next sibling" :silent true})

;; Folds = z-prefix + horizontal HAEI (depth axis, mirroring structural H/I):
;;   h = close (collapse, shallower)   i = open (expand, deeper)
;;   capital = all folds.
(lset :n :zh :zc {:desc "Close fold (one)" :noremap true})
(lset :n :zi :zo {:desc "Open fold (one)" :noremap true})
(lset :n :zH ufo.closeAllFolds {:desc "Close all folds"})
(lset :n :zI ufo.openAllFolds {:desc "Open all folds"})

(lset [ :n :o :x ] "k" :t {:desc "Till before"} )
(lset [ :n :o :x ] "K" :T {:desc "Till before backward"} )

(local gs (require :gitsigns))
(lset :n :<C-S-A>
      (fn []
        (if vim.wo.diff
            (vim.cmd.normal {1 "]c" :bang true})
            (gs.nav_hunk "next" {:target "all"})))
      {:desc "Next git hunk"})
(lset :n :<C-S-E>
      (fn []
        (if vim.wo.diff
            (vim.cmd.normal {1 "[c" :bang true})
            (gs.nav_hunk "prev" {:target "all"})))
      {:desc "Prev git hunk"})


