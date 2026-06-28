{1 "rmagatti/auto-session"
 :pin true
 :branch "fix/issue-516-branch-hash"
 :lazy false
 :config
 (fn []
    ;; @type AutoSession.Config
    ((. (require "auto-session") :setup)
     {:auto_session_enabled true
       :auto_save true
       :auto_restore false
       :root_dir (.. (vim.fn.stdpath "data") "/sessions/")
       :bypass_save_filetypes ["alpha" "dashboard" "slime" "git" "snacks_win" "snacks_picker" "snacks_explorer"]
       :close_unsupported_windows true
       :suppressed_dirs ["/tmp" "~/Downloads" "/" "~/.config/nvim"]
       :git_use_branch_name true
       :git_auto_restore_on_branch_change true
       :session_lens {:picker :snacks}})

  ;; Alias commands for convenience (plugin already provides :AutoSession *)
   (vim.api.nvim_create_user_command :SaveSession
     #(vim.cmd ":AutoSession save")
     {:desc "Save the current session"})

   (vim.api.nvim_create_user_command :RestoreSession
     #(vim.cmd ":AutoSession restore")
     {:desc "Restore the last saved session"})

   (vim.api.nvim_create_user_command :DeleteSession
      (fn [opts]
        (if opts.args
            (vim.cmd (.. ":AutoSession delete " opts.args))
            (vim.cmd ":AutoSession delete")))
      {:nargs "?" :desc "Delete a saved session"}))}
