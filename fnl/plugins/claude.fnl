;; claudecode.nvim — Claude Code integration in a sidebar
{1 "coder/claudecode.nvim"
 :enabled true
 :config
 (fn []
   ((. (require :claudecode) :setup)
    {:terminal
     {:snacks_win_opts
      {:position "right"
       :width 0.35
       :keys {:toggle {1 "<C-Space>"
                       2 "hide"
                       :mode "t"
                       :desc "Toggle Claude"}}}}})

   ;; Close Claude Code panel when a diff opens
   (vim.api.nvim_create_autocmd
     "User"
     {:pattern "ClaudeCodeDiffOpened"
      :callback (fn [] (vim.cmd "ClaudeCode"))}))}
