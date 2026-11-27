;; <leader>y* clipboard / path-copy (migrated from <leader>p in the retired
;; lua/config/keymaps.lua).
(local lset vim.keymap.set)
(local clipboard (require :utils.clipboard))
(local mode [:n :v])

(lset mode :<leader>yc clipboard.copy_file_path {:desc "Copy file path (relative to cwd)"})
(lset mode :<leader>yp clipboard.copy_file_path_from_home {:desc "Copy file path (from home)"})
(lset mode :<leader>yn clipboard.copy_file_name {:desc "Copy file name"})
(lset mode :<leader>ya clipboard.copy_file_path_claude_style {:desc "Copy file w \"@\" prefix"})

(lset mode :<leader>yg
      (fn []
        (let [path (-> (vim.fn.system (.. "git ls-files --full-name "
                                          (vim.fn.shellescape (vim.fn.expand "%:p"))))
                       (: :gsub "\n" ""))]
          (vim.fn.setreg "+" path)
          (vim.notify (.. "Copied: " path) vim.log.levels.INFO)))
      {:desc "Copy file path (relative to git)"})

(lset mode :<leader>yo clipboard.copy_code_path {:desc "Copy object path"})
(lset mode :<leader>yO clipboard.copy_code_path_with_types {:desc "Copy object path (with types)"})
(lset mode :<leader>ys clipboard.copy_path_from_src {:desc "Copy path from src (@/...)"})
(lset mode :<leader>yw ":OpenFileInRepo<CR>" {:desc "Open file in web browser"})
(lset mode :<leader>yl clipboard.copy_file_path_with_line {:desc "Copy file path to clipboard"})
(lset mode :<leader>yL ":YankLineUrl +<CR>" {:desc "Copy file URL with line to clipboard"})
