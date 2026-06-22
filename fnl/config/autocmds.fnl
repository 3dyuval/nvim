(macro autocmd [events opts]
  `(vim.api.nvim_create_autocmd ,events ,opts))

(macro set-ft [pattern ft]
  `(vim.api.nvim_create_autocmd [:BufRead :BufNewFile]
                                {:pattern ,pattern
                                 :command ,(.. "set filetype=" ft)}))

;; --- User commands ---

(let [ai-popup (require :utils.ai_popup)]
  (vim.api.nvim_create_user_command
    :AiCommit
    (fn [opts]
      (if (or (= opts.args :--preview) (= opts.args :-p))
          (ai-popup.run_generate (or vim.g.AiCommitLastSettings {}))
          (or (= opts.args :--repeat) (= opts.args :-r))
          (ai-popup.repeat_last)
          (ai-popup.create)))
    {:nargs "?" :desc "AI commit popup"}))

(vim.api.nvim_create_user_command
  :BugTemplate
  (fn [opts] ((. (require :utils.buffers) :create_buffer_bug) (or opts.args :X)))
  {:nargs "?"})

(vim.api.nvim_create_user_command
  :BugSnippet
  (fn [opts] ((. (require :utils.buffers) :create_buffer_bug_snippet) (or opts.args :X)))
  {:nargs "?"})

;; :SchemaStore — browse the SchemaStore catalog, fetch+cache schema bodies.
((. (require :picker.schemastore) :setup))

