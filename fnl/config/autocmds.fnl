;; Index of autocmd/command/override concerns. Each is a focused module under
;; fnl/workspace/; this file only wires them up (and a couple of misc one-offs).

;; User commands
(require :workspace.ai-commit)
(require :workspace.bug-template)
(require :workspace.tutor)
((. (require :workspace.schemastore) :setup))

;; LSP
(require :workspace.lsp-autosave)
(require :workspace.tailwind)

;; Filetypes & buffers
(require :workspace.filetypes)
(require :workspace.cursor-restore)
(require :workspace.text-ft)
(require :workspace.swapfile)
(require :workspace.folds)

;; Git
(require :workspace.commitlint)

;; UI
(require :workspace.kitty-padding)
(require :workspace.claude-windows)

;; Misc one-offs
(vim.api.nvim_del_augroup_by_name :lazyvim_wrap_spell)
(vim.opt.shortmess:append :F)
