;; Terminal mode scroll keymaps
;; kitty sends these sequences when ctrl+shift+e/a are pressed inside Neovim
;; (instead of kitty handling scroll_page_up/down itself)
(local lset vim.keymap.set)

(lset :t :<C-w>
      (fn []
        (local win (vim.api.nvim_get_current_win))
        (vim.api.nvim_feedkeys
          (vim.api.nvim_replace_termcodes "<C-\\><C-n>" true false true) :n false)
        (vim.schedule (fn [] (pcall vim.api.nvim_win_close win false))))
      {:desc "Close terminal window"})
(lset :t "\x1b[101;6u" "<C-\\><C-n><C-u>" {:desc "Scroll up in terminal"})
(lset :t "\x1b[97;6u"  "<C-\\><C-n><C-d>" {:desc "Scroll down in terminal"})

(lset :n "<leader>tr" (fn [] ((. (require :summon) :open) :terminal))
      {:desc "Terminal (summon)"})

(lset :n "<leader>tt" (fn [] ((. (require :summon) :pick)))
      {:desc "Pick (summon)"})

(lset :n "\x1b[44;6u" (fn [] ((. (require :summon) :open) :claude))
      {:desc "Claude-Code (bound to kitty-{PID})"})
