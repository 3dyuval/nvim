;; picker-extensions — shared snacks.nvim picker helpers and actions.
;;
;; Ported from lua. Code-formatting actions (conform) were dropped, along with
;; three referenced-but-undefined functions (git_conflicts_explorer,
;; filter_conflicts_explorer, show_context_menu). Public names stay snake_case
;; because external callers use require("utils.picker-extensions").<name>.
;;
;; The repeated "selected items, else current item" pattern and the eight
;; near-identical context get_items functions collapse into `picker-items`.

(local M {})

;; ── explorer layout state (survives across picker instances this session) ──
(var explorer-layout (or vim.g.explorer_layout "sidebar"))

(fn floating-layout? [preset]
  (or (= preset "default") (= preset "fullscreen")))

(fn preview-for-layout [preset]
  (floating-layout? preset))

(var _path-signal nil)
(fn path-signal []
  (when (not _path-signal)
    (let [(ok t) (pcall require :u.tracker)]
      (when ok
        (set _path-signal (t.create_signal nil)))))
  _path-signal)

;; ── picker validation / safe calls ──────────────────────────────────────
(fn validate-picker [picker]
  (if (and picker (= (type picker) "table"))
      true
      (do (vim.notify "Invalid picker object" vim.log.levels.ERROR) false)))

;; Call picker:method(...) with error handling. Returns (result nil) or (nil err).
(fn safe-call [picker method ...]
  (if (not (validate-picker picker))
      (values nil "Invalid picker")
      (= (type (. picker method)) :function)
      (let [args [...]
            (ok res) (pcall (fn [] ((. picker method) picker (table.unpack args))))]
        (if ok (values res nil) (values nil res)))
      (values nil (.. "Method " method " not available"))))

;; Items for an action: explicit selection, else current item, else list.selected.
(fn picker-items [picker]
  (let [(sel _) (safe-call picker :selected)]
    (if (and sel (> (length sel) 0))
        sel
        (let [(cur _) (safe-call picker :current)]
          (if cur
              [cur]
              (and picker.list picker.list.selected
                   (= (type picker.list.selected) :table)
                   (> (length picker.list.selected) 0))
              picker.list.selected
              [])))))

;; ── open_explorer ─────────────────────────────────────────────────────────
(fn M.open_explorer [opts]
  (let [old-shortmess vim.o.shortmess]
    (set vim.o.shortmess (.. vim.o.shortmess "A"))
    (when (and opts opts.layout opts.layout.preset)
      (set explorer-layout opts.layout.preset)
      (set vim.g.explorer_layout explorer-layout))
    (let [focus-editor (fn [picker]
                         (if (and picker.main (vim.api.nvim_win_is_valid picker.main))
                             (vim.api.nvim_set_current_win picker.main)
                             (vim.cmd "wincmd l")))
          win-override (when (not (floating-layout? explorer-layout))
                         {:input {:keys {"<Esc>" {1 "focus_editor" :mode ["n" "i"]}}}
                          :list {:keys {"<Esc>" "focus_editor"}}})
          config (vim.tbl_deep_extend
                   "force"
                   {:root false
                    :layout {:preset explorer-layout
                             :preview (preview-for-layout explorer-layout)}
                    :auto_close (floating-layout? explorer-layout)
                    :win win-override
                    :actions {:focus_editor {:action focus-editor}}
                    :on_close (fn [picker]
                                (set vim.g.explorer_was_open false)
                                (let [item (picker:current)]
                                  (when (and item (or item.file item.dir))
                                    (let [s (path-signal)]
                                      (when s (s:set (or item.file item.dir)))))))
                    :on_show (fn [picker]
                               (set vim.g.explorer_was_open true)
                               (when (not (floating-layout? explorer-layout))
                                 (let [s (path-signal)
                                       path (and s (s:get))]
                                   (when path
                                     (picker:find
                                       {:on_done (fn []
                                                   (var found false)
                                                   (each [i item (ipairs picker.list.items) &until found]
                                                     (when (and item (or (= item.file path)
                                                                         (= item.dir path)))
                                                       (picker.list:view i)
                                                       (set found true))))})))))}
                   (or opts {}))]
      (Snacks.picker.explorer config)
      (set vim.o.shortmess old-shortmess))))

;; ── current item / branch name ─────────────────────────────────────────────
(fn M.get_current_item [picker]
  (if (not (validate-picker picker))
      (values nil "Invalid picker")
      (do
        (when (= (type picker.current) :function)
          (let [(ok item) (pcall picker.current picker)]
            (when (and ok item) (lua "return item, nil"))))
        (when (and picker.list (= (type picker.list.current) :function))
          (let [(ok item) (pcall picker.list.current picker.list)]
            (when (and ok item) (lua "return item, nil"))))
        (values nil "No current item found"))))

