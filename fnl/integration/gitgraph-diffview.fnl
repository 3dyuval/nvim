(local M {})

(var graph-win nil)
(var src-win nil)
(var graph-buf nil)

(fn graph-open? []
  (and graph-win (vim.api.nvim_win_is_valid graph-win)))

(fn M.open-graph []
  (let [(ok gitgraph) (pcall require :gitgraph)
        (ok-core core) (pcall require :gitgraph.core)]
    (if (not ok)
      (vim.notify "gitgraph.nvim not installed" vim.log.levels.WARN)
      (do
        (set src-win (vim.api.nvim_get_current_win))
        (when (not (graph-open?))
          (vim.cmd "botright split")
          (set graph-win (vim.api.nvim_get_current_win))
          (set graph-buf (vim.api.nvim_get_current_buf))
          (vim.api.nvim_win_set_height graph-win 16))
        (vim.api.nvim_set_current_win graph-win)
        (vim.api.nvim_set_option_value "modifiable" true {:buf graph-buf})
        (let [(ok-render render-result) (pcall core.render_data gitgraph.config {} {:all true :max_count 256})]
          (if ok-render
            (do
              (vim.api.nvim_buf_set_lines graph-buf 0 -1 false render-result.lines)
              (each [_ hl (ipairs render-result.highlights)]
                (vim.api.nvim_buf_add_highlight graph-buf -1 hl.hg hl.row hl.start hl.stop)))
            (vim.notify (.. "Failed to render graph: " render-result) vim.log.levels.ERROR)))
        (vim.api.nvim_set_option_value "modifiable" false {:buf graph-buf})
        (when (and src-win (vim.api.nvim_win_is_valid src-win))
          (vim.api.nvim_set_current_win src-win))))))

(fn M.close-graph []
  (when (graph-open?)
    (vim.api.nvim_win_close graph-win true))
  (set graph-win nil))

(fn M.on-view-opened [view]
  (M.open-graph))

(fn M.on-view-closed [view]
  (M.close-graph))

(fn M.on-selection-changed [view])

(fn M.on-files-staged [view])

(fn M.create-command []
  (vim.api.nvim_create_user_command :DiffviewGraph
    (fn [_opts] (M.open-graph))
    {:nargs "*" :desc "Open gitgraph in a split"}))

(fn M.setup []
  (M.create-command)
  {:view_closed M.on-view-closed})

M
