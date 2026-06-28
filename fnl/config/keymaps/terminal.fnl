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

;; Move out of terminal with the same Ctrl+h/a/e/i as smart-splits window nav.
(each [key dir (pairs {:<C-h> :move_cursor_left
                       :<C-a> :move_cursor_down
                       :<C-e> :move_cursor_up
                       :<C-i> :move_cursor_right})]
  (lset :t key
        (fn []
          (vim.api.nvim_feedkeys
            (vim.api.nvim_replace_termcodes "<C-\\><C-n>" true false true) :n false)
          (vim.schedule (fn [] ((. (require :smart-splits) dir)))))
        {:desc (.. "Window " (string.gsub dir "move_cursor_" ""))}))

(fn goto-nearest-terminal [insert?]
  ;; Focus a window already showing a term:// buffer; else open the
  ;; most-recently-used term:// buffer in the current window; else create
  ;; one in a split below. With insert? true, enter terminal insert mode.
  (var focused false)
  (each [_ win (ipairs (vim.api.nvim_tabpage_list_wins 0)) :until focused]
    (let [buf (vim.api.nvim_win_get_buf win)
          name (vim.api.nvim_buf_get_name buf)]
      (when (name:match "^term://")
        (vim.api.nvim_set_current_win win)
        (set focused true))))
  (when (not focused)
    (var best nil)
    (var best-used -1)
    (each [_ b (ipairs (vim.fn.getbufinfo))]
      (when (and (= b.loaded 1) (b.name:match "^term://") (> b.lastused best-used))
        (set best b.bufnr)
        (set best-used b.lastused)))
    (if best
        (vim.api.nvim_set_current_buf best)
        (do
          (vim.cmd "belowright split")
          (vim.cmd "terminal"))))
  (when insert?
    (vim.cmd "startinsert")))

(lset :n "<leader>tt" (fn [] (goto-nearest-terminal false))
      {:desc "Go to nearest terminal"})

(lset :n "<leader>tr" (fn [] (goto-nearest-terminal true))
      {:desc "Go to nearest terminal (insert)"})