(fn M.get_branch_name [item]
  (if (not item)
      nil
      (and (= (type item) :table) item.branch)
      item.branch
      (and (= (type item) :table) item.text)
      (let [commit-pat (string.rep "[a-z0-9]" 7)
            patterns [(.. "^(.)%s(%b())%s+(" commit-pat ")%s*(.*)$")
                      (.. "^(.)%s(%S+)%s+(" commit-pat ")%s*(.*)$")]]
        (var result nil)
        (each [p pattern (ipairs patterns) &until result]
          (let [(status branch) (item.text:match pattern)]
            (when (and status branch (not (= p 1)))
              (set result branch))))
        (if result
            result
            (let [cleaned (-> item.text (: :gsub "^%s*%*?%s*" "") (: :gsub "%s+$" ""))
                  cleaned (if (cleaned:match "^remotes/")
                              (cleaned:gsub "^remotes/" "")
                              cleaned)
                  branch-only (cleaned:match "^(%S+)")]
              (if (and branch-only (not (= branch-only "")))
                  branch-only
                  nil))))
      (= (type item) :string)
      (let [cleaned (-> item (: :gsub "^%s*%*?%s*" "") (: :gsub "%s+$" "")
                        (: :gsub "^remotes/" ""))]
        (if (not (= cleaned "")) cleaned nil))
      nil))

;; ── explorer actions ───────────────────────────────────────────────────────
(fn M.open_multiple_buffers [picker]
  (when (validate-picker picker)
    (let [(sel err) (safe-call picker :selected)]
      (if err
          (vim.notify (.. "Could not get selected items: " err) vim.log.levels.WARN)
          (let [sel (or sel [])]
            (if (= (length sel) 0)
                (vim.notify "No files selected" vim.log.levels.WARN)
                (do
                  (picker:close)
                  (each [_ item (ipairs sel)]
                    (when (and item item.file)
                      (vim.cmd (.. "edit " (vim.fn.fnameescape item.file)))))
                  (vim.notify (string.format "Opened %d file(s)" (length sel)))))))) ))

(fn M.search_in_directory [picker item]
  (if (not item)
      (vim.notify "No item provided" vim.log.levels.WARN)
      (Snacks.picker.grep
        {:cwd (vim.fn.fnamemodify item.file ":p:h")
         :cmd :rg
         :args ["-g" "!.git" "-g" "!node_modules" "-g" "!dist" "-g" "!build"
                "-g" "!coverage" "-g" "!.DS_Store" "-g" "!.docusaurus" "-g" "!.dart_tool"]
         :show_empty true
         :hidden true
         :ignored true
         :follow false
         :supports_live true})))

(fn M.diff_selected [picker]
  (when (validate-picker picker)
    (picker:close)
    (let [(sel err) (safe-call picker :selected)]
      (if err
          (vim.notify (.. "Could not get selected items: " err) vim.log.levels.WARN)
          (let [sel (or sel [])]
            (if (>= (length sel) 2)
                (do
                  (Snacks.notify.info (. sel 1 :file))
                  (vim.cmd (.. "tabnew " (. sel 1 :file)))
                  (vim.cmd (.. "vert diffs " (. sel 2 :file)))
                  (Snacks.notify.info (.. "Diffing " (. sel 1 :file) " against " (. sel 2 :file))))
                (Snacks.notify.info "Select two entries for the diff")))))))

(fn M.handle_directory_expansion [picker]
  (when (validate-picker picker)
    (let [(item err) (safe-call picker :current)]
      (if err
          (vim.notify (.. "Could not get current item: " err) vim.log.levels.WARN)
          (when (and item item.dir)
            (picker:confirm))))))

;; ── copy file path (explorer) ──────────────────────────────────────────────
(fn M.copy_file_path [picker item]
  (let [(sel err) (safe-call picker :selected)
        items (if (and (not err) sel (> (length sel) 0))
                  sel
                  item
                  [item]
                  nil)]
    (if (not items)
        (vim.notify "No item provided" vim.log.levels.WARN)
        (let [is-multi (> (length items) 1)
              copy-options (if is-multi
                               (let [paths-cwd [] paths-home [] filenames [] paths-abs []]
                                 (each [_ itm (ipairs items)]
                                   (table.insert paths-cwd (vim.fn.fnamemodify itm.file ":."))
                                   (table.insert paths-home (vim.fn.fnamemodify itm.file ":~"))
                                   (table.insert filenames (vim.fn.fnamemodify itm.file ":t"))
                                   (table.insert paths-abs itm.file))
                                 [{:key "cwd" :icon "󰉋" :value (table.concat paths-cwd "\n")}
                                  {:key "tree" :icon "" :value "tree_structure" :items items}
                                  {:key "home" :icon "󰋜" :value (table.concat paths-home "\n")}
                                  {:key "content" :icon "󰈙" :value "file_content_multi" :items items}
                                  {:key "name" :icon "󰈔" :value (table.concat filenames "\n")}
                                  {:key "path" :icon "󰆏" :value (table.concat paths-abs "\n")}
                                  {:key "claude" :icon "" :value "claude_add" :items items}])
                               (let [f (. items 1 :file)]
                                 [{:key "tree" :icon "" :value "tree_structure" :items items}
                                  {:key "cwd" :icon "󰉋" :value (vim.fn.fnamemodify f ":.")}
                                  {:key "home" :icon "󰋜" :value (vim.fn.fnamemodify f ":~")}
                                  {:key "content" :icon "󰈙" :value "file_content" :items items}
                                  {:key "name" :icon "󰈔" :value (vim.fn.fnamemodify f ":t")}
                                  {:key "path" :icon "󰆏" :value f}
                                  {:key "basename" :icon "󰈙" :value (vim.fn.fnamemodify f ":t:r")}
                                  {:key "extension" :icon "󰈙" :value (vim.fn.fnamemodify f ":t:e")}
                                  {:key "uri" :icon "󰌷" :value (vim.uri_from_fname f)}
                                  {:key "claude" :icon "" :value "claude_add" :items items}]))
              menu-options []
              option-map {}]
          (each [_ option (ipairs copy-options)]
            (when (and option.value (not (= option.value "")))
              (table.insert menu-options
                (string.format "%s %s: %s" option.icon option.key option.value))
              (tset option-map (length menu-options) option)))
          (if (= (length menu-options) 0)
              (vim.notify "No values to copy" vim.log.levels.WARN)
              (vim.ui.select menu-options
                {:prompt "Choose to copy to clipboard:"
                 :format_item (fn [list-item] list-item)}
                (fn [choice idx]
                  (when (and choice idx (. option-map idx))
                    (let [opt (. option-map idx)]
                      (M._copy_path_apply picker opt is-multi)))))))) ))

