;; CDiffView-based integration: custom diff view with gitgraph data
(local M {})

(fn M.create-graph-view []
  (let [(ok CDiffView-module) (pcall #(require :diffview.api.views.diff.diff_view))]
    (if (not ok)
      (do
        (vim.notify (.. "Failed to load CDiffView: " CDiffView-module) vim.log.levels.WARN)
        nil)
      (let [CDiffView (. CDiffView-module :CDiffView)
            Rev (. CDiffView-module :Rev)
            RevType (. CDiffView-module :RevType)]
        (if (not CDiffView)
          (do
            (vim.notify "CDiffView class not found in module" vim.log.levels.WARN)
            nil)
          (let [gitgraph (require :gitgraph)
                core (require :gitgraph.core)
                git_root "/home/yuv/proj/gitgraph.nvim-snacks-api"

                ;; Get graph data
                graph-result (core.render_data gitgraph.config {} {:all true :max_count 256})
                commits (or (. graph-result :graph) [])

                ;; Create file entries from graph commits
                files (M.create-file-entries graph-result)

                ;; Get first commit hash for initial view
                first-commit (and (> (length commits) 0)
                                 (. (. commits 1) :commit)
                                 (. (. commits 1) :commit :hash))]

            ;; Create custom diff view
            (CDiffView {
              :git_root git_root
              :files files
              :left (Rev RevType.COMMIT (.. (or first-commit "HEAD") "^"))
              :right (Rev RevType.COMMIT (or first-commit "HEAD"))

              ;; Refresh file list on demand
              :update_files (fn [view]
                              (M.create-file-entries
                                (core.render_data gitgraph.config {} {:all true :max_count 256})))

              ;; Return diff content for commit
              :get_file_data (fn [path split]
                               (M.get-commit-content path split))})))))))

(fn M.create-file-entries [graph-result]
  (let [files []
        commits (or (. graph-result :graph) [])]
    (each [idx row (ipairs commits)]
      (when (and row.commit row.commit.hash)
        (let [hash row.commit.hash
              subject (or row.commit.msg "")]
          (table.insert files {
            :path (.. hash " " subject)
            :oldpath nil
            :status "M"
            :selected (= idx 1)
          }))))
    files))

(fn M.get-commit-content [path split]
  ;; Extract hash from path (format: "hash subject")
  (let [hash (string.match path "^(%x+)")
        cmd (if (= split "left")
              (.. "git show " hash "^:" split)
              (.. "git show " hash ":" split))]
    (if hash
      (vim.fn.systemlist cmd)
      [])))

(fn M.open []
  (let [view (M.create-graph-view)]
    (when view
      (view:open))))

M
