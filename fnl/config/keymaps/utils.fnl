(local lset vim.keymap.set)

(lset :n :<leader>gs ":DiffviewOpen %"
      {:desc "File DiffviewOpen history" :noremap true})
(lset :n :P (fn [] ((. (require :hover) :open)))
                   {:desc "Hover"})
