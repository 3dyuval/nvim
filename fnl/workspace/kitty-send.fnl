;; Send the current line / visual selection to the neighboring kitty split and
;; run it — via the neighboring_window.py kitten (extended with a `send` verb).
;; Runs inside kitty over boss, so no socket/tab-creation fragility.

(local M {})
(local kitten (.. (vim.fn.expand "~") "/.config/kitty/neighboring_window.py"))
(local direction :right)

(fn run-kitten [args]
  "kitty @ --to <this-instance> kitten neighboring_window.py <args...>"
  (let [socket (or vim.env.KITTY_LISTEN_ON "unix:@mykitty")
        cmd (vim.list_extend ["kitty" "@" "--to" socket "kitten" kitten] args)]
    (vim.system cmd {:text true}
      (fn [res]
        (when (not= res.code 0)
          (vim.schedule
            #(vim.notify (.. "kitty send failed: " (or res.stderr ""))
                         vim.log.levels.ERROR)))))))

(fn selection-or-line []
  (let [mode (. (vim.api.nvim_get_mode) :mode)]
    (when (mode:match "[vV\022]") (vim.cmd "normal! \27"))
    (if (mode:match "[vV\022]")
        (vim.api.nvim_buf_get_lines 0
          (- (. (vim.fn.getpos "'<") 2) 1) (. (vim.fn.getpos "'>") 2) false)
        [(vim.api.nvim_get_current_line)])))

(fn M.send []
  "Send current line / visual selection to the neighbor split (+ run)."
  (run-kitten (vim.list_extend ["send" direction "--"] (selection-or-line))))

(fn M.open []
  "Focus the neighboring split in `direction`."
  (run-kitten [direction]))

M
