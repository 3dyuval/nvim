;; nvim-ufo — fold provider (treesitter/LSP/indent) with pretty fold text.
;; Fold COMMANDS are deliberately left native: zR/zr/zM/zm and zH/zI
;; (fnl/config/keymaps/movement.fnl) act on Vim's own fold machinery, not
;; ufo's, so they stay consistent with the treewalker fold-walk (<M-h>/<M-i>)
;; which uses native zo/zc. No `config` fn needed — lazy runs ufo.setup(opts).
(fn provider-selector [_bufnr filetype _buftype]
  (if (or (= filetype :typescript) (= filetype :typescriptreact))
      [:lsp :indent]
      ;; gitcommit (fugitive/neogit): gitcommit TS parser may be absent, so
      ;; fall back to indent folding for diff hunks.
      (= filetype :gitcommit)
      [:indent]
      [:treesitter :indent]))

;; Fold virt-text: keep the fold's text, append " 󰁂 <lines> " right-aligned.
(fn fold-virt-text-handler [virt-text lnum end-lnum width truncate]
  (let [new-virt-text []
        suffix-fmt (string.format " 󰁂 %d " (- end-lnum lnum))
        suf-width (vim.fn.strdisplaywidth suffix-fmt)
        target-width (- width suf-width)]
    (var suffix suffix-fmt)
    (var cur-width 0)
    (each [_ chunk (ipairs virt-text)]
      (let [chunk-text (. chunk 1)
            chunk-width (vim.fn.strdisplaywidth chunk-text)]
        (if (> target-width (+ cur-width chunk-width))
            (do
              (table.insert new-virt-text chunk)
              (set cur-width (+ cur-width chunk-width)))
            (let [trimmed (truncate chunk-text (- target-width cur-width))
                  hl-group (. chunk 2)
                  trimmed-width (vim.fn.strdisplaywidth trimmed)]
              (table.insert new-virt-text [trimmed hl-group])
              (when (< (+ cur-width trimmed-width) target-width)
                (set suffix (.. suffix (string.rep " " (- target-width cur-width trimmed-width)))))
              (lua "break")))))
    (table.insert new-virt-text [suffix :MoreMsg])
    new-virt-text))

{1 "kevinhwang91/nvim-ufo"
 :dependencies ["kevinhwang91/promise-async"]
 :event "BufReadPost"
 :opts
 {:provider_selector provider-selector
  ;; Auto-fold imports when the buffer opens.
  :close_fold_kinds_for_ft {:default [:imports]
                            :typescript [:imports]
                            :typescriptreact [:imports]}
  :enable_get_fold_virt_text true
  :preview {:mappings {:scrollB "" :scrollF "" :scrollU "" :scrollD ""
                       :scrollE "" :scrollY "" :jump "" :close "q"}}
  :fold_virt_text_handler fold-virt-text-handler}}