;; Apply a chosen copy option (content / tree / claude / plain value).
(fn M._copy_path_apply [picker opt is-multi]
  (let [result opt.value]
    (if (= opt.key "content")
        (let [all-contents [] ]
          (var total-lines 0)
          (var file-count 0)
          (var aborted false)
          (each [_ itm (ipairs opt.items) &until aborted]
            (if (or itm.dir (= (vim.fn.isdirectory itm.file) 1))
                (let [dir-files (vim.fn.readdir itm.file
                                  (fn [name]
                                    (= (vim.fn.filereadable (.. itm.file "/" name)) 1)))]
                  (each [_ fname (ipairs dir-files)]
                    (let [fpath (.. itm.file "/" fname)
                          content (vim.fn.readfile fpath)
                          rel-path (vim.fn.fnamemodify fpath ":.")]
                      (set total-lines (+ total-lines (length content)))
                      (set file-count (+ file-count 1))
                      (table.insert all-contents rel-path)
                      (table.insert all-contents (.. "--- " rel-path " ---"))
                      (table.insert all-contents (table.concat content "\n")))))
                (if (= (vim.fn.filereadable itm.file) 0)
                    (do
                      (vim.notify (.. "File not readable: " itm.file) vim.log.levels.ERROR)
                      (set aborted true))
                    (let [content (vim.fn.readfile itm.file)
                          rel-path (vim.fn.fnamemodify itm.file ":.")]
                      (set total-lines (+ total-lines (length content)))
                      (set file-count (+ file-count 1))
                      (if is-multi
                          (do
                            (table.insert all-contents rel-path)
                            (table.insert all-contents (.. "--- " rel-path " ---"))
                            (table.insert all-contents (table.concat content "\n")))
                          (do
                            (table.insert all-contents rel-path)
                            (table.insert all-contents (table.concat content "\n"))))))))
          (when (not aborted)
            (if (= file-count 0)
                (vim.notify "No files to copy" vim.log.levels.WARN)
                (do
                  (vim.fn.setreg "+" (table.concat all-contents "\n"))
                  (Snacks.notify.info
                    (string.format "Copied %d file(s) to clipboard (%d lines)" file-count total-lines))))))
        (= opt.key "tree")
        (M._copy_tree opt)
        (= opt.key "claude")
        (let [claudecode (require :claudecode)]
          (var count 0)
          (each [_ itm (ipairs opt.items)]
            (when (and itm.file (not (= itm.file "")))
              (claudecode.send_at_mention itm.file nil nil "snacks_picker")
              (set count (+ count 1))))
          (Snacks.notify.info (string.format "Added %d file(s) to Claude" count)))
        (do
          (vim.fn.setreg "+" result)
          (Snacks.notify.info (.. "Yanked `" result "`"))))))

(fn M._copy_tree [opt]
  (let [items opt.items
        items-count (length items)
        single-dir (and (= items-count 1)
                        (or (. items 1 :dir)
                            (= (vim.fn.isdirectory (. items 1 :file)) 1)))]
    (if single-dir
        (let [tree-output (vim.fn.system (.. "tree " (vim.fn.shellescape (. items 1 :file))))]
          (if (not (= vim.v.shell_error 0))
              (vim.notify "Failed to run tree command" vim.log.levels.ERROR)
              (do
                (vim.fn.setreg "+" tree-output)
                (Snacks.notify.info "Tree structure copied to clipboard"))))
        (let [file-paths []]
          (each [_ itm (ipairs items)]
            (when (not (or itm.dir (= (vim.fn.isdirectory itm.file) 1)))
              (table.insert file-paths (vim.fn.fnamemodify itm.file ":."))))
          (if (= (length file-paths) 0)
              (vim.notify "No files to show in tree" vim.log.levels.WARN)
              (let [tree {}]
                (each [_ fpath (ipairs file-paths)]
                  (var current tree)
                  (each [_ part (ipairs (vim.split fpath "/" {:plain true}))]
                    (when (not (. current part)) (tset current part {}))
                    (set current (. current part))))
                (fn render-tree [node prefix]
                  (let [lines []
                        keys (vim.tbl_keys node)]
                    (table.sort keys)
                    (each [idx key (ipairs keys)]
                      (let [is-last (= idx (length keys))
                            connector (if is-last "└── " "├── ")
                            child-prefix (if is-last "    " "│   ")
                            is-leaf (vim.tbl_isempty (. node key))
                            suffix (if is-leaf "" "/")]
                        (table.insert lines (.. prefix connector key suffix))
                        (when (not is-leaf)
                          (each [_ line (ipairs (render-tree (. node key) (.. prefix child-prefix)))]
                            (table.insert lines line)))))
                    lines))
                (let [tree-lines ["."]]
                  (each [_ line (ipairs (render-tree tree ""))]
                    (table.insert tree-lines line))
                  (vim.fn.setreg "+" (table.concat tree-lines "\n"))
                  (Snacks.notify.info "Tree structure copied to clipboard"))))))))

