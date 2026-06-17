;; Gitgraph + Diffview Integration
;; Stateful view recipe: render gitgraph inside a managed split, driven by
;; diffview navigation. Probing how far the public hook surface reaches.
;;
;; gitgraph.draw hijacks window 0 (nvim_win_set_buf(0, buf)) — it has no
;; window of its own. So to get a split we open our own window, focus it,
;; THEN call draw: window 0 is now our split, and gitgraph lands there.
;; We give it a bottom split to live in; gitgraph is the dumb renderer, we
;; own the window layout.

(local M {})

(var graph-win nil)   ; the split window we own
(var src-win nil)     ; the diffview window we came from (to restore focus)

;; Is our graph split currently live?
(fn graph-open? []
  (and graph-win (vim.api.nvim_win_is_valid graph-win)))

;; Open (or reuse) the graph split and render gitgraph into it.
;; Returns focus to the originating window afterward.
(fn M.open-graph []
  (let [(ok gitgraph) (pcall require :gitgraph)]
    (if (not ok)
      (vim.notify "gitgraph.nvim not installed" vim.log.levels.WARN)
      (do
        (set src-win (vim.api.nvim_get_current_win))
        ;; Create our split if we don't have one yet.
        (when (not (graph-open?))
          (vim.cmd "botright split")
          (set graph-win (vim.api.nvim_get_current_win))
          (vim.api.nvim_win_set_height graph-win 16))
        ;; Focus our split so gitgraph's nvim_win_set_buf(0,...) targets it.
        (vim.api.nvim_set_current_win graph-win)
        (gitgraph.draw {} {:all true :max_count 256})
        ;; Restore focus to diffview.
        (when (and src-win (vim.api.nvim_win_is_valid src-win))
          (vim.api.nvim_set_current_win src-win))))))

;; Close the graph split.
(fn M.close-graph []
  (when (graph-open?)
    (vim.api.nvim_win_close graph-win true))
  (set graph-win nil))

;; --- diffview hooks -------------------------------------------------------

;; view_opened: open the graph split alongside the diff.
(fn M.on-view-opened [view]
  (M.open-graph))

;; view_closed: tear down the graph split.
(fn M.on-view-closed [view]
  (M.close-graph))

;; --- :DiffviewGraph command ----------------------------------------------

(fn M.create-command []
  (vim.api.nvim_create_user_command :DiffviewGraph
    (fn [_opts] (M.open-graph))
    {:nargs "*" :desc "Open gitgraph in a split"}))

;; --- setup ----------------------------------------------------------------

(fn M.setup []
  (M.create-command)
  {:view_opened M.on-view-opened
   :view_closed M.on-view-closed})

M
