;; fff.nvim — fast fuzzy file finder with a Rust core.
;; The native binary is downloaded (or cargo-built) via the build step; without
;; it require("fff") errors on binary load. Git ref and binary are pinned to the
;; same stable release to avoid lua<->binary drift on update.
{1 "dmtrKovalenko/fff.nvim"
 :enabled true
 :version "v0.9.6"
 :build (fn []
          ;; downloads a prebuilt binary matching the version, or falls back to cargo build
          ((. (require :fff.download) :download_or_build_binary)))
 :opts {:version "v0.9.6"
        :base_path (vim.fn.getcwd)
        :max_results 100
        :max_threads 6
        :prompt "FFF "
        :title "Find Files"
        :ui_enabled false
        :layout {:width 0.8
                 :height 0.8
                 :preview_size 0.5
                 :prompt_position "bottom"}
        :preview {:enabled true
                  :max_lines 5000
                  :max_size (* 10 1024 1024)
                  :line_numbers false
                  :wrap_lines false
                  :show_file_info true
                  :binary_file_threshold 1024}
        ;; open is bound globally as <C-F> (utils.files.find_files) in
        ;; lua/config/keymaps.lua [ctrl] block — not self-registered here.
        :keymaps {:close "<Esc>"
                  :select "<CR>"
                  :select_split "<C-s>"
                  :select_vsplit "<C-v>"
                  :select_tab "<C-CR>"
                  :move_up ["<Up>" "<C-p>"]
                  :move_down ["<Down>" "<C-n>"]
                  :preview_scroll_up "<C-u>"
                  :preview_scroll_down "<C-d>"
                  :toggle_debug "<F2>"}
        :frecency {:enabled true
                   :db_path (.. (vim.fn.stdpath :cache) "/fff_nvim")}
        :logging {:enabled false
                  :log_level "info"}
        :icons {:enabled true}
        ;; Directory display options
        :show_hidden false        ; Show hidden files/folders
        :respect_gitignore true   ; Respect .gitignore rules
        :follow_symlinks false}   ; Follow symbolic links
 :config (fn [_ opts]
           ((. (require :fff) :setup) opts))}