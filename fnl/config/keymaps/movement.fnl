(local lset vim.keymap.set)
(local ufo (require :ufo))

;; Treewalk: structural movement
(lset :n :of "<cmd>Treewalker Left<cr>"
      {:desc "Treewalk out (up a level)" :silent true})

(lset :n :ou "<cmd>Treewalker Right<cr>"
      {:desc "Treewalk in (into level)" :silent true})

(lset :n :H "<cmd>Treewalker Up<cr>"
      {:desc "Treewalk prev (same level)" :silent true})

(lset :n :I "<cmd>Treewalker Down<cr>"
      {:desc "Treewalk next (same level)" :silent true})

;; Folds: capitalized mirror of the treewalk keys (F = fold/close, U = unfold/open)
(lset :n :OF :zc {:desc "Close fold (one)" :noremap true})
(lset :n :OU :zo {:desc "Open fold (one)" :noremap true})
(lset :n :FF ufo.closeAllFolds {:desc "Close all folds"})
(lset :n :UU ufo.openAllFolds {:desc "Open all folds"})

(lset [ :n :o :x ] "k" :t {:desc "Till before"} )
(lset [ :n :o :x ] "K" :T {:desc "Till before backward"} )

;; Git hunk navigation (gitsigns; falls back to diff ]c/[c in diff mode)
(local gs (require :gitsigns))
(lset :n :<C-PageDown>
      (fn []
        (if vim.wo.diff
            (vim.cmd.normal {1 "]c" :bang true})
            (gs.next_hunk)))
      {:desc "Next git hunk"})
(lset :n :<C-PageUp>
      (fn []
        (if vim.wo.diff
            (vim.cmd.normal {1 "[c" :bang true})
            (gs.prev_hunk)))
      {:desc "Prev git hunk"})
