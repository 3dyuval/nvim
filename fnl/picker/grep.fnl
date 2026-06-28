(local M {})

(local ignore-globs
  ["-g" "!.git" "-g" "!node_modules" "-g" "!dist" "-g" "!build"
   "-g" "!coverage" "-g" "!.DS_Store" "-g" "!.docusaurus" "-g" "!.dart_tool"])

(fn M.grep-in-dir [dir]
  (when (and dir (not= dir ""))
    (let [rel (vim.fn.fnamemodify dir ":~:.")
          label (if (or (= rel "") (= rel ".")) (vim.fn.fnamemodify dir ":t") rel)]
      (Snacks.picker.grep {:cwd dir
                           :cmd :rg
                           :args ignore-globs
                           :title (.. "Grep  " label)
                           :show_empty true
                           :hidden true
                           :ignored true
                           :follow false
                           :supports_live true}))))

(fn M.search-in-directory [picker item]
  (if item
      (M.grep-in-dir (vim.fn.fnamemodify item.file ":p:h"))
      (vim.notify "No item provided" vim.log.levels.WARN)))

(fn M.grep-current-buffer-dir []
  (let [file (vim.api.nvim_buf_get_name 0)
        dir (if (not= file "") (vim.fn.fnamemodify file ":p:h") (vim.fn.getcwd))]
    (M.grep-in-dir dir)))

M
