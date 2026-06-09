(local lset vim.keymap.set)
(local editor (require :utils.editor))

(lset :n :<leader>rk editor.reload_keymaps {:desc "Reload keymaps"})

