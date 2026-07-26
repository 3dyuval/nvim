;; claudecode.nvim — Claude Code in a right sidebar split.
{1 "coder/claudecode.nvim"
 :enabled true
 :config
 (fn []
   ((. (require :claudecode) :setup)
    {;; Focus the terminal after sending/adding (e.g. ClaudeCodeAdd) instead of
     ;; just making it visible. Top-level option (sibling of :terminal).
     :focus_after_send true
     :terminal
     {:snacks_win_opts
      {:position "right"
       :width 0.35
       :enter true
       ;; Split close returns focus to the editor on its own, so a plain hide is
       ;; enough here (no float focus-restore dance).
       :keys {:toggle {1 "<C-Space>"
                       2 (fn [self] (self:hide))
                       :mode "t"
                       :desc "Toggle Claude"}}}}})

   ;; Close Claude Code panel when a diff opens
   (vim.api.nvim_create_autocmd
     "User"
     {:pattern "ClaudeCodeDiffOpened"
      :callback (fn [] (vim.cmd "ClaudeCode"))}))}
