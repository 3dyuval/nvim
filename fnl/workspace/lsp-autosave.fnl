;; Auto-save LSP workspace edits (vtsls import updates on file rename).
;; https://github.com/yioneko/vtsls/issues/287
;; Buffers already loaded before the edit are saved in place; buffers the edit
;; itself opened are saved then wiped, so rename-driven edits don't litter the
;; buffer list.
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

{}
