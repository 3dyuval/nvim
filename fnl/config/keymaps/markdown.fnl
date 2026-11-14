;; Buffer-local checkmate.nvim keymaps under the <leader>t prefix.
;; Dumb flat tree: key = lhs char, value = command tail string.
;; rhs = <Cmd>Checkmate <tail><CR>; desc = "Checkmate <tail>".

(local base "Checkmate ")

(fn register-checkmate [bufnr prefix node]
  (each [key tail (pairs node)]
    (let [lhs (.. prefix key)]
      (if (= (type tail) :string)
          (vim.keymap.set :n lhs (.. "<Cmd>" base tail "<CR>")
                          {:buffer bufnr :silent true :desc (.. base tail)})
          (register-checkmate bufnr lhs tail)))))

(local tree
  {:<leader>t {:t "create"
               :<CR> "toggle"
               :y "check"
               :x "uncheck"
               :c "archive"
               :l "lint"
               "=" "cycle_next"
               "-" "cycle_previous"
               :X "remove_all_metadata"
               "]" "metadata jump_next"
               "[" "metadata jump_previous"
               :v "metadata select_value"}})

;; Link maps from markdown.nvim (gl/gliw), moved out of the lazy keys spec.
(fn register-links [bufnr]
  (vim.keymap.set :n :<leader>tl :gliw
                  {:buffer bufnr :desc "Add link to word"})
  (vim.keymap.set :v :<leader>tl :gl
                  {:buffer bufnr :desc "Add link (visual)"}))

(local group (vim.api.nvim_create_augroup :checkmate_keymaps {:clear true}))

;; Checkmate commands only make sense in markdown.
(vim.api.nvim_create_autocmd :FileType
  {:pattern :markdown
   :group group
   :callback (fn [ev] (register-checkmate ev.buf "" tree))})

;; markdown.nvim link maps span the wider text filetypes the plugin loads on.
(vim.api.nvim_create_autocmd :FileType
  {:pattern [:markdown :text :feature :gitcommit]
   :group group
   :callback (fn [ev] (register-links ev.buf))})