;; ── context detection ──────────────────────────────────────────────────────
;; Each context: detect(picker) -> bool. Items come from the shared picker-items.
(fn action-count [picker]
  (var n 0)
  (when (and picker.opts picker.opts.actions)
    (each [_ _ (pairs picker.opts.actions)] (set n (+ n 1))))
  n)

(fn has-explorer-actions? [picker ...]
  (and picker.opts picker.opts.actions
       (let [names [...]]
         (var found false)
         (each [_ name (ipairs names) &until found]
           (when (. picker.opts.actions name) (set found true)))
         found)))

(local contexts
  {:sidebar_explorer
   {:detect (fn [picker]
              (and (validate-picker picker)
                   picker.opts picker.opts.actions
                   picker.opts.actions.explorer_add picker.opts.actions.list_down
                   (< (action-count picker) 10)))}
   :explorer
   {:detect (fn [picker]
              (and (validate-picker picker)
                   (has-explorer-actions? picker :explorer_add :explorer_del :explorer_open
                                          :explorer_rename :explorer_close :explorer_up :explorer_focus)
                   (>= (action-count picker) 5)))}
   :git_status
   {:detect (fn [picker]
              (if (not (validate-picker picker))
                  false
                  (= (and picker.opts picker.opts.source) "git_status")
                  true
                  (not (has-explorer-actions? picker :explorer_add :explorer_del :explorer_open))
                  (let [(cur err) (safe-call picker :current)]
                    (and (not err) cur cur.status cur.file (not cur.dir)
                         (cur.status:match "^[MADRCU?!]") true))
                  false))}
   :files
   {:detect (fn [picker]
              (if (not (validate-picker picker))
                  false
                  (let [source (and picker.opts picker.opts.source)]
                    (if (or (= source "files") (= source "git_files"))
                        true
                        (not (has-explorer-actions? picker :explorer_add :explorer_del))
                        (let [(cur err) (safe-call picker :current)]
                          (and (not err) cur cur.file (not cur.dir) true))
                        false))))}
   :buffers
   {:detect (fn [picker]
              (if (not (validate-picker picker))
                  false
                  (= (and picker.opts picker.opts.source) "buffers")
                  true
                  (let [(cur err) (safe-call picker :current)]
                    (and (not err) cur cur.bufnr true))))}
   :lsp_symbols
   {:detect (fn [picker]
              (if (not (validate-picker picker))
                  false
                  (let [source (and picker.opts picker.opts.source)]
                    (if (or (= source "lsp_symbols") (= source "lsp_workspace_symbols"))
                        true
                        (let [(cur err) (safe-call picker :current)]
                          (and (not err) cur (or cur.kind cur.symbol cur.lnum) true))))))}
   :grep
   {:detect (fn [picker]
              (if (not (validate-picker picker))
                  false
                  (let [source (and picker.opts picker.opts.source)]
                    (if (or (= source "grep") (= source "grep_word") (= source "grep_buffers"))
                        true
                        (let [(cur err) (safe-call picker :current)]
                          (and (not err) cur cur.line cur.file cur.pos true))))))}
   :git_branches
   {:detect (fn [picker]
              (if (not (validate-picker picker))
                  false
                  (= (and picker.opts picker.opts.source) "git_branches")
                  true
                  (let [(cur err) (M.get_current_item picker)]
                    (if (or err (not cur) (not (= (type cur) :table)))
                        false
                        (or cur.branch cur.commit (not (= cur.current nil)) (not (= cur.detached nil)))
                        true
                        cur.text
                        (let [commit-pat (string.rep "[a-z0-9]" 7)
                              patterns [(.. "^(.)%s(%b())%s+(" commit-pat ")%s*(.*)$")
                                        (.. "^(.)%s(%S+)%s+(" commit-pat ")%s*(.*)$")]]
                          (var matched false)
                          (each [_ pattern (ipairs patterns) &until matched]
                            (when (cur.text:match pattern) (set matched true)))
                          matched)
                        false))))}})

(local context-order
  [:sidebar_explorer :explorer :git_branches :git_status :lsp_symbols :grep :buffers :files])

(fn detect-context [picker]
  (if (not (validate-picker picker))
      (values "unknown" nil)
      (do
        (var found-name "unknown")
        (var found-ctx nil)
        (each [_ name (ipairs context-order) &until found-ctx]
          (let [ctx (. contexts name)]
            (when (and ctx (ctx.detect picker))
              (set found-name name)
              (set found-ctx ctx))))
        (if found-ctx
            (values found-name found-ctx)
            (let [(cur err) (safe-call picker :current)]
              (if (and (not err) cur cur.bufnr)
                  (values "buffers" (. contexts :buffers))
                  (and (not err) cur cur.file)
                  (values "files" (. contexts :files))
                  (values "unknown" nil)))))))

