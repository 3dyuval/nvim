;; move.nvim — line/char/block relocation. The directional <M-h/a/e/i> keys
;; were freed: <M-h>/<M-i> now drive treewalker fold-walk
;; (fnl/config/keymaps/movement.fnl), <M-a>/<M-e> dropped. Only the <leader>w
;; word moves remain here.
{1 "fedepujol/move.nvim"
 :keys
 [{1 "<leader>wf" 2 ":MoveWord(1)<CR>"  :mode [:n] :desc "Move Word Forward"}
  {1 "<leader>wb" 2 ":MoveWord(-1)<CR>" :mode [:n] :desc "Move Word Backward"}]
 :opts
 {:line  {:enable true :indent true}
  :block {:enable true :indent true}
  :word  {:enable true}
  :char  {:enable true}}}
