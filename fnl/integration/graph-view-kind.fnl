;; Graph View Kind Registration
;; Registers GraphView as a custom view kind with diffview

(local M {})

(fn graph-render [self]
  "Render gitgraph data instead of file tree"
  ;; Initialize graph data on first render
  (if (not self.graph_data)
    (let [(ok-core core) (pcall #(require :gitgraph.core))
          (ok-gitgraph gitgraph) (pcall #(require :gitgraph))]
      (if (and ok-core ok-gitgraph)
        (let [(ok-render render-result) (pcall #(core.render_data gitgraph.config {} {:all true :max_count 256}))]
          (if ok-render
            (set self.graph_data render-result))))))

  ;; Render graph data to buffer
  (if self.graph_data
    (let [bufnr self.bufid]
      (if (vim.api.nvim_buf_is_valid bufnr)
        (do
          (vim.api.nvim_set_option_value "modifiable" true {:buf bufnr})
          (vim.api.nvim_buf_set_lines bufnr 0 -1 false self.graph_data.lines)
          (each [_ hl (ipairs self.graph_data.highlights)]
            (vim.api.nvim_buf_add_highlight bufnr -1 hl.hg hl.row hl.start hl.stop))
          (vim.api.nvim_set_option_value "modifiable" false {:buf bufnr}))))))

(fn M.open-graph []
  "Open diffview with gitgraph rendering"
  ;; Hook into view_opened to override panel render
  (let [lib (require :diffview.lib)]
    (vim.api.nvim_create_autocmd :User
      {:pattern :DiffviewViewOpened
       :once true
       :callback (fn []
                   (let [view (lib.get_current_view)]
                     (if view
                       (do
                         ;; Override panel render with gitgraph
                         (set view.panel.graph_data nil)
                         (set view.panel.render graph-render)))))}))
  ;; Now open diffview normally
  (vim.cmd "DiffviewOpen main..HEAD"))

M