;; ── context-menu action tables (non-format) ────────────────────────────────
(fn confirm-rename [picker item]
  (let [new-name (vim.fn.input "Rename to: " (vim.fn.fnamemodify item.file ":t"))]
    (when (and new-name (not (= new-name "")))
      (let [new-path (.. (vim.fn.fnamemodify item.file ":h") "/" new-name)]
        (Snacks.rename.rename_file
          {:from item.file :to new-path
           :on_rename (fn [to from ok]
                        (when ok
                          (vim.notify (.. "Renamed to " new-name))
                          (when picker.refresh (picker:refresh))))})))))

;; ── context menu (vim.ui.select) ───────────────────────────────────────────
(fn M.context_menu [picker item]
  (if (not item)
      (vim.notify "No item available" vim.log.levels.WARN)
      (let [menu-title (if item.dir
                           (.. "󰈔 " (vim.fn.fnamemodify item.file ":t") " (Directory)")
                           (.. "󰈙 " (vim.fn.fnamemodify item.file ":t")))
            options [] acts []]
        (table.insert options "󰑕 Rename")
        (table.insert acts (fn [] (confirm-rename picker item)))
        (table.insert options "󰆴 Delete")
        (table.insert acts (fn []
                             (when (= (vim.fn.confirm "Delete 1 items?" "&Yes\n&No" 1) 1)
                               (if item.dir (vim.fn.delete item.file "rf") (os.remove item.file))
                               (vim.notify "Deleted 1 items")
                               (when picker.refresh (picker:refresh)))))
        (let [selected (picker:selected)
              claude-label (if (> (length selected) 1)
                               (.. " Add " (length selected) " files to Claude")
                               " Add to Claude")]
          (table.insert options claude-label)
          (table.insert acts (fn [] (M.claude_add_tree picker item))))
        (vim.ui.select options
          {:prompt (.. menu-title " - Choose action:")
           :format_item (fn [i] i)}
          (fn [choice idx]
            (when (and choice idx (. acts idx))
              ((. acts idx))))))))

(fn M.git_context_menu [picker item]
  (if (not item)
      (vim.notify "No item available" vim.log.levels.WARN)
      (let [menu-title (.. "󰈙 " (vim.fn.fnamemodify item.file ":t") " (Git)")
            options [] acts []]
        (table.insert options "󰊢 Stage/Unstage")
        (table.insert acts (fn []
                             (let [file item.file]
                               (if (and item.status
                                        (or (item.status:match "^M") (item.status:match "^A") (item.status:match "^D")))
                                   (vim.system ["git" "restore" "--staged" file])
                                   (vim.system ["git" "add" file])))
                             (vim.notify "Toggled stage status for 1 files")
                             (when picker.refresh (picker:refresh))))
        (table.insert options "󰆏 Copy Path")
        (table.insert acts (fn []
                             (vim.fn.setreg "+" item.file)
                             (vim.notify "Copied 1 paths")))
        (vim.ui.select options
          {:prompt (.. menu-title " - Choose action:")
           :format_item (fn [i] i)}
          (fn [choice idx]
            (when (and choice idx (. acts idx))
              ((. acts idx))))))))

(fn M.buffer_context_menu [picker item]
  (if (not item)
      (vim.notify "No item available" vim.log.levels.WARN)
      (let [menu-title (.. "󰈙 " (or item.name (vim.fn.fnamemodify (vim.api.nvim_buf_get_name (or item.bufnr 0)) ":t")))
            buf-path (fn []
                       (when (and item.bufnr (vim.api.nvim_buf_is_loaded item.bufnr))
                         (let [fp (vim.api.nvim_buf_get_name item.bufnr)]
                           (when (and fp (not (= fp ""))) fp))))
            options [] acts []]
        (table.insert options "󰆏 Copy Path")
        (table.insert acts (fn []
                             (let [fp (buf-path)]
                               (vim.fn.setreg "+" (or fp ""))
                               (vim.notify "Copied 1 paths"))))
        (table.insert options "󰖭 Delete Buffer")
        (table.insert acts (fn []
                             (when item.bufnr (vim.api.nvim_buf_delete item.bufnr {:force false}))
                             (vim.notify "Deleted 1 buffers")
                             (when picker.refresh (picker:refresh))))
        (table.insert options "󰆓 Save Buffer")
        (table.insert acts (fn []
                             (when (and item.bufnr (vim.api.nvim_buf_is_loaded item.bufnr))
                               (pcall (fn [] (vim.api.nvim_buf_call item.bufnr (fn [] (vim.cmd "write"))))))
                             (vim.notify "Saved buffer")))
        (vim.ui.select options
          {:prompt (.. menu-title " - Choose action:")
           :format_item (fn [i] i)}
          (fn [choice idx]
            (when (and choice idx (. acts idx))
              ((. acts idx))))))))