;; --- Auto-save LSP workspace edits (vtsls import updates on file rename) ---
;; https://github.com/yioneko/vtsls/issues/287
(let [orig vim.lsp.util.apply_workspace_edit]
  (set vim.lsp.util.apply_workspace_edit
       (fn [workspace-edit offset-encoding]
         (local pre-loaded {})
         (each [_ bufnr (ipairs (vim.api.nvim_list_bufs))]
           (when (vim.api.nvim_buf_is_loaded bufnr)
             (tset pre-loaded bufnr true)))
         (local result (orig workspace-edit offset-encoding))
         (vim.schedule
           (fn []
             (local to-save {})
             (local to-cleanup {})
             (fn process-uri [uri]
               (local bufnr (vim.uri_to_bufnr uri))
               (when (and (vim.api.nvim_buf_is_loaded bufnr)
                          (. vim.bo bufnr :modified))
                 (if (. pre-loaded bufnr)
                     (tset to-save bufnr true)
                     (tset to-cleanup bufnr uri))))
             (when workspace-edit.changes
               (each [uri _ (pairs workspace-edit.changes)]
                 (process-uri uri)))
             (when workspace-edit.documentChanges
               (each [_ change (ipairs workspace-edit.documentChanges)]
                 (when (and change.textDocument change.textDocument.uri)
                   (process-uri change.textDocument.uri))))
             (local saved-eventignore vim.o.eventignore)
             (set vim.o.eventignore :all)
             (each [bufnr _ (pairs to-save)]
               (vim.api.nvim_buf_call bufnr #(vim.cmd "silent! noautocmd write")))
             (each [bufnr _ (pairs to-cleanup)]
               (vim.api.nvim_buf_call bufnr #(vim.cmd "silent! noautocmd write"))
               (vim.api.nvim_buf_delete bufnr {:force true}))
             (set vim.o.eventignore saved-eventignore)
             (vim.cmd :redraw)))
         result)))

;; --- Filetype detection ---

(set-ft [:Fastfile :Appfile :Matchfile :Pluginfile] :ruby)
(set-ft ["*.ex" "*.exs"] :elixir)
(set-ft ["*.heex"] :heex)
(set-ft ["*.log"] :log)

;; env-indirected shebangs confuse bashls (falls back to bash dialect) — force zsh ft
(autocmd :BufReadPost
         {:callback (fn []
                      (when (string.match (or (vim.fn.getline 1) "") "^#!.*env zsh")
                        (set vim.bo.filetype :zsh)))})


;; --- Restore cursor position from previous session ---

(autocmd :BufReadPost
         {:callback (fn [args]
                      (local mark (vim.api.nvim_buf_get_mark args.buf "\""))
                      (local lines (vim.api.nvim_buf_line_count args.buf))
                      (when (and (> (. mark 1) 0) (<= (. mark 1) lines))
                        (vim.api.nvim_buf_call args.buf #(vim.cmd "normal! g`\"zz"))))})

;; --- Commitlint: populate b:commitlint_types / b:commitlint_scopes ---
;; Runs scripts/commitlint.sh in the buffer's repo and stores the enum values
;; as buffer vars for the blink `commitlint` source to consume.

(autocmd :FileType
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

;; --- Commitlint: auto-open the completion menu on entering the commit buffer ---
;; Neogit runs `:startinsert` as it opens the commit buffer, firing InsertEnter
;; before blink has attached its per-buffer listener — so blink's show_on_insert
;; is missed and the menu only appears once you type a char. Re-trigger the menu
;; ourselves on a deferred tick, when still in insert mode on the first line.
(autocmd :FileType
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

;; --- Commitlint: re-open the menu on a snippet tabstop after accepting ---
;; Accepting a cl* skeleton expands the snippet and jumps to the `type` tabstop,
;; but blink only re-shows inside a snippet if the menu was already open at jump
;; time — after accept it's closed, so the type/scope completions don't appear.
;; On BlinkCmpAccept in a gitcommit buffer with an active snippet, re-show.
(autocmd :User
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

;; --- Commitlint: validate the message on save ---
;; Pipes the buffer through `commitlint` on write; a non-zero exit notifies
;; with the linter output so rule violations surface without leaving the buffer.

(autocmd :BufWritePost
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

;; --- Text formatting: wrap and spell for text-like filetypes ---

(autocmd :FileType
         {:pattern [:text :plaintex :typst :gitcommit :markdown]
          :callback (fn []
                      (set vim.opt_local.wrap true)
                      (set vim.opt_local.spell true))})

;; --- COMMIT_EDITMSG: create manual folds for @@ diff hunk markers ---

(autocmd :BufReadPost
         {:pattern "*COMMIT_EDITMSG*"
          :callback (fn []
                      (vim.defer_fn
                        (fn []
                          (let [bufnr (vim.api.nvim_get_current_buf)
                                lines (vim.api.nvim_buf_get_lines bufnr 0 -1 false)]
                            (when (> (length lines) 0)
                              (set vim.bo.foldmethod :manual)
                              (vim.cmd "normal! zE")
                              ;; Find @@ markers and fold content between them
                              (var prev-hunk nil)
                              (each [i line (ipairs lines)]
                                (when (string.match line "^@@")
                                  (when (and prev-hunk (> (- i prev-hunk) 1))
                                    (vim.cmd (string.format "%d,%dfold" (+ prev-hunk 1) (- i 1))))
                                  (set prev-hunk i)))
                              ;; Fold final section
                              (when prev-hunk
                                (vim.cmd (string.format "%d,%dfold" (+ prev-hunk 1) (length lines))))
                              ;; Close all folds
                              (vim.cmd "normal! zM"))))
                        50))})
;; --- Snacks windows: no swap ---

(autocmd :FileType
         {:pattern [:snacks_win :snacks_picker :snacks_explorer]
          :callback (fn [] (set vim.opt_local.swapfile false))})

;; --- SSHFS mounts: disable swap/undo/backup ---

(autocmd :BufReadPre
         {:pattern [(.. (vim.fn.expand "~") "/mnt/*")
                    (.. (vim.fn.expand "~") "/.sshfs/*")]
          :callback (fn []
                      (set vim.opt_local.swapfile false)
                      (set vim.opt_local.undofile false)
                      (set vim.opt_local.backup false)
                      (set vim.opt_local.writebackup false))})

;; --- Foldlevel: keep at 99 (UFO manages actual folding), except gitcommit ---

(autocmd [:BufWinEnter :WinEnter :TabEnter]
         {:callback (fn []
                      (vim.defer_fn (fn []
                                      (when (and (< vim.wo.foldlevel 99)
                                                 (not= vim.bo.filetype :gitcommit))
                                        (set vim.wo.foldlevel 99)))
                                    100))})

;; --- Tailwind CSS LSP: auto-start when config detected ---

(autocmd [:BufEnter :BufWinEnter]
         {:pattern ["*.ts" "*.tsx" "*.js" "*.jsx"]
          :callback (fn []
                      (when (not vim.b.tailwind_checked)
                        (set vim.b.tailwind_checked true)
                        (var found false)
                        (each [_ cfg (ipairs [:tailwind.config.js
                                              :tailwind.config.ts
                                              :tailwind.config.cjs
                                              :tailwind.config.mjs])
                               :until found]
                          (when (= (vim.fn.filereadable cfg) 1)
                            (vim.defer_fn #(vim.cmd "LspStart tailwindcss") 200)
                            (set found true)))))})

;; --- Kitty: remove padding on enter, restore on exit ---

(vim.defer_fn
  (fn []
    (when (and vim.env.KITTY_WINDOW_ID vim.env.KITTY_LISTEN_ON)
      (vim.fn.system (string.format "kitten @ --to %s set-spacing --match id:%s padding=0"
                                    vim.env.KITTY_LISTEN_ON
                                    vim.env.KITTY_WINDOW_ID))))
  100)

(autocmd :VimLeavePre
         {:callback (fn []
                      (when (and vim.env.KITTY_WINDOW_ID vim.env.KITTY_LISTEN_ON)
                        (vim.fn.system (string.format "kitten @ --to %s set-spacing --match id:%s padding=12"
                                                      vim.env.KITTY_LISTEN_ON
                                                      vim.env.KITTY_WINDOW_ID))))})

;; --- Claude Code: hide terminal when diff buffers open ---

(autocmd :BufWinEnter
         {:callback (fn []
                      (local buf (vim.api.nvim_get_current_buf))
                      (when (. vim.b buf :claudecode_diff_tab_name)
                        (each [_ win (ipairs (vim.api.nvim_list_wins))]
                          (local wbuf (vim.api.nvim_win_get_buf win))
                          (when (and (= (. vim.bo wbuf :buftype) :terminal)
                                     (string.match (vim.api.nvim_buf_get_name wbuf) :claude))
                            (pcall vim.api.nvim_win_close win false)
                            (lua :return)))))})

;; --- Claude Code: refocus float on FocusGained ---

(autocmd :FocusGained
         {:callback (fn []
                      (each [_ win (ipairs (vim.api.nvim_list_wins))]
                        (local buf (vim.api.nvim_win_get_buf win))
                        (local name (vim.api.nvim_buf_get_name buf))
                        (when (and (name:match :claude)
                                   (= (. vim.bo buf :buftype) :terminal))
                          (vim.api.nvim_set_current_win win)
                          (vim.cmd :startinsert)
                          (lua :return))))})

(vim.api.nvim_del_augroup_by_name :lazyvim_wrap_spell)
(vim.opt.shortmess:append :F)
