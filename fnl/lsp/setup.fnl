;; Global capabilities for all servers
(vim.lsp.config "*" {:capabilities {:positionEncoding :utf-8}
                     :root_markers [:.git]})

;; Enable all servers
(vim.lsp.enable [:lua_ls
                 :rust_analyzer
                 :vtsls
                 :vue_ls
                 :elixirls
                 :bashls
                 :cssls
                 :jsonls
                 :kcl_lsp
                 :fennel_ls])

(vim.lsp.config :lua_ls
                {:settings {:Lua {:runtime {:version :LuaJIT}
                                  :diagnostics {:globals [:vim]}
                                  :workspace {:checkThirdParty false}
                                  :telemetry {:enable false}}}})

(vim.lsp.config :rust_analyzer
                {:settings {:rust-analyzer {:cargo {:allFeatures true
                                                    :loadOutDirsFromCheck true
                                                    :buildScripts {:enable true}}
                                            :checkOnSave {:command :clippy}
                                            :procMacro {:enable true}}}})

(local vue-plugin-location
       (.. (vim.fn.stdpath :data)
           "/mason/packages/vue-language-server/node_modules/@vue/language-server"))

(local ignored-diag-codes {7047 true 7044 true 6133 true})

(vim.lsp.config :vtsls
                ;; vtsls is the TS companion for vue_ls's hybrid mode (mandatory since
                ;; Volar 3.0 removed takeover mode). It attaches to .vue and loads
                ;; @vue/typescript-plugin so vue_ls can forward tsserver requests to it.
                {:filetypes [:typescript
                             :typescriptreact
                             :javascript
                             :javascriptreact
                             :vue]
                 :settings {:vtsls {:autoUseWorkspaceTsdk false
                                    :tsserver {:globalPlugins [{:name "@vue/typescript-plugin"
                                                                :location vue-plugin-location
                                                                :languages [:vue]
                                                                :configNamespace :typescript}]}}
                            :typescript {:preferences {:importModuleSpecifier :relative}
                                         :inlayHints {:parameterNames {:enabled :literals}
                                                      :variableTypes {:enabled true}
                                                      :propertyDeclarationTypes {:enabled true}
                                                      :enumMemberValues {:enabled true}}}
                            :javascript {:implicitProjectConfig {:checkJs true
                                                                 :strictNullChecks false
                                                                 :strictFunctionTypes false}
                                         :lib [:ES2020 :DOM]}}
                 :handlers {:textDocument/publishDiagnostics (fn [err
                                                                  result
                                                                  ctx]
                                                               (when (and result
                                                                          result.diagnostics)
                                                                 (set result.diagnostics
                                                                      (vim.tbl_filter (fn [d]
                                                                                        (not (. ignored-diag-codes
                                                                                                d.code)))
                                                                                      result.diagnostics)))
                                                               ((. vim.lsp.handlers
                                                                   :textDocument/publishDiagnostics) err
                                                                                                                                                                                         result
                                                                                                                                                                                         ctx))
                            :textDocument/documentSymbol (fn [err
                                                              result
                                                              ctx
                                                              config]
                                                           ;; Filter flat import/keyword symbols vtsls returns for Vue <script setup>
                                                           ;; All symbols are kind 5 (Class) so filter by name pattern instead
                                                           (let [result (if (and result
                                                                                 (= (. vim.bo
                                                                                       ctx.bufnr
                                                                                       :filetype)
                                                                                    :vue))
                                                                            (vim.tbl_filter (fn [sym]
                                                                                              (let [n sym.name]
                                                                                                (not (or (= n
                                                                                                            :import)
                                                                                                         (= n
                                                                                                            :from)
                                                                                                         (= n
                                                                                                            :export)
                                                                                                         (vim.startswith n
                                                                                                                         "import ")
                                                                                                         (vim.startswith n
                                                                                                                         :script)))))
                                                                                            result)
                                                                            result)]
                                                             ((. vim.lsp.handlers
                                                                 :textDocument/documentSymbol) err
                                                                                                                                                                                 result
                                                                                                                                                                                 ctx
                                                                                                                                                                                 config)))}})

