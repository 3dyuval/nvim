;; fennel-ls project configuration
;; https://git.sr.ht/~xerool/fennel-ls/tree/HEAD/docs/manual.md#configuration
;;
;; Also serves as the root marker for the fennel_ls language server
;; (see lspconfig's fennel_ls preset root_dir).
{;; Resolve `require` of project modules to the fnl/ source tree.
 :fennel-path "fnl/?.fnl;fnl/?/init.fnl"

 ;; Neovim exposes `vim` as a global; without this fennel-ls reports it
 ;; as an unknown global in every config file.
 :extra-globals "vim"}
