
(local lset vim.keymap.set)
(local ufo (require :ufo))

(lset :<leader>gs ":DiffviewOpen %" {:desc "File DiffviewOpen history" :noremap true})
(lset :ff (ufo.action.openFoldsWith 0) {:desc "Close all folds (fold all)" :noremap true})
(lset :fF "zr" {:desc "Open all folds (unfold all)" :noremap true})
(lset :fo "zo" {:desc "Open fold (unfold)" :noremap true})
(lset :fu "zc" {:desc "Close fold (fold one)" :noremap true})