;; Hybrid mode is mandatory since Volar 3.0 (takeover mode removed in #5248).
;; vue_ls owns template/CSS and forwards TS requests to vtsls. It produces NO
;; usable document symbols in this mode — the .vue outline comes from treesitter
;; (aerial.nvim), not LSP. rename is owned by vtsls; documentSymbol on vue_ls is
;; disabled so the picker doesn't query a server that returns nothing.
(vim.lsp.config :vue_ls {:filetypes [:vue]
                         :init_options {:vue {:hybridMode true}}
                         :settings {:vue {:complete {:casing {:tags :kebab
                                                              :props :kebab}}}}
                         :on_init (fn [client]
                                    ;; vtsls is the sole authority for TS-semantic features on .vue.
                                    ;; vue_ls advertises these but stalls direct requests in hybrid
                                    ;; mode, which hangs vim.lsp.buf aggregation — grr/gra/gd appear
                                    ;; broken. Disable them so only vtsls (which answers correctly)
                                    ;; responds. vue_ls keeps template/style completion + diagnostics.
                                    (each [_ cap (ipairs [:renameProvider
                                                          :documentSymbolProvider
                                                          :referencesProvider
                                                          :codeActionProvider
                                                          :definitionProvider
                                                          :implementationProvider
                                                          :typeDefinitionProvider])]
                                      (tset client.server_capabilities cap
                                            false)))})

(vim.lsp.config :elixirls
                {:settings {:elixirls {:lint_on_save true
                                       :format_on_save true
                                       :use_dialyzer true}}})

(vim.lsp.config :bashls
                {:cmd [:bash-language-server :start]
                 :filetypes [:sh]
                 :single_file_support true
                 :settings {:bashIde {:explainshellEndpoint "https://explainshell.com"
                                      :shellcheckPath :shellcheck
                                      :globPattern "**/*@(.sh|.inc|.bash|.command)"}}})

(vim.lsp.config :cssls
                ;; Dropped :vue — cssls misparsed <script> blocks into junk document
                ;; symbols. vue_ls handles <style> blocks itself in non-hybrid mode.
                {:filetypes [:css :scss :less]
                 :settings {:css {:validate true}
                            :scss {:validate true}
                            :less {:validate true}}})

(vim.lsp.config :jsonls
                {:settings {:json {:schemas ((. (require :schemastore) :json
                                                :schemas))
                                   :validate {:enable true}}}})

(vim.lsp.config :kcl_lsp {:cmd [(vim.fn.expand "~/.local/bin/kcl-language-server")
                                :server
                                :-s]
                          :filetypes [:kcl]
                          :root_markers [:.git]
                          :single_file_support true})

;; --- LSP keymap migration → Neovim 0.11 native gr* defaults ---
;; Old custom keys now noop and notify the native replacement, to retrain
;; muscle memory. (Definition has no gr* default, so gd stays functional below.)
(local lsp-nudges {:<leader>cr "grn  (rename)"
                   :<leader>cR "grr  (references)"
                   :<leader>ca "gra  (code action)"
                   :gD "grt  (go to definition)"
                   :gR "grr  (references)"})

(each [lhs target (pairs lsp-nudges)]
  (vim.keymap.set :n lhs
                  (fn []
                    (vim.notify (.. "Deprecated keymap — use " target)
                                vim.log.levels.WARN {:title "LSP keymap moved"}))
                  {:desc (.. "moved -> " target) :silent true}))

;; grt natively does type_definition; remap it to go-to-definition instead,
;; which is template-aware in Vue (jumps to component files). No bare custom gd.
;; grt jumps straight to the first result; grT keeps the full quickfix list.
(fn goto-definition-first []
  (vim.lsp.buf.definition {:on_list (fn [o]
                                      (let [it (. o.items 1)]
                                        (when it
                                          (vim.fn.setqflist {} " "
                                                            {:title o.title
                                                             :items [it]})
                                          (vim.cmd :cfirst))))}))

(vim.keymap.set :n :grt goto-definition-first
                {:desc "Go to definition (first)"})

(vim.keymap.set :n :grT vim.lsp.buf.definition
                {:desc "Go to definition (list)"})

;; grs: all document symbols in a bottom layout. .vue has no usable LSP symbols
;; (Volar 3.x hybrid), so it falls back to the injected-TS treesitter extractor.
(vim.keymap.set :n :grs
                (fn []
                  (if (= vim.bo.filetype :vue)
                      ((. (require :lsp.vue-symbols) :pick) :bottom)
                      ((. (require :snacks) :picker :lsp_symbols) {:layout :bottom})))
                {:desc :Symbols})