;; ── duplicate ──────────────────────────────────────────────────────────────
(fn M.duplicate_file [picker item]
  (if (not item)
      (vim.notify "No item provided" vim.log.levels.WARN)
      (let [source item.file
            source-name (vim.fn.fnamemodify source ":t")
            source-dir (vim.fn.fnamemodify source ":h")
            source-ext (vim.fn.fnamemodify source ":e")
            source-base (vim.fn.fnamemodify source ":t:r")
            default-name (if item.dir
                             (.. source-name "_copy")
                             (not (= source-ext ""))
                             (.. source-base "_copy." source-ext)
                             (.. source-name "_copy"))
            new-name (vim.fn.input "Duplicate as: " default-name)]
        (when (and new-name (not (= new-name "")))
          (let [target (.. source-dir "/" new-name)]
            (if (or (= (vim.fn.filereadable target) 1) (= (vim.fn.isdirectory target) 1))
                (vim.notify (.. "Target already exists: " new-name) vim.log.levels.ERROR)
                (let [cmd (if item.dir ["cp" "-r" source target] ["cp" source target])
                      result (vim.fn.system cmd)
                      label (if item.dir "directory" "file")]
                  (if (= vim.v.shell_error 0)
                      (do
                        (vim.notify (.. "Duplicated " label ": " new-name))
                        (when picker.refresh (picker:refresh)))
                      (vim.notify (.. "Failed to duplicate " label ": " (or result "unknown error"))
                                  vim.log.levels.ERROR)))))))))

;; ── copy references (lsp) ──────────────────────────────────────────────────
(fn M.copy_references [picker]
  (let [selected (picker:selected)
        items (if (and selected (> (length selected) 0)) selected (picker:items))]
    (if (or (not items) (= (length items) 0))
        (vim.notify "No references to copy" vim.log.levels.WARN)
        (let [full-refs [] short-refs [] paths-only [] seen-paths {}]
          (each [_ item (ipairs items)]
            (let [rel-path (vim.fn.fnamemodify item.file ":~:.")]
              (if item.pos
                  (do
                    (table.insert full-refs (string.format "%s:%d:%d" rel-path (. item.pos 1) (. item.pos 2)))
                    (table.insert short-refs (string.format "%s:%d" rel-path (. item.pos 1))))
                  (do
                    (table.insert full-refs rel-path)
                    (table.insert short-refs rel-path)))
              (when (not (. seen-paths item.file))
                (tset seen-paths item.file true)
                (table.insert paths-only rel-path))))
          (let [copy-options [{:key "full" :icon "󰆏" :desc "file:line:col" :value (table.concat full-refs "\n")}
                              {:key "short" :icon "󰉋" :desc "file:line" :value (table.concat short-refs "\n")}
                              {:key "paths" :icon "󰈔" :desc "unique paths" :value (table.concat paths-only "\n")}]
                menu-options []]
            (each [i opt (ipairs copy-options)]
              (tset menu-options i (string.format "%s %s (%s)" opt.icon opt.key opt.desc)))
            (vim.ui.select menu-options {:prompt "Copy references:"}
              (fn [_ idx]
                (when (and idx (. copy-options idx))
                  (vim.fn.setreg "+" (. copy-options idx :value))
                  (vim.notify (string.format "Copied %d references (%s)" (length items) (. copy-options idx :key))
                              vim.log.levels.INFO)))))))))

;; ── generalized copy ───────────────────────────────────────────────────────
(fn get-symbol-path [item]
  (let [parts []]
    (var current item)
    (while current
      (when (or current.text current.name)
        (table.insert parts 1 (or current.text current.name)))
      (set current current.parent))
    (table.concat parts ".")))

