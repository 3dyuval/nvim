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

;; --- Foldlevel: keep at 99 (UFO manages actual folding) ---

(autocmd [:BufWinEnter :WinEnter :TabEnter]
         {:callback (fn []
                      (vim.defer_fn (fn []
                                      (when (< vim.wo.foldlevel 99)
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
