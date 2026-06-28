;; Shared keymap registration function
;; Usage: (register prefix tree-table)
;;   prefix: string like "<leader>t" or "<C-r>"
;;   tree: table with nested key/value pairs where values are commands or nested tables

(fn register [prefix node]
  (each [key val (pairs node)]
    (let [lhs (.. prefix key)]
      (if (= (type val) :table)
          (register lhs val)
          (vim.keymap.set :n lhs val {:desc ""})))))

{: register}
