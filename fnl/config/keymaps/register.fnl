;; Shared keymap registration function
;; Usage: (register prefix tree-table)
;;   prefix: string like "<leader>t" or "<C-r>"
;;   tree: table with nested key/value pairs where values are:
;;     - a string command                -> mapped with an empty desc
;;     - {:cmd <string> :desc <string>}  -> mapped with a description
;;     - a nested table                  -> recursed into
;;   The special key :group holds a which-key label for the prefix and is
;;   skipped during binding.

(fn register [prefix node]
  (each [key val (pairs node)]
    (when (not= key :group)
      (let [lhs (.. prefix key)]
        (if (and (= (type val) :table) val.cmd)
            (vim.keymap.set :n lhs val.cmd {:desc (or val.desc "")})
            (= (type val) :table)
            (register lhs val)
            (vim.keymap.set :n lhs val {:desc ""}))))))

{: register}
