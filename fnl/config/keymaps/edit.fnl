;; Buffer-local checkmate.nvim keymaps under the <leader>t prefix.
;; Dumb flat tree: key = lhs char, value = command tail string.
;; rhs = <Cmd>Checkmate <tail><CR>; desc = "Checkmate <tail>".

(local base "Checkmate ")

(fn register [bufnr prefix node]
  (each [key tail (pairs node)]
    (let [lhs (.. prefix key)]
      (if (= (type tail) :string)
          (vim.keymap.set :n lhs (.. "<Cmd>" base tail "<CR>")
                          {:buffer bufnr :silent true :desc (.. base tail)})
          (register bufnr lhs tail)))))

(local tree
  {:<leader>t {:r "create"
               :n "toggle"
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

(vim.api.nvim_create_autocmd :FileType
  {:pattern :markdown
   :group (vim.api.nvim_create_augroup :checkmate_keymaps {:clear true})
   :callback (fn [ev] (register ev.buf "" tree))})
