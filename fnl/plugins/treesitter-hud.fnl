;; <leader>io keymap lives in config/keymaps/inspect.fnl; its require lazy-loads this.
[{1 "so1ve/textobject-hud.nvim"
  :dependencies ["nvim-mini/mini.nvim"
                 "nvim-treesitter/nvim-treesitter-textobjects"]
  :lazy true
  :opts (fn []
          (let [hud   (require :textobject-hud)
                tbobj (require :treesitter.textobjects)]
            {:sources   [hud.sources.treesitter]
             :key_hints (tbobj.hud-hints)}))}]
