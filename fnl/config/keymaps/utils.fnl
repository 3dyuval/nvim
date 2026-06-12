(local lset vim.keymap.set)

(lset :n :<leader>gg
      (fn [] (vim.cmd (.. "Neogit kind=vsplit cwd=" (vim.fn.expand "%:p:h"))))
      {:desc "Neogit (side)" :noremap true})


(lset :n :<leader>gs ":DiffviewOpen %"
      {:desc "File DiffviewOpen history" :noremap true})
(lset :n :P (fn [] ((. (require :hover) :open)))
                   {:desc "Hover"})
