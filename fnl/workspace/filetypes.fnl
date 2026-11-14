;; Filetype detection the built-in ftdetect misses.
(fn set-ft [pattern ft]
  (vim.api.nvim_create_autocmd [:BufRead :BufNewFile]
                               {: pattern :command (.. "set filetype=" ft)}))

(set-ft [:Fastfile :Appfile :Matchfile :Pluginfile] :ruby)
(set-ft ["*.ex" "*.exs"] :elixir)
(set-ft ["*.heex"] :heex)
(set-ft ["*.log"] :log)

;; env-indirected shebangs confuse bashls (falls back to bash dialect) — force zsh ft
(vim.api.nvim_create_autocmd :BufReadPost
  {:callback (fn []
               (when (string.match (or (vim.fn.getline 1) "") "^#!.*env zsh")
                 (set vim.bo.filetype :zsh)))})

{}
