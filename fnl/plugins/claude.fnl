;; claudecode.nvim — Claude Code integration in a floating snacks terminal.
{1 "coder/claudecode.nvim"
 :enabled true
 :config
 (fn []
   ((. (require :claudecode) :setup)
    {:terminal
     {:snacks_win_opts
      {:position "float"
       :width 0.95
       :height 0.88
       :border "rounded"
       :backdrop false
       :enter true
       :keys {:toggle {1 "<C-Space>"
                       2 (fn [self]
                           (self:hide)
                           ;; cc_hide's `wincmd p` is flaky from terminal-insert
                           ;; mode (textlock/timing), so focus sometimes stays in
                           ;; the now-hidden float. Step out deterministically.
                           (vim.schedule
                             (fn []
                               (when (and self.win
                                          (vim.api.nvim_win_is_valid self.win)
                                          (= (vim.api.nvim_get_current_win) self.win))
                                 (pcall vim.cmd "wincmd p"))
                               (when (= (vim.fn.mode) :t)
                                 (pcall vim.cmd "stopinsert")))))
                       :mode "t"
                       :desc "Toggle Claude"}}}}})

   ;; Close Claude Code panel when a diff opens
   (vim.api.nvim_create_autocmd
     "User"
     {:pattern "ClaudeCodeDiffOpened"
      :callback (fn [] (vim.cmd "ClaudeCode"))}))}