(fn get-copy-options [ctx _picker items]
  (let [is-multi (> (length items) 1)]
    (if (or (= ctx "explorer") (= ctx "files"))
        (if is-multi
            (let [paths-cwd [] paths-home [] filenames [] paths-abs []]
              (each [_ item (ipairs items)]
                (table.insert paths-cwd (vim.fn.fnamemodify item.file ":."))
                (table.insert paths-home (vim.fn.fnamemodify item.file ":~"))
                (table.insert filenames (vim.fn.fnamemodify item.file ":t"))
                (table.insert paths-abs item.file))
              [{:label "Relative paths" :value (table.concat paths-cwd "\n") :icon "󰉋"}
               {:label "From home" :value (table.concat paths-home "\n") :icon "󰋜"}
               {:label "Filenames" :value (table.concat filenames "\n") :icon "󰈔"}
               {:label "Absolute paths" :value (table.concat paths-abs "\n") :icon "󰆏"}])
            (let [f (. items 1 :file)]
              [{:label "Relative path" :value (vim.fn.fnamemodify f ":.") :icon "󰉋"}
               {:label "From home" :value (vim.fn.fnamemodify f ":~") :icon "󰋜"}
               {:label "Filename" :value (vim.fn.fnamemodify f ":t") :icon "󰈔"}
               {:label "Absolute path" :value f :icon "󰆏"}
               {:label "Basename" :value (vim.fn.fnamemodify f ":t:r") :icon "󰈙"}
               {:label "Extension" :value (vim.fn.fnamemodify f ":e") :icon "󰈙"}]))
        (= ctx "lsp_symbols")
        (if is-multi
            (let [names [] locations []]
              (each [_ item (ipairs items)]
                (table.insert names (or item.text item.name ""))
                (when (and item.file item.pos)
                  (table.insert locations (string.format "%s:%d" (vim.fn.fnamemodify item.file ":.") (. item.pos 1)))))
              [{:label "Symbol names" :value (table.concat names "\n") :icon "󰊕"}
               {:label "File:line locations" :value (table.concat locations "\n") :icon "󰆏"}])
            (let [item (. items 1)
                  name (or item.text item.name "")
                  symbol-path (get-symbol-path item)
                  options [{:label "Symbol name" :value name :icon "󰊕"}]]
              (when (and (not (= symbol-path name)) (not (= symbol-path "")))
                (table.insert options {:label "Symbol path" :value symbol-path :icon "󰙅"}))
              (when (and item.file item.pos)
                (table.insert options {:label "File:line"
                                       :value (string.format "%s:%d" (vim.fn.fnamemodify item.file ":.") (. item.pos 1))
                                       :icon "󰆏"})
                (table.insert options {:label "File:symbol"
                                       :value (string.format "%s:%s" (vim.fn.fnamemodify item.file ":.") name)
                                       :icon "󰈔"}))
              options))
        (= ctx "grep")
        (if is-multi
            (let [locations [] lines [] paths [] seen-paths {}]
              (each [_ item (ipairs items)]
                (when (and item.file item.pos)
                  (table.insert locations (string.format "%s:%d" (vim.fn.fnamemodify item.file ":.") (. item.pos 1))))
                (if item.line (table.insert lines item.line) item.text (table.insert lines item.text))
                (when (and item.file (not (. seen-paths item.file)))
                  (tset seen-paths item.file true)
                  (table.insert paths (vim.fn.fnamemodify item.file ":."))))
              [{:label "File:line locations" :value (table.concat locations "\n") :icon "󰆏"}
               {:label "Matched lines" :value (table.concat lines "\n") :icon "󰈙"}
               {:label "Unique paths" :value (table.concat paths "\n") :icon "󰉋"}])
            (let [item (. items 1) options []]
              (when (and item.file item.pos)
                (table.insert options {:label "File:line"
                                       :value (string.format "%s:%d" (vim.fn.fnamemodify item.file ":.") (. item.pos 1))
                                       :icon "󰆏"}))
              (if item.line (table.insert options {:label "Matched line" :value item.line :icon "󰈙"})
                  item.text (table.insert options {:label "Matched text" :value item.text :icon "󰈙"}))
              (when item.file
                (table.insert options {:label "File path" :value (vim.fn.fnamemodify item.file ":.") :icon "󰉋"}))
              options))
        (= ctx "git_branches")
        (if is-multi
            (let [names []]
              (each [_ item (ipairs items)]
                (let [branch (M.get_branch_name item)]
                  (when branch (table.insert names branch))))
              [{:label "Branch names" :value (table.concat names "\n") :icon ""}])
            (let [branch (M.get_branch_name (. items 1))]
              (if branch
                  (let [options [{:label "Branch name" :value branch :icon ""}]]
                    (when (branch:match "/")
                      (let [(remote name) (branch:match "^([^/]+)/(.+)$")]
                        (when (and remote name)
                          (table.insert options {:label "Remote branch" :value branch :icon "󰊢"})
                          (table.insert options {:label "Branch only" :value name :icon ""}))))
                    options)
                  [])))
        (= ctx "git_status")
        (if is-multi
            (let [paths []]
              (each [_ item (ipairs items)]
                (table.insert paths (vim.fn.fnamemodify item.file ":.")))
              [{:label "File paths" :value (table.concat paths "\n") :icon "󰉋"}])
            (let [item (. items 1)
                  options [{:label "File path" :value (vim.fn.fnamemodify item.file ":.") :icon "󰉋"}]]
              (when item.status
                (table.insert options {:label "Status" :value item.status :icon "󰊢"}))
              options))
        (= ctx "buffers")
        (if is-multi
            (let [paths [] names []]
              (each [_ item (ipairs items)]
                (let [bufname (or item.file (and item.bufnr (vim.api.nvim_buf_get_name item.bufnr)) "")]
                  (when (not (= bufname ""))
                    (table.insert paths (vim.fn.fnamemodify bufname ":."))
                    (table.insert names (vim.fn.fnamemodify bufname ":t")))))
              [{:label "File paths" :value (table.concat paths "\n") :icon "󰉋"}
               {:label "Buffer names" :value (table.concat names "\n") :icon "󰈔"}])
            (let [item (. items 1)
                  bufname (or item.file (and item.bufnr (vim.api.nvim_buf_get_name item.bufnr)) "")]
              (if (not (= bufname ""))
                  [{:label "File path" :value (vim.fn.fnamemodify bufname ":.") :icon "󰉋"}
                   {:label "Buffer name" :value (vim.fn.fnamemodify bufname ":t") :icon "󰈔"}
                   {:label "Absolute path" :value bufname :icon "󰆏"}]
                  [])))
        ;; default/unknown
        (if is-multi
            (let [texts [] files [] options []]
              (each [_ item (ipairs items)]
                (when item.text (table.insert texts item.text))
                (when item.file (table.insert files (vim.fn.fnamemodify item.file ":."))))
              (when (> (length texts) 0)
                (table.insert options {:label "Text" :value (table.concat texts "\n") :icon "󰈙"}))
              (when (> (length files) 0)
                (table.insert options {:label "Files" :value (table.concat files "\n") :icon "󰉋"}))
              options)
            (let [item (. items 1) options []]
              (when item.text (table.insert options {:label "Text" :value item.text :icon "󰈙"}))
              (when item.file (table.insert options {:label "File" :value (vim.fn.fnamemodify item.file ":.") :icon "󰉋"}))
              options)))))

