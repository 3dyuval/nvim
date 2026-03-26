;; Mode entry / exit keymaps
(local lset vim.keymap.set)

(lset :n :n :i {:desc "Insert before cursor"})
(lset :n :N :I {:desc "Insert at line start (first non-blank)"})
(lset :i :<C-n> :<Esc> {:desc "Normal mode"})
