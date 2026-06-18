;; Gitgraph integration: show gitgraph in a split next to diffview
(local M {})

(var graph-win nil)
(var src-win nil)
(var graph-buf nil)
(var graph-data nil)

(fn graph-open? []
  (and graph-win (vim.api.nvim_win_is_valid graph-win)))

(fn M.open []
  ;; Change to snacks-api worktree
  (let [cwd (vim.fn.getcwd)
        ok (pcall #(vim.cmd (.. "cd /home/yuv/proj/gitgraph.nvim-snacks-api")))]

    (when ok
      ;; Load gitgraph from snacks-api worktree
      (let [(ok-gitgraph gitgraph) (pcall #(require :gitgraph))]
        (if (not ok-gitgraph)
          (vim.notify "Failed to load gitgraph" vim.log.levels.WARN)
          (do
            ;; Get render_data from snacks-api implementation
            (let [(ok-core core) (pcall #(require :gitgraph.core))
                  render-result (core.render_data gitgraph.config {} {:all true :max_count 256})]

              ;; Create graph split
              (set src-win (vim.api.nvim_get_current_win))
              (when (not (graph-open?))
                (vim.cmd "topleft vertical split")
                (set graph-win (vim.api.nvim_get_current_win))
                (set graph-buf (vim.api.nvim_get_current_buf))
                (vim.api.nvim_win_set_width graph-win 60))

              ;; Render graph
              (vim.api.nvim_set_current_win graph-win)
              (vim.api.nvim_set_option_value "modifiable" true {:buf graph-buf})
              (vim.api.nvim_buf_set_lines graph-buf 0 -1 false render-result.lines)

              ;; Apply highlights
              (each [_ hl (ipairs render-result.highlights)]
                (vim.api.nvim_buf_add_highlight graph-buf -1 hl.hg hl.row hl.start hl.stop))

              (vim.api.nvim_set_option_value "modifiable" false {:buf graph-buf})
              (set graph-data render-result)

              ;; Open diffview in the other window
              (when (and src-win (vim.api.nvim_win_is_valid src-win))
                (vim.api.nvim_set_current_win src-win))

              (vim.cmd "DiffviewOpen main..HEAD"))))))

    ;; Return to original directory
    (pcall #(vim.cmd (.. "cd " cwd)))))

M