(fn M.copy [picker item]
  (let [(ctx _context) (detect-context picker)
        items (let [its (picker-items picker)]
                (if (> (length its) 0) its (if item [item] [])))]
    (if (= (length items) 0)
        (vim.notify "No items to copy" vim.log.levels.WARN)
        (let [options (get-copy-options ctx picker items)]
          (if (= (length options) 0)
              (vim.notify "No copy options available" vim.log.levels.WARN)
              (let [menu-items []]
                (each [i opt (ipairs options)]
                  (var preview opt.value)
                  (when (> (length preview) 40)
                    (set preview (.. (preview:sub 1 37) "...")))
                  (set preview (preview:gsub "\n" " ↵ "))
                  (tset menu-items i (string.format "%s %s: %s" (or opt.icon "󰆏") opt.label preview)))
                (vim.ui.select menu-items {:prompt (string.format "Copy (%s):" ctx)}
                  (fn [_ idx]
                    (when (and idx (. options idx))
                      (vim.fn.setreg "+" (. options idx :value))
                      (let [count-info (if (> (length items) 1) (string.format " (%d items)" (length items)) "")]
                        (Snacks.notify.info (.. "Copied: " (. options idx :label) count-info))))))))))) )

;; ── layout / tree toggles ──────────────────────────────────────────────────
(fn M.get_explorer_layout [] explorer-layout)

(fn M.toggle_layout [picker]
  (let [new-layout (if (= explorer-layout "sidebar") "default" "sidebar")]
    (set explorer-layout new-layout)
    (set vim.g.explorer_layout new-layout)
    (let [layout (Snacks.picker.config.layout
                   {:layout {:preset new-layout :preview (preview-for-layout new-layout)}})]
      (picker:set_layout layout)
      (set picker.opts.preview (preview-for-layout new-layout))
      (set picker.opts.auto_close (= new-layout "default")))))

(fn M.toggle_tree [picker]
  (when (and picker picker.opts)
    (let [new-tree (not picker.opts.tree)]
      (set picker.opts.tree new-tree)
      (set picker._tree_mode new-tree)
      (set picker.opts.formatters (or picker.opts.formatters {}))
      (set picker.opts.formatters.file (or picker.opts.formatters.file {}))
      (set picker.opts.formatters.file.filename_only new-tree)
      (when (not new-tree)
        (let [(ok Tree) (pcall require :snacks.explorer.tree)]
          (when ok
            (let [root (Tree:find (picker:cwd))]
              (when root
                (Tree:walk root
                  (fn [node]
                    (when node.dir (set node.open true) (Tree:expand node)))
                  {:all true}))))))
      (picker.list:set_target)
      (picker:find))))

(fn M.format_file_tree_aware [item picker]
  (let [original-parent item.parent]
    (when (= picker._tree_mode false)
      (set item.parent nil))
    (let [ret (Snacks.picker.format.file item picker)]
      (set item.parent original-parent)
      ret)))

;; ── confirm with multi-select warning ──────────────────────────────────────
(fn M.confirm_multi [picker item action]
  (if (and item item.dir)
      (let [Tree (require :snacks.explorer.tree)]
        (Tree:toggle item.file)
        ((. (require :snacks.explorer.actions) :update) picker {:refresh true}))
      (let [selected (picker:selected)]
        (if (> (length selected) 1)
            (let [files []]
              (each [i sel (ipairs selected)]
                (when (<= i 5)
                  (table.insert files (.. "  " (if sel.file (vim.fn.fnamemodify sel.file ":t") sel.text)))))
              (when (> (length selected) 5)
                (table.insert files (.. "  ... and " (- (length selected) 5) " more")))
              (let [msg (.. "Open " (length selected) " files?\n" (table.concat files "\n"))]
                (vim.ui.select ["Yes" "No"] {:prompt msg}
                  (fn [choice]
                    (when (= choice "Yes")
                      (Snacks.picker.actions.confirm picker item (or action {})))))))
            (let [main-win picker.main
                  has-winfixbuf (and main-win (vim.api.nvim_win_is_valid main-win) (. vim.wo main-win :winfixbuf))]
              (if has-winfixbuf
                  (do
                    (picker:close)
                    (when (and item item.file)
                      (vim.cmd (.. "split " (vim.fn.fnameescape item.file)))))
                  (= explorer-layout "default")
                  (let [file (and item item.file)]
                    (picker:close)
                    (when file (vim.cmd (.. "edit " (vim.fn.fnameescape file)))))
                  (Snacks.picker.actions.confirm picker item (or action {}))))))))

(fn M.claude_add_tree [picker _item]
  (let [claudecode (require :claudecode)]
    (each [_ selected (ipairs (picker:selected {:fallback true}))]
      (let [path (Snacks.picker.util.path selected)]
        (when path
          (claudecode.send_at_mention path nil nil "snacks_picker"))))))

;; ── exported actions table (consumed by snacks.lua) ────────────────────────
(set M.actions
  {:open_multiple_buffers M.open_multiple_buffers
   :copy_file_path M.copy_file_path
   :copy M.copy
   :copy_references M.copy_references
   :search_in_directory M.search_in_directory
   :diff_selected M.diff_selected
   :handle_directory_expansion M.handle_directory_expansion
   :duplicate_file M.duplicate_file
   :claude_add_tree M.claude_add_tree
   :context_menu M.context_menu
   :git_context_menu M.git_context_menu
   :buffer_context_menu M.buffer_context_menu
   :toggle_tree M.toggle_tree
   :toggle_layout M.toggle_layout
   :confirm_multi M.confirm_multi})

M
