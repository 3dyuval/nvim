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

;; Folds: capitalized mirror of the treewalk keys (F = fold/close, U = unfold/open)
(lset :n :OF :zc {:desc "Close fold (one)" :noremap true})
(lset :n :OU :zo {:desc "Open fold (one)" :noremap true})
(lset :n :FF ufo.closeAllFolds {:desc "Close all folds"})
(lset :n :UU ufo.openAllFolds {:desc "Open all folds"})

(lset [ :n :o :x ] "k" :t {:desc "Till before"} )
(lset [ :n :o :x ] "K" :T {:desc "Till before backward"} )

(local gs (require :gitsigns))
(lset :n :ga
      (fn []
        (if vim.wo.diff
            (vim.cmd.normal {1 "]c" :bang true})
            (gs.nav_hunk "next" {:target "all"})))
      {:desc "Next git hunk"})
(lset :n :ge
      (fn []
        (if vim.wo.diff
            (vim.cmd.normal {1 "[c" :bang true})
            (gs.nav_hunk "prev" {:target "all"})))
      {:desc "Prev git hunk"})


