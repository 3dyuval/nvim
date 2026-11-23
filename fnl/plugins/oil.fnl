;; oil.nvim — edit the filesystem as a normal buffer (bulk rename/move/delete
;; via vim editing, :w to apply). Hijacks netrw as the directory handler.
;; In-buffer keymaps are HAEI-adapted (h=parent, i=enter, ? shows help).
;; Deletes go to the trash, not rm.
{1 "stevearc/oil.nvim"
 :dependencies ["nvim-tree/nvim-web-devicons"]
 ;; lazy=false is required when hijacking netrw so oil claims directory buffers
 ;; opened at startup (e.g. `nvim .`).
 :lazy false
 :keys [{1 "<leader>o-"
         2 (fn [] ((. (require :oil) :open)))
         :desc "Oil: open parent dir (editable)"}
        {1 "<leader>oo"
         2 (fn [] ((. (require :oil) :open_float)))
         :desc "Oil: open float (editable)"}]
 :opts {:default_file_explorer true
        :delete_to_trash true
        :skip_confirm_for_simple_edits false
        :view_options {:show_hidden true}
        :float {:padding 4
                :max_width 100
                :max_height 30}
        ;; HAEI-adapted in-buffer keymaps (h=left/out, i=right/in). Defaults are
        ;; fully replaced so the stock <C-h> horizontal-split (which collides
        ;; with smart-splits "window left") never registers.
        :use_default_keymaps false
        :keymaps {;; help on both ? and g?
                  "?" {1 "actions.show_help" :mode "n"}
                  "g?" {1 "actions.show_help" :mode "n"}
                  ;; HAEI directional nav: h = parent (out), i = enter/open (in)
                  "h" {1 "actions.parent" :mode "n"}
                  "i" {1 "actions.select" :mode "n"}
                  "<CR>" "actions.select"
                  ;; splits moved off <C-h> (smart-splits window-left)
                  "<C-s>" {1 "actions.select" :opts {:vertical true}}
                  "<C-x>" {1 "actions.select" :opts {:horizontal true}}
                  "<C-t>" {1 "actions.select" :opts {:tab true}}
                  "<C-p>" "actions.preview"
                  "<C-c>" {1 "actions.close" :mode "n"}
                  "<C-l>" "actions.refresh"
                  ;; keep the native dir/view actions
                  "-" {1 "actions.parent" :mode "n"}
                  "_" {1 "actions.open_cwd" :mode "n"}
                  "`" {1 "actions.cd" :mode "n"}
                  "gs" {1 "actions.change_sort" :mode "n"}
                  "gx" "actions.open_external"
                  "g." {1 "actions.toggle_hidden" :mode "n"}
                  "g\\" {1 "actions.toggle_trash" :mode "n"}}}}
