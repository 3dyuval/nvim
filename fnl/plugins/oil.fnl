;; oil.nvim — edit the filesystem as a normal buffer (bulk rename/move/delete
;; via vim editing, :w to apply). Hijacks netrw as the directory handler; the
;; snacks explorer (<leader>of / <leader>fo) and yazi stay keymap-driven and
;; are unaffected. Deletes go to the trash, not rm.
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
                :max_height 30}}}
