{1 "dlyongemallo/diffview-plus.nvim"
 :dev false
 :dependencies ["nvim-tree/nvim-web-devicons"]
 :cmd ["DiffviewOpen" "DiffviewFileHistory" "DiffviewDiffFiles" "DiffviewDiffDirs"]
 :opts (fn []
         (let [actions (require :diffview.actions)]
           {:enhanced_diff_hl true
            :use_icons true
            :show_help_hints true
            :watch_index false
            :diff_binaries false
            :default_args {:DiffviewOpen ["--imply-local"]
                           :DiffviewFileHistory []}
            :view {:default {:layout :diff2_horizontal
                             :winbar_info true
                             :win_config {:position :bottom}}
                   :merge_tool {:layout :diff1_plain
                                :disable_diagnostics false
                                :winbar_info true}
                   :file_history {:layout :diff2_horizontal
                                  :winbar_info true
                                  :pin_local true
                                  :win_config {:position :bottom}}}
            :file_panel {:listing_style :tree
                         :tree_options {:flatten_dirs false
                                        :folder_statuses :only_folded}}
            :keymaps
             {:disable_defaults true
              :view
              ;; conflict resolve — action, not motion: single-window diff1_plain
              ;; has no left/right geometry, so down/up = choose theirs/ours.
              [["n" "<C-M-S-Down>"
                (fn []
                  (if (~= (vim.fn.search "^<<<<<<< " :nw) 0)
                    (actions.conflict_choose :theirs)
                    (vim.cmd "diffget")))
                {:desc "Take THEIRS (get)"}]
               ["n" "<C-M-S-Up>"
                (fn []
                  (if (~= (vim.fn.search "^<<<<<<< " :nw) 0)
                    (actions.conflict_choose :ours)
                    (vim.cmd "diffput")))
                {:desc "Take OURS (put)"}]
               ;; hunk level operations
               ["n" :dp "<Cmd>diffput<CR>" {:desc "Put hunk to other (OURS)"}]
               ;; navigation (HAEI)
               ["n" :<C-A> (fn [] (if (~= (vim.fn.search "^<<<<<<< " :nw) 0) (actions.next_conflict) (vim.cmd "normal! ]c"))) {:desc "Next conflict or hunk"}]
               ["n" :<C-E> (fn [] (if (~= (vim.fn.search "^<<<<<<< " :nw) 0) (actions.prev_conflict) (vim.cmd "normal! [c"))) {:desc "Prev conflict or hunk"}]
               ;; common actions
               ["n" "<S-Esc>" actions.toggle_files {:desc "Toggle files list panel"}]
               ["n" "<leader>." actions.cycle_layout {:desc "Cycle layout"}]
               ["n" "q"        actions.close         {:desc "Close diffview"}]
               ["n" "gf"       actions.goto_file_edit {:desc "Go to file"}]
               ["n" "<C-s>"    actions.stage_all      {:desc "Stage all"}]
               ["n" "?"        (actions.help :view)   {:desc "Help"}]]
              :diff1_inline
             [["n" "<C-A>" actions.next_inline_hunk {:desc "Next inline hunk"}]
              ["n" "<C-E>" actions.prev_inline_hunk {:desc "Prev inline hunk"}]]
              :file_panel
              [["n" "<S-A>" actions.select_next_entry {:desc "Next file"}]
               ["n" "<S-E>" actions.select_prev_entry {:desc "Previous file"}]
               ["n" "<S-Esc>" actions.toggle_files {:desc "Toggle files list panel"}]
               ["n" "dr"    actions.restore_entry                    {:desc "Restore file"}]
               ["n" "dl"    (fn [] (actions.toggle_stage_entry))     {:desc "Stage file"}]
               ["n" "<C-R>" actions.refresh_files                    {:desc "Refresh files"}]
               ["n" "<cr>"  actions.select_entry                     {:desc "Open diff"}]
               ["n" "o"     actions.select_entry                     {:desc "Open diff"}]
               ["n" "q"     "<Cmd>DiffviewClose<CR>"                 {:desc "Close diffview"}]
               ["n" "?"     (actions.help :file_panel)               {:desc "Help"}]]
              :file_history_panel
              [["n" "<S-A>" actions.select_next_entry {:desc "Next file"}]
               ["n" "<S-E>" actions.select_prev_entry {:desc "Previous file"}]
               ["n" "<S-Esc>" actions.toggle_files {:desc "Toggle files list panel"}]
               ["n" "<cr>"   actions.select_entry      {:desc "Open diff"}]
               ["n" "o"      actions.select_entry      {:desc "Open diff"}]
               ["n" "q"      "<Cmd>DiffviewClose<CR>"  {:desc "Close diffview"}]
               ["n" "?"      (actions.help :file_history_panel) {:desc "Help"}]]
              :help_panel
             [["n" "q"   actions.close {:desc "Close help menu"}]
              ["n" "<esc>" actions.close {:desc "Close help menu"}]]}
           :hooks
             {:diff_buf_read (fn [bufnr]
                               (set vim.opt_local.foldenable false)
                               (tset vim.b bufnr :snacks_indent false)
                               (tset vim.b bufnr :snacks_scope false))
              :view_opened  (fn [] (set vim.g.diffview_active true))
              :view_closed  (fn [] (set vim.g.diffview_active false))}}))}
