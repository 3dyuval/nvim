(local M {})
(local kitten (.. (vim.fn.expand "~") "/.config/kitty/runner.py"))

(fn run-kitten [args]
  (let [socket (or vim.env.KITTY_LISTEN_ON "unix:@mykitty")
        cmd (vim.list_extend ["kitty" "@" "--to" socket "kitten" kitten] args)]
    (vim.system cmd {:text true}
      (fn [res]
        (when (not= res.code 0)
          (vim.schedule
            #(vim.notify (.. "kitty runner failed: " (or res.stderr ""))
                         vim.log.levels.ERROR)))))))

(fn selection-or-line []
  (let [mode (. (vim.api.nvim_get_mode) :mode)]
    (when (mode:match "[vV\022]") (vim.cmd "normal! \27"))
    (if (mode:match "[vV\022]")
        (vim.api.nvim_buf_get_lines 0
          (- (. (vim.fn.getpos "'<") 2) 1) (. (vim.fn.getpos "'>") 2) false)
        [(vim.api.nvim_get_current_line)])))

(fn M.send [location]
  "Run current line / visual selection in the tab's RUNNER window (opens it if needed)."
  (run-kitten (vim.list_extend ["send" (or location :hsplit) "--"] (selection-or-line))))

(fn M.open [location]
  "Ensure and focus the tab's RUNNER window."
  (run-kitten ["open" (or location :hsplit)]))

M
