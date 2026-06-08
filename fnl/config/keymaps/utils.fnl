(local lset vim.keymap.set)
(local ufo (require :ufo))
(lset :n :<leader>gs ":DiffviewOpen %"
      {:desc "File DiffviewOpen history" :noremap true})

(lset :n :ff (fn [] (ufo.action.openFoldsWith 0))
      {:desc "Close all folds (fold all)"})
(lset :n :fM :zr {:desc "Fold all" :noremap true})
(lset :n :fF :zr {:desc "Unfold all" :noremap true})
(lset :n :fo :zo {:desc :Unfold :noremap true})
(lset :n :fu :zc {:desc "Fold one" :noremap true})

