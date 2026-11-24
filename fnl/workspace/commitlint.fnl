;; Commitlint integration for gitcommit buffers: populate completion enums,
;; drive the blink menu, and validate on save.

;; Populate b:commitlint_types / b:commitlint_scopes by running
;; scripts/commitlint.sh in the buffer's repo; the blink `commitlint` source
;; consumes these buffer vars.
(vim.api.nvim_create_autocmd :FileType
  {:pattern :gitcommit
   :callback (fn [args]
               (local bufnr args.buf)
               (local script (.. (vim.fn.stdpath :config) "/scripts/commitlint.sh"))
               (local name (vim.api.nvim_buf_get_name bufnr))
               (local cwd (if (and name (not= name ""))
                              (vim.fs.dirname name)
                              (vim.fn.getcwd)))
               (vim.system [:bash script] {: cwd :text true}
                 (vim.schedule_wrap
                   (fn [out]
                     (when (and (vim.api.nvim_buf_is_valid bufnr)
                                (= out.code 0))
                       (let [(ok parsed) (pcall vim.json.decode (or out.stdout "{}"))]
                         (when ok
                           (tset (. vim.b bufnr) :commitlint_types
                                 (or parsed.types []))
                           (tset (. vim.b bufnr) :commitlint_scopes
                                 (or parsed.scopes [])))))))))})

;; Auto-open the completion menu on entering the commit buffer. Neogit runs
;; `:startinsert` as it opens the buffer, firing InsertEnter before blink has
;; attached its per-buffer listener — so show_on_insert is missed and the menu
;; only appears once you type. Re-trigger it on a deferred tick.
(vim.api.nvim_create_autocmd :FileType
  {:pattern :gitcommit
   :callback (fn [args]
               (local bufnr args.buf)
               (vim.defer_fn
                 (fn []
                   (let [(ok blink) (pcall require :blink.cmp)]
                     (when (and ok
                                (vim.api.nvim_buf_is_valid bufnr)
                                (= (vim.api.nvim_get_current_buf) bufnr)
                                (vim.startswith (. (vim.api.nvim_get_mode) :mode) :i)
                                (not (blink.is_visible)))
                       (blink.show))))
                 100))})

;; Re-open the menu on a snippet tabstop after accepting. Accepting a cl*
;; skeleton expands the snippet and jumps to the `type` tabstop, but blink only
;; re-shows inside a snippet if the menu was open at jump time — after accept
;; it's closed. On BlinkCmpAccept in gitcommit with an active snippet, re-show.
(vim.api.nvim_create_autocmd :User
  {:pattern :BlinkCmpAccept
   :callback (fn []
               (when (= vim.bo.filetype :gitcommit)
                 (vim.defer_fn
                   (fn []
                     (let [(ok blink) (pcall require :blink.cmp)]
                       (when (and ok
                                  (blink.snippet_active)
                                  (not (blink.is_visible)))
                         (blink.show))))
                   50)))})

;; Validate the message on save: pipe the buffer through `commitlint`; a
;; non-zero exit notifies with the linter output so violations surface in place.
(vim.api.nvim_create_autocmd :BufWritePost
  {:pattern :gitcommit
   :callback (fn [args]
               (local bufnr args.buf)
               (when (= (vim.fn.executable :commitlint) 1)
                 (local lines (vim.api.nvim_buf_get_lines bufnr 0 -1 false))
                 (local msg (table.concat lines "\n"))
                 (local name (vim.api.nvim_buf_get_name bufnr))
                 (local cwd (if (and name (not= name ""))
                                (vim.fs.dirname name)
                                (vim.fn.getcwd)))
                 (vim.system [:commitlint] {:stdin msg :text true : cwd}
                   (vim.schedule_wrap
                     (fn [out]
                       (when (not= out.code 0)
                         (let [body (let [s (.. (or out.stdout "") (or out.stderr ""))]
                                      (vim.trim s))]
                           (vim.notify (if (= body "") "commitlint: invalid commit message" body)
                                       vim.log.levels.ERROR
                                       {:title :commitlint}))))))))})

{}
