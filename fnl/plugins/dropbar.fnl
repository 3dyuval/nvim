;; dropbar.nvim — interactive winbar breadcrumbs (LSP -> treesitter -> path).
;; Replaces navic/barbecue-style breadcrumbs. Needs Neovim >= 0.10.
;; Menu: <CR> pick, q/<Esc> close. Requires no extra deps.
{1 "Bekaboo/dropbar.nvim"
 :event :VeryLazy
 :config (fn []
           (local dropbar (require :dropbar))
           (dropbar.setup
             {:sources {}
              :bar {:sources
                    (fn [_ _]
                      (let [sources (require :dropbar.sources)]
                        [sources.path
                         {:get_symbols
                          (fn [buf win cursor]
                            (if (next (vim.lsp.get_clients {:bufnr buf}))
                                (sources.lsp.get_symbols buf win cursor)
                                (sources.treesitter.get_symbols buf win cursor)))}]))}})

           ;; Open the breadcrumb pick menu.
           (vim.keymap.set :n :<leader>o.
                           (. (require :dropbar.api) :pick)
                           {:desc "Breadcrumb pick (dropbar)"}))}
