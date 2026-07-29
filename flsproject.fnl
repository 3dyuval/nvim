;; fennel-ls project configuration
;; https://git.sr.ht/~xerool/fennel-ls/tree/HEAD/docs/manual.md#configuration
;;
;; Also serves as the root marker for the fennel_ls language server
;; (see lspconfig's fennel_ls preset root_dir).
{;; Resolve `require` of project modules to the fnl/ source tree.
 :fennel-path "fnl/?.fnl;fnl/?/init.fnl"

 ;; Globals injected at runtime that fennel-ls can't see: `vim` (Neovim),
 ;; `Snacks` (snacks.nvim sets _G.Snacks), `LazyVim` (LazyVim). Without this
 ;; fennel-ls reports them as unknown identifiers.
 :extra-globals "vim Snacks LazyVim"}
