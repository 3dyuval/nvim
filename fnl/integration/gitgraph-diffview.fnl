(local M {})

(var graph-win nil)
(var src-win nil)

(fn graph-open? []
  (and graph-win (vim.api.nvim_win_is_valid graph-win)))

(fn M.open-graph []
  (let [(ok gitgraph) (pcall require :gitgraph)]
    (if (not ok)
      (vim.notify "gitgraph.nvim not installed" vim.log.levels.WARN)
      (do
        (set src-win (vim.api.nvim_get_current_win))
        (when (not (graph-open?))
          (vim.cmd "botright split")
          (set graph-win (vim.api.nvim_get_current_win))
          (vim.api.nvim_win_set_height graph-win 16))
        (vim.api.nvim_set_current_win graph-win)
        (gitgraph.draw {} {:all true :max_count 256})
        (when (and src-win (vim.api.nvim_win_is_valid src-win))
          (vim.api.nvim_set_current_win src-win))))))

(fn M.close-graph []
  (when (graph-open?)
    (vim.api.nvim_win_close graph-win true))
  (set graph-win nil))

(fn M.on-view-closed [view]
  (M.close-graph))

(fn M.create-command []
  (vim.api.nvim_create_user_command :DiffviewGraph
    (fn [_opts] (M.open-graph))
    {:nargs "*" :desc "Open gitgraph in a split"}))

(fn M.setup []
  (M.create-command)
  {:view_closed M.on-view-closed})

M
