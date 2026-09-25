(local lset vim.keymap.set)

(lset :n :<leader>qs
      (fn [] ((. (require :workspace.session) :open)))
      {:desc "Session picker"})

(lset :n :<leader>tt
      (fn [] (vim.api.nvim_feedkeys ":terminal " :t false))
      {:desc "Terminal prefill"})

(lset [:n :x] :<leader>rs
      (fn [] ((. (require :workspace.kitty-send) :send)))
      {:desc "Kitty: send line/selection"})

(lset :n :<leader>rr
      (fn [] ((. (require :workspace.kitty-send) :open) :hsplit))
      {:desc "Kitty: open runner (bottom)"})

(lset :n :<leader>rR
      (fn [] ((. (require :workspace.kitty-send) :open) :vsplit))
      {:desc "Kitty: open runner (right)"})

(lset :n :<leader>ff
      (fn [] (vim.cmd "Yazi"))
      {:desc "Yazi at current file"})

