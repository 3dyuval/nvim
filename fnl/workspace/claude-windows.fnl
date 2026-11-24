;; Claude Code window behavior: hide the terminal when a diff buffer opens,
;; and refocus the claude float when nvim regains focus.
(vim.api.nvim_create_autocmd :BufWinEnter
  {:callback (fn []
               (local buf (vim.api.nvim_get_current_buf))
               (when (. vim.b buf :claudecode_diff_tab_name)
                 (each [_ win (ipairs (vim.api.nvim_list_wins))]
                   (local wbuf (vim.api.nvim_win_get_buf win))
                   (when (and (= (. vim.bo wbuf :buftype) :terminal)
                              (string.match (vim.api.nvim_buf_get_name wbuf) :claude))
                     (pcall vim.api.nvim_win_close win false)
                     (lua :return)))))})

(vim.api.nvim_create_autocmd :FocusGained
  {:callback (fn []
               (each [_ win (ipairs (vim.api.nvim_list_wins))]
                 (local buf (vim.api.nvim_win_get_buf win))
                 (local name (vim.api.nvim_buf_get_name buf))
                 (when (and (name:match :claude)
                            (= (. vim.bo buf :buftype) :terminal))
                   (vim.api.nvim_set_current_win win)
                   (vim.cmd :startinsert)
                   (lua :return))))})

{}
