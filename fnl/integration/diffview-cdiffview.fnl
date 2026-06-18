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
        commits (or (. graph-result :graph) [])
        ;; Get changed files from first commit
        first-commit (and (> (length commits) 0)
                         (. (. commits 1) :commit)
                         (. (. commits 1) :commit :hash))]
    (when first-commit
      (let [changed-files (vim.fn.systemlist (.. "git diff --name-only " first-commit "^.." first-commit))]
        (each [idx file (ipairs changed-files)]
          (table.insert files {
            :path file
            :oldpath nil
            :status "M"
            :selected (= idx 1)
          }))))
    files))

(fn M.get-commit-content [path split]
  ;; Get file content from git
  ;; We need to use the currently selected commit
  ;; For now, just get the file from HEAD
  (let [cmd (if (= split "left")
              (.. "git show HEAD^:" path)
              (.. "git show HEAD:" path))]
    (vim.fn.systemlist cmd)))

(fn M.open []
  ;; Simply open diffview on the snacks-api worktree
  (let [cwd (vim.fn.getcwd)]
    (vim.cmd (.. "cd /home/yuv/proj/gitgraph.nvim-snacks-api"))
    (vim.cmd "DiffviewOpen")
    (vim.cmd (.. "cd " cwd))))

M
