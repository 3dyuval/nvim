{1 "dlyongemallo/diffview-plus.nvim"
 :dev true
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
              [["n" "dr"
                (fn []
                  (if (~= (vim.fn.search "^<<<<<<< " :nw) 0)
                    (actions.conflict_choose :theirs)
                    (vim.cmd "diffget")))
                {:desc "Get from right (THEIRS)"}]
               ["n" "dl"
                (fn []
                  (if (~= (vim.fn.search "^<<<<<<< " :nw) 0)
                    (actions.conflict_choose :ours)
                    (vim.cmd "diffget")))
                {:desc "Get from left (OURS)"}]
               ;; diff get (all hunks)
               ["n" "Dr" "<Cmd>%diffget<CR>" {:desc "Get all from right (THEIRS)"}]
               ["n" "Dl" "<Cmd>diffget<CR>" {:desc "Get all from left (OURS)"}]
               ;; hunk level operations
               ["n" "dp" "<Cmd>diffput<CR>" {:desc "Put hunk to other (OURS)"}]
               ;; navigation (HAEI)
               ["n" "ga" (fn [] (if (~= (vim.fn.search "^<<<<<<< " :nw) 0) (actions.next_conflict) (vim.cmd "normal! ]c"))) {:desc "Next conflict or hunk"}]
               ["n" "ge" (fn [] (if (~= (vim.fn.search "^<<<<<<< " :nw) 0) (actions.prev_conflict) (vim.cmd "normal! [c"))) {:desc "Prev conflict or hunk"}]
               ;; common actions
               ["n" "<leader>." actions.cycle_layout {:desc "Cycle layout"}]
               ["n" "q"        actions.close         {:desc "Close diffview"}]
               ["n" "gf"       actions.goto_file_edit {:desc "Go to file"}]
               ["n" "<C-s>"    actions.stage_all      {:desc "Stage all"}]
               ["n" "<S-PageDown>" actions.select_next_entry {:desc "Next file"}]
               ["n" "<S-PageUp>"   actions.select_prev_entry {:desc "Previous file"}]
               ["n" "?"        (actions.help :view)   {:desc "Help"}]]
              :diff1_inline
            [["n" "ga" actions.next_inline_hunk {:desc "Next inline hunk"}]
              ["n" "ge" actions.prev_inline_hunk {:desc "Prev inline hunk"}]]
              :file_panel
              [["n" "<S-PageDown>" actions.select_next_entry {:desc "Next file"}]
               ["n" "<S-PageUp>"   actions.select_prev_entry {:desc "Previous file"}]
               ["n" "dr"    actions.restore_entry                    {:desc "Restore file"}]
               ["n" "dl"    (fn [] (actions.toggle_stage_entry))     {:desc "Stage file"}]
               ["n" "<C-R>" actions.refresh_files                    {:desc "Refresh files"}]
               ["n" "<cr>"  actions.select_entry                     {:desc "Open diff"}]
               ["n" "o"     actions.select_entry                     {:desc "Open diff"}]
               ["n" "q"     "<Cmd>DiffviewClose<CR>"                 {:desc "Close diffview"}]
               ["n" "?"     (actions.help :file_panel)               {:desc "Help"}]]
              :file_history_panel
              [["n" "<S-PageDown>" actions.select_next_entry {:desc "Next file"}]
               ["n" "<S-PageUp>"   actions.select_prev_entry {:desc "Previous file"}]
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
