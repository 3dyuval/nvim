(local M {})

(fn listed []
  (icollect [_ b (ipairs (vim.api.nvim_list_bufs))]
    (when (and (. (. vim.bo b) :buflisted) (vim.api.nvim_buf_is_loaded b)) b)))

(fn bento-visible? []
  (not= vim.o.showtabline 0))

(fn kitty-tab [action]
  (let [socket (or vim.env.KITTY_LISTEN_ON "unix:@mykitty")]
    (vim.system ["kitty" "@" "--to" socket "action" action] {:text true})))

(fn M.next []
  "Bento visible: next buffer, edge -> kitty next tab. Else: kitty next tab."
  (let [bufs (listed)
        cur (vim.api.nvim_get_current_buf)]
    (if (or (not (bento-visible?)) (= cur (. bufs (length bufs))))
        (kitty-tab :next_tab)
        (vim.cmd "bnext"))))

(fn M.prev []
  "Bento visible: prev buffer, edge -> kitty prev tab. Else: kitty prev tab."
  (let [bufs (listed)
        cur (vim.api.nvim_get_current_buf)]
    (if (or (not (bento-visible?)) (= cur (. bufs 1)))
        (kitty-tab :previous_tab)
        (vim.cmd "bprev"))))

M
