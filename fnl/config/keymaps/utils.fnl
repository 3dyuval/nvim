(local lset vim.keymap.set)

(lset :n :<leader>gG ":Gitsigns"
      {:desc "Gitsigns prefill"})

(lset :n :<leader>gg ":DiffviewGraph<CR>"
      {:desc "Open gitgraph"})

(lset :n :<leader>gn
      (fn [] (vim.cmd (.. "Neogit kind=vsplit cwd=" (vim.fn.expand "%:p:h"))))
      {:desc "Neogit (side)"})

(lset :n :<leader>gc
      ":Neogit commit<CR>"
      {:desc "Neogit commit"})


(lset :n :<leader>gs ":DiffviewOpen %"
      {:desc "File DiffviewOpen history"})

(lset :n :<leader>gh (fn [] (vim.cmd "DiffviewFileHistory ."))
      {:desc "Diffview repo log"})
(lset :n :P (fn [] ((. (require :hover) :open)))
                   {:desc "Hover"})
