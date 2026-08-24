(local lset vim.keymap.set)
(local ufo (require :ufo))

;; SPEC.md Layer 2 G2 — structural movement = capital HAEI (treewalk)
(lset :n :H "<cmd>Treewalker Left<cr>"
      {:desc "Treewalk out (parent)" :silent true})
(lset :n :I "<cmd>Treewalker Right<cr>"
      {:desc "Treewalk in (child)" :silent true})
(lset :n :E
      ;; SPEC.md Layer 2 G2a — prev sibling, else climb out (row-unchanged proxy)
      (fn []
        (when (pcall vim.treesitter.get_parser 0)
          (let [tw (require :treewalker)
                row (vim.fn.line ".")]
            (tw.move_up)
            (when (= row (vim.fn.line "."))
              (tw.move_out)))))
      {:desc "Treewalk prev sibling (else out)" :silent true})
(lset :n :A "<cmd>Treewalker Down<cr>"
      {:desc "Treewalk next sibling" :silent true})

;; SPEC.md Layer 2 G3 — folds = z-prefix + horizontal HAEI
(lset :n :zh :zc {:desc "Close fold (one)" :noremap true})
(lset :n :zi :zo {:desc "Open fold (one)" :noremap true})
(lset :n :zH ufo.closeAllFolds {:desc "Close all folds"})
(lset :n :zI ufo.openAllFolds {:desc "Open all folds"})

(lset [ :n :o :x ] "k" :t {:desc "Till before"} )
(lset [ :n :o :x ] "K" :T {:desc "Till before backward"} )

;; SPEC.md Layer 4 P2 — buffer paging; hands off to kitty tab at the edge
(lset :n :<C-PageUp> (fn [] ((. (require :workspace.buffer-nav) :prev)))
      {:desc "Prev buffer (kitty tab at edge)"})
(lset :n :<C-PageDown> (fn [] ((. (require :workspace.buffer-nav) :next)))
      {:desc "Next buffer (kitty tab at edge)"})

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


