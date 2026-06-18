(local M {})

(var graph-win nil)
(var src-win nil)
(var graph-buf nil)
(var graph-data nil)

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
          (set graph-buf (vim.api.nvim_create_buf false true))
          (vim.api.nvim_win_set_buf graph-win graph-buf)
          (vim.api.nvim_win_set_height graph-win 16))
        (vim.api.nvim_set_current_win graph-win)
        (vim.api.nvim_set_option_value "modifiable" true {:buf graph-buf})
        (let [(ok-render render-result) (pcall core.render_data gitgraph.config {} {:all true :max_count 256})]
          (if ok-render
            (do
              (set graph-data render-result)
              (vim.api.nvim_buf_set_lines graph-buf 0 -1 false render-result.lines)
              (each [_ hl (ipairs render-result.highlights)]
                (vim.api.nvim_buf_add_highlight graph-buf -1 hl.hg hl.row hl.start hl.stop)))
            (vim.notify (.. "Failed to render graph: " render-result) vim.log.levels.ERROR)))
        (vim.api.nvim_set_option_value "modifiable" false {:buf graph-buf})
        (M.setup-graph-keymaps)
        (when (and src-win (vim.api.nvim_win_is_valid src-win))
          (vim.api.nvim_set_current_win src-win))))))

(fn M.close-graph []
  (when (graph-open?)
    (vim.api.nvim_win_close graph-win true))
  (set graph-win nil))

(fn M.open-commit-in-diffview []
  (let [line (vim.api.nvim_get_current_line)
        hash (string.match line "(%x%x%x%x%x%x%x)")]
    (if hash
      (do
        (when (and src-win (vim.api.nvim_win_is_valid src-win))
          (vim.api.nvim_set_current_win src-win))
        (vim.cmd (.. "DiffviewOpen " hash "^!"))
        (when (graph-open?)
          (vim.api.nvim_set_current_win graph-win)))
      (vim.notify "No commit hash found on this line" vim.log.levels.WARN))))

(fn M.setup-graph-keymaps []
  (when (and graph-buf (vim.api.nvim_buf_is_valid graph-buf))
    (vim.keymap.set :n :q (fn [] (M.close-graph)) {:buffer graph-buf :noremap true :silent true})
    (vim.keymap.set :n :<CR> (fn [] (M.open-commit-in-diffview)) {:buffer graph-buf :noremap true :silent true})))

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
