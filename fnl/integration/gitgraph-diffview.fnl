;; Gitgraph + Diffview Integration
;; Stateful view recipe: syncs gitgraph with diffview selection changes

(local M {})

(var current-file nil)
(var current-rev nil)
(var gitgraph-open false)

;; Get the selected file from diffview
;; @param view DiffView object from hook
;; @return string|nil
(fn get-selected-file [view]
  (when (and view view.panel)
    (let [selected view.panel.selected_files]
      (when (and selected (next selected))
        (next selected)))))

;; Open or refresh gitgraph for the current file
(fn M.open-graph []
  (when current-file
    (let [(ok gitgraph) (pcall require :gitgraph)]
      (if ok
        (do
          (gitgraph.open_with_file current-file)
          (set gitgraph-open true))
        (vim.notify "gitgraph.nvim not installed" vim.log.levels.WARN)))))

;; Called when diffview selection changes
;; @param view DiffView object
(fn M.on-selection-changed [view]
  (let [file (get-selected-file view)]
    (when (and file (~= file current-file))
      (set current-file file)
      (M.open-graph))))

;; Called when diffview view opens
;; @param view DiffView object
(fn M.on-view-opened [view]
  ;; Only sync file selection if it's a diff view, not a graph view
  ;; (DiffviewGraph opens a LogGraphView which doesn't have file selection)
  (when (and view view.panel (. view.panel.selected_files))
    (set current-file (get-selected-file view))
    (M.open-graph)))

;; Called when files are staged
;; @param view DiffView object
(fn M.on-files-staged [view]
  (when gitgraph-open
    (M.open-graph)))

;; Called when diffview closes
;; @param view DiffView object
(fn M.on-view-closed [view]
  (set current-file nil)
  (set current-rev nil)
  (set gitgraph-open false))

;; Create :DiffviewGraph command
(fn M.create-command []
  (vim.api.nvim_create_user_command :DiffviewGraph
    (fn [opts]
      (let [(ok gitgraph) (pcall require :gitgraph)]
        (if ok
          (gitgraph.open opts.fargs)
          (vim.notify "gitgraph.nvim not installed" vim.log.levels.WARN))))
    {:nargs "*" :desc "Open gitgraph"}))

;; Register hooks in diffview config
(fn M.setup []
  (M.create-command)
  {:selection_changed M.on-selection-changed
   :files_staged M.on-files-staged
   :view_opened M.on-view-opened
   :view_closed M.on-view-closed})

M
