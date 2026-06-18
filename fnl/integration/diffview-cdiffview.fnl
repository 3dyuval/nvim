;; Gitgraph integration: replace file panel render with gitgraph output
;; Uses view_opened hook to render gitgraph instead of file tree
(local M {})

(var graph-data nil)

(fn render-graph []
  "Render gitgraph and return {lines, highlights}"
  (let [(ok-core core) (pcall #(require :gitgraph.core))]
    (when (not ok-core)
      (vim.notify "Failed to load gitgraph.core" vim.log.levels.WARN)
      (lua "return nil"))

    (let [(ok-gitgraph gitgraph) (pcall #(require :gitgraph))]
      (when (not ok-gitgraph)
        (vim.notify "Failed to load gitgraph" vim.log.levels.WARN)
        (lua "return nil"))

      (let [(ok-render render-result) (pcall #(core.render_data gitgraph.config {} {:all true :max_count 256}))]
        (when (not ok-render)
          (vim.notify (.. "Failed to render graph: " (tostring render-result)) vim.log.levels.ERROR)
          (lua "return nil"))

        render-result))))

(fn setup-panel-for-graph [bufnr]
  "Configure file panel buffer to display gitgraph instead of files"
  ;; Set filetype so we can target it with syntax/autocmds
  (vim.api.nvim_buf_set_option bufnr "filetype" "DiffviewGraph")

  ;; Window display options (compact)
  (set vim.opt_local.number false)
  (set vim.opt_local.relativenumber false)
  (set vim.opt_local.signcolumn "no")
  (set vim.opt_local.wrap false))

(fn M.inject-graph [view]
  "Replace file panel rendering with gitgraph output"
  (let [render-result (render-graph)]
    (if (not render-result)
      (vim.notify "No graph data to inject" vim.log.levels.WARN)
      (let [panel view.panel
            bufnr (and panel panel.bufid)]
        (if (not bufnr)
          (vim.notify "No file panel found" vim.log.levels.WARN)
          (do
            ;; Clear and repopulate panel buffer with gitgraph
            (vim.api.nvim_set_option_value "modifiable" true {:buf bufnr})
            (vim.api.nvim_buf_set_lines bufnr 0 -1 false render-result.lines)

            ;; Apply gitgraph highlights
            (each [_ hl (ipairs render-result.highlights)]
              (vim.api.nvim_buf_add_highlight bufnr -1 hl.hg hl.row hl.start hl.stop))

            ;; Lock buffer
            (vim.api.nvim_set_option_value "modifiable" false {:buf bufnr})

            ;; Configure for graph display
            (setup-panel-for-graph bufnr)

            ;; Store graph data for interactive features (if needed later)
            (set graph-data render-result)))))))

(fn M.open []
  "Command: open diffview with graph in file panel"
  (vim.cmd "DiffviewOpen main..HEAD"))

M
