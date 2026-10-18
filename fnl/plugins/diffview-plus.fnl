;; diffview-plus — keymaps (HAEI, consistent across every context):
;;
;;   key             action                      contexts
;;   ──────────────  ──────────────────────────  ───────────────────────────────
;;   <S-A> / <S-E>   next / prev file entry       view, file_panel, file_history
;;   <C-S-A>/<C-S-E> next / prev commit entry     file_history
;;   <C-A> / <C-E>   window down / up (smart-split)  all
;;   <C-Down>/<C-Up> next / prev hunk or conflict    view, inline, both panels
;;   <C-M-S-Down/Up> take THEIRS / OURS (conflict)   view
;;   dp              put hunk to other (OURS)        view
;;   <CR> / o        open diff for entry             file_panel, file_history
;;   <S-Esc>         toggle files list panel         view, both panels
;;   dr / dl         restore / stage file            file_panel
;;   q               close diffview                  all
;;
;; SPEC.md X2: <C-A>/<C-E> stay directional window-nav here (their global
;; meaning); entry-nav is <S-A>/<S-E>; hunk-nav moved to <C-Down>/<C-Up>.
{1 "dlyongemallo/diffview-plus.nvim"
 :dev false
 :dependencies ["nvim-tree/nvim-web-devicons"]
 :cmd ["DiffviewOpen" "DiffviewFileHistory" "DiffviewDiffFiles" "DiffviewDiffDirs"]
 :opts (fn []
         (let [actions (require :diffview.actions)
               ;; run fn in the diff main window; from a panel (winfixbuf)
               ;; focus the main win first so hunk/conflict nav targets the diff.
               in-diff-window (fn [f]
                                (fn []
                                  (when vim.wo.winfixbuf
                                    (let [view ((. (require :diffview.lib) :get_current_view))]
                                      (when (and view view.cur_layout)
                                        (let [main (view.cur_layout:get_main_win)]
                                          (when (and main main.id (vim.api.nvim_win_is_valid main.id))
                                            (vim.api.nvim_set_current_win main.id))))))
                                  (f)))
               next-hunk (fn [] (if (~= (vim.fn.search "^<<<<<<< " :nw) 0) (actions.next_conflict) (vim.cmd "normal! ]c")))
               prev-hunk (fn [] (if (~= (vim.fn.search "^<<<<<<< " :nw) 0) (actions.prev_conflict) (vim.cmd "normal! [c")))
               ;; <C-A>/<C-E> stay directional window-nav here too (SPEC: those
               ;; keys are smart-splits down/up everywhere); hunks move to <C-Down>/<C-Up>.
               win-down (fn [] ((. (require :smart-splits) :move_cursor_down)))
               win-up   (fn [] ((. (require :smart-splits) :move_cursor_up)))]
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
                   ;; No global pin_local: <leader>gf = history without local,
                   ;; <leader>gF = history with --base=LOCAL (working tree on right).
                   :file_history {:layout :diff2_horizontal
                                  :winbar_info true
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
               ;; window nav (HAEI, smart-splits) + hunk nav on arrows
               ["n" :<C-A> win-down {:desc "Window down"}]
               ["n" :<C-E> win-up {:desc "Window up"}]
               ["n" :<C-Down> next-hunk {:desc "Next conflict or hunk"}]
               ["n" :<C-Up> prev-hunk {:desc "Prev conflict or hunk"}]
               ;; entry navigation (match the panels)
               ["n" "<S-A>" actions.select_next_entry {:desc "Next file"}]
               ["n" "<S-E>" actions.select_prev_entry {:desc "Previous file"}]
               ;; common actions
               ["n" "<S-Esc>" actions.toggle_files {:desc "Toggle files list panel"}]
               ["n" "<leader>." actions.cycle_layout {:desc "Cycle layout"}]
               ["n" "q"        actions.close         {:desc "Close diffview"}]
               ["n" "gf"       actions.goto_file_edit {:desc "Go to file"}]
               ["n" "<C-s>"    actions.stage_all      {:desc "Stage all"}]
               ["n" "?"        (actions.help :view)   {:desc "Help"}]]
              :diff1_inline
             [["n" "<C-A>" win-down {:desc "Window down"}]
              ["n" "<C-E>" win-up {:desc "Window up"}]
              ["n" "<C-Down>" actions.next_inline_hunk {:desc "Next inline hunk"}]
              ["n" "<C-Up>" actions.prev_inline_hunk {:desc "Prev inline hunk"}]]
              :file_panel
              [["n" "<S-A>" actions.select_next_entry {:desc "Next file"}]
               ["n" "<S-E>" actions.select_prev_entry {:desc "Previous file"}]
               ["n" "<C-A>" win-down {:desc "Window down"}]
               ["n" "<C-E>" win-up {:desc "Window up"}]
               ["n" "<C-Down>" (in-diff-window next-hunk) {:desc "Next conflict or hunk"}]
               ["n" "<C-Up>" (in-diff-window prev-hunk) {:desc "Prev conflict or hunk"}]
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
               ["n" "<C-S-A>" actions.select_next_commit {:desc "Next commit"}]
               ["n" "<C-S-E>" actions.select_prev_commit {:desc "Prev commit"}]
               ["n" "<C-A>" win-down {:desc "Window down"}]
               ["n" "<C-E>" win-up {:desc "Window up"}]
               ["n" "<C-Down>" (in-diff-window next-hunk) {:desc "Next conflict or hunk"}]
               ["n" "<C-Up>" (in-diff-window prev-hunk) {:desc "Prev conflict or hunk"}]
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
