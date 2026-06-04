[{1 "aaronik/treewalker.nvim"
  :opts {:highlight          true
         :highlight_duration 250
         :highlight_group    :CursorLine
         :jumplist           true}}
 {1 "arborist-ts/arborist.nvim"
  :lazy false
  :config (fn []
            ((. (require :arborist) :setup)
             {:update_cadence    :weekly
              :ensure_installed  [:lua :vim :vimdoc :query
                                   :markdown :markdown_inline
                                   :go :rust :ruby
                                   :javascript :typescript :tsx :python
                                   :bash :json :yaml :toml
                                   :elixir :heex :vue
                                   :css :scss :html :kcl]
              :overrides {:kcl {:url "https://github.com/KittyCAD/tree-sitter-kcl"}}}))}
 {1 "nvim-treesitter/nvim-treesitter"
  :branch :main
  :lazy false
  :dependencies ["RRethy/nvim-treesitter-endwise"]
  :config #((. (require :treesitter.setup) :setup))}
 {1 "nvim-treesitter/nvim-treesitter-textobjects"
  :enabled true
  :branch  :main
  :event   :VeryLazy
  :config  #((. (require :treesitter.textobjects) :setup))}]
