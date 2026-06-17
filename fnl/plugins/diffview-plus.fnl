{1 "dlyongemallo/diffview-plus.nvim"
 :dev true
 ;; gitgraph.nvim is an opt-in dependency: diffview-plus's :DiffviewGraph panel
 ;; renders via gitgraph.core when present (and degrades silently if absent).
 ;; Its opts/config travel with it here — symbols built by codepoint (the kitty
 ;; PUA glyphs don't survive as source literals), and its highlight groups
 ;; linked to the active colorscheme.
 :dependencies ["nvim-tree/nvim-web-devicons"
                {1 "isakbm/gitgraph.nvim"
                 :opts {:git_cmd "git"
                        :format {:timestamp "%H:%M:%S %d-%m-%Y"
                                 :fields ["hash" "timestamp" "author" "branch_name" "tag"]}
                        :symbols {:merge_commit (vim.fn.nr2char 0xF5FA)
                                  :commit (vim.fn.nr2char 0xF5FB)
                                  :merge_commit_end (vim.fn.nr2char 0xF5F6)
                                  :commit_end (vim.fn.nr2char 0xF5F7)
                                  :GVER (vim.fn.nr2char 0xF5D1)
                                  :GHOR (vim.fn.nr2char 0xF5D0)
                                  :GCLD (vim.fn.nr2char 0xF5D7)
                                  :GCRD "╭"
                                  :GCLU (vim.fn.nr2char 0xF5D9)
                                  :GCRU (vim.fn.nr2char 0xF5D8)
                                  :GLRU (vim.fn.nr2char 0xF5E5)
                                  :GLRD (vim.fn.nr2char 0xF5E0)
                                  :GLUD (vim.fn.nr2char 0xF5DE)
                                  :GRUD (vim.fn.nr2char 0xF5DB)
                                  :GFORKU (vim.fn.nr2char 0xF5E6)
                                  :GFORKD (vim.fn.nr2char 0xF5E6)
                                  :GRUDCD (vim.fn.nr2char 0xF5DB)
                                  :GRUDCU (vim.fn.nr2char 0xF5DA)
                                  :GLUDCD (vim.fn.nr2char 0xF5DE)
                                  :GLUDCU (vim.fn.nr2char 0xF5DD)
                                  :GLRDCL (vim.fn.nr2char 0xF5E0)
                                  :GLRDCR (vim.fn.nr2char 0xF5E1)
                                  :GLRUCL (vim.fn.nr2char 0xF5E3)
                                  :GLRUCR (vim.fn.nr2char 0xF5E5)}}
                 :config (fn [_ opts]
                           ((. (require :gitgraph) :setup) opts)
                           (let [link (fn [from to]
                                        (vim.api.nvim_set_hl 0 from {:link to :default false}))
                                 apply (fn []
                                         (link :GitGraphBranch1 :Function)
                                         (link :GitGraphBranch2 :Type)
                                         (link :GitGraphBranch3 :String)
                                         (link :GitGraphBranch4 :Identifier)
                                         (link :GitGraphBranch5 :Special)
                                         (link :GitGraphHash :Identifier)
                                         (link :GitGraphTimestamp :Comment)
                                         (link :GitGraphAuthor :Type)
                                         (link :GitGraphBranchName :Function)
                                         (link :GitGraphBranchTag :Constant)
                                         (link :GitGraphBranchMsg :Normal))]
                             (apply)
                             (vim.api.nvim_create_autocmd :ColorScheme {:callback apply})))}]
 :cmd ["DiffviewOpen"
       "DiffviewToggle"
       "DiffviewFileHistory"
       "DiffviewGraph"
       "DiffviewDiffFiles"
       "DiffviewMergeFiles"
       "DiffviewDiffDirs"]
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
                                        :folder_statuses :only_folded}}
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
            (let [gitgraph (require :integration.gitgraph-diffview)]
              {:diff_buf_read (fn [bufnr]
                                (set vim.opt_local.foldenable false)
                                (tset vim.b bufnr :snacks_indent false)
                                (tset vim.b bufnr :snacks_scope false))
               :view_opened  (fn [view]
                                (set vim.g.diffview_active true)
                                (gitgraph.on-view-opened view))
               :view_closed  (fn [view]
                                (set vim.g.diffview_active false)
                                (gitgraph.on-view-closed view))
               :selection_changed (fn [view]
                                    (gitgraph.on-selection-changed view))
               :files_staged (fn [view]
                                (gitgraph.on-files-staged view))}})})}}
