;; CDiffView-based integration: custom diff view with gitgraph data
(local M {})

(fn M.create-graph-view []
  (let [(ok CDiffView-module) (pcall #(require :diffview.api.views.diff))]
    (if (not ok)
      (do
        (vim.notify (.. "Failed to load CDiffView: " CDiffView-module) vim.log.levels.WARN)
        nil)
      (let [CDiffView (. CDiffView-module :CDiffView)]
        (if (not CDiffView)
          (do
            (vim.notify "CDiffView class not found in module" vim.log.levels.WARN)
            nil)
          (do
            (let [gitgraph (require :gitgraph)
                  core (require :gitgraph.core)
                  git_root (vim.fn.getcwd)

                  ;; Get graph data
                  graph-result (core.render_data gitgraph.config {} {:all true :max_count 256})

                  ;; Create file entries from graph commits
                  files (M.create-file-entries graph-result)]

              ;; Create custom diff view
              (CDiffView {
                :git_root git_root
                :files files

                ;; Refresh file list on demand
                :update_files (fn [view]
                                (M.create-file-entries
                                  (core.render_data gitgraph.config {} {:all true :max_count 256})))

                ;; Return diff content for commit
                :get_file_data (fn [path split]
                                 (M.get-commit-content path split))}))))))))

(fn M.create-file-entries [graph-result]
  (let [files []
        commits (or (. graph-result :graph) [])]
    (each [idx row (ipairs commits)]
      (when (and row.commit row.commit.hash)
        (table.insert files {
          :path row.commit.hash
          :oldpath nil
          :status "M"
          :selected (= idx 1)
        })))
    files))

(fn M.get-commit-content [hash split]
  (let [cmd (if (= split "left")
              (.. "git show " hash "^")
              (.. "git show " hash))]
    (vim.fn.systemlist cmd)))

(fn M.open []
  (let [view (M.create-graph-view)]
    (when view
      (view:open))))

M
