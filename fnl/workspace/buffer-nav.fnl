(local M {})

(fn listed []
  (icollect [_ b (ipairs (vim.api.nvim_list_bufs))]
    (when (and (. (. vim.bo b) :buflisted) (vim.api.nvim_buf_is_loaded b)) b)))

(fn bento-visible? []
  (not= vim.o.showtabline 0))

(fn kitty-tab [action]
  (let [socket (or vim.env.KITTY_LISTEN_ON "unix:@mykitty")]
    (vim.system ["kitty" "@" "--to" socket "action" action] {:text true})))

(fn at-edge? [cur bufs which]
  "True when buffer paging can't continue: line hidden, <2 listed buffers,
  current buffer not listed, or already at the which end (1 | (length bufs))."
  (or (not (bento-visible?))
      (< (length bufs) 2)
      (= cur (. bufs which))
      (not (vim.tbl_contains bufs cur))))

(fn M.next []
  "Bento visible: next buffer, edge -> kitty next tab. Else: kitty next tab."
  (let [bufs (listed)
        cur (vim.api.nvim_get_current_buf)]
    (if (at-edge? cur bufs (length bufs))
        (kitty-tab :next_tab)
        (when (not (pcall vim.cmd "bnext"))
          (kitty-tab :next_tab)))))

(fn M.prev []
  "Bento visible: prev buffer, edge -> kitty prev tab. Else: kitty prev tab."
  (let [bufs (listed)
        cur (vim.api.nvim_get_current_buf)]
    (if (at-edge? cur bufs 1)
        (kitty-tab :previous_tab)
        (when (not (pcall vim.cmd "bprev"))
          (kitty-tab :previous_tab)))))

M
