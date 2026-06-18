{1 "dlyongemallo/diffview-plus.nvim"
 :dev true
 :dependencies ["nvim-tree/nvim-web-devicons"
                "isakbm/gitgraph.nvim"]  ;; Optional for CDiffView integration
 :init (fn []
         ;; Command to open diffview with gitgraph panel
         (let [graph-view-kind (require :integration.graph-view-kind)]
           (vim.api.nvim_create_user_command
             :DiffviewGraph
             (fn [_opts] (graph-view-kind.open-graph))
             {:desc "Open gitgraph in diffview"})))
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
                   :merge_tool {:layout :diff3_horizontal
                                :disable_diagnostics false
                                :winbar_info true}
                   :file_history {:layout :diff2_horizontal
                                  :winbar_info true
                                  :pin_local true
                                  :win_config {:position :bottom}}}
            :graph_panel {:win_config {:position :bottom
                                       :height 16}}
            :file_panel {:listing_style :tree
                         :tree_options {:flatten_dirs false
                                        :folder_statuses :only_folded}
                         :win_config {:position :bottom
                                      :height 16}}
            :keymaps
            {:disable_defaults true
             :view
             [;; diff get/put (current hunk)
              ["n" "dr"
               (fn []
                 (if (: vim.opt_local.diff :get)
                   (vim.cmd :diffget)
                   (actions.conflict_choose :theirs)))
               {:desc "Get from right"}]
              ["n" "dl"
               (fn []
                 (if (: vim.opt_local.diff :get)
                   (vim.cmd "diffget //2")
                   (actions.conflict_choose :ours)))
               {:desc "Get from left (ours)"}]
              ;; diff get (all hunks)
              ["n" "Dr" "<Cmd>%diffget //3<CR>" {:desc "Get all from right (theirs)"}]
              ["n" "Dl" "<Cmd>%diffget //2<CR>" {:desc "Get all from left (ours)"}]
              ;; navigation (HAEI)
              ["n" "A"
               (fn []
                 (if (~= (vim.fn.search "^<<<<<<< " :nw) 0)
                   (actions.next_conflict)
                   (vim.cmd "normal! ]c")))
               {:desc "Next conflict or hunk"}]
              ["n" "E"
               (fn []
                 (if (~= (vim.fn.search "^<<<<<<< " :nw) 0)
                   (actions.prev_conflict)
                   (vim.cmd "normal! [c")))
               {:desc "Prev conflict or hunk"}]
              ;; navigation (SHAD)
              ["n" "<C-PageDown>"
               (fn []
                 (if (~= (vim.fn.search "^<<<<<<< " :nw) 0)
                   (actions.next_conflict)
                   (vim.cmd "normal! ]c")))
               {:desc "Next conflict or hunk"}]
              ["n" "<C-PageUp>"
               (fn []
                 (if (~= (vim.fn.search "^<<<<<<< " :nw) 0)
                   (actions.prev_conflict)
                   (vim.cmd "normal! [c")))
               {:desc "Prev conflict or hunk"}]
              ;; common actions
              ["n" "<leader>." actions.cycle_layout {:desc "Cycle layout"}]
              ["n" "q"        actions.close         {:desc "Close diffview"}]
              ["n" "<C-S-A>"  actions.select_next_entry {:desc "Open diff for next file"}]
              ["n" "<C-S-E>"  actions.select_prev_entry {:desc "Open diff for previous file"}]
              ["n" "gf"       actions.goto_file_edit {:desc "Go to file"}]
              ["n" "<C-s>"    actions.stage_all      {:desc "Stage all"}]
              ["n" "?"        (actions.help :view)   {:desc "Help"}]]
             :diff1_inline
             [["n" "A" actions.next_inline_hunk {:desc "Next inline hunk"}]
              ["n" "E" actions.prev_inline_hunk {:desc "Prev inline hunk"}]]
             :file_panel
             [["n" "dr"    actions.restore_entry                    {:desc "Restore file"}]
              ["n" "dl"    (fn [] (actions.toggle_stage_entry))     {:desc "Stage file"}]
              ["n" "<C-R>" actions.refresh_files                    {:desc "Refresh files"}]
              ["n" "A"     actions.select_next_entry                {:desc "Next file"}]
              ["n" "E"     actions.select_prev_entry                {:desc "Prev file"}]
              ["n" "<C-S-A>" actions.select_next_entry              {:desc "Next file"}]
              ["n" "<C-S-E>" actions.select_prev_entry              {:desc "Prev file"}]
              ["n" "<C-PageDown>" actions.select_next_entry         {:desc "Next file"}]
              ["n" "<C-PageUp>"   actions.select_prev_entry         {:desc "Prev file"}]
              ["n" "<cr>"  actions.select_entry                     {:desc "Open diff"}]
              ["n" "o"     actions.select_entry                     {:desc "Open diff"}]
              ["n" "q"     "<Cmd>DiffviewClose<CR>"                 {:desc "Close diffview"}]
              ["n" "?"     (actions.help :file_panel)               {:desc "Help"}]]
             :file_history_panel
             [["n" "A"      actions.select_next_commit {:desc "Next commit"}]
              ["n" "E"      actions.select_prev_commit {:desc "Prev commit"}]
              ["n" "<C-M-A>" actions.select_next_entry {:desc "Next file"}]
              ["n" "<C-M-E>" actions.select_prev_entry {:desc "Prev file"}]
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
                              (tset vim.b bufnr :snacks_scope false))}}))}
