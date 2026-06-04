[{1 "so1ve/textobject-hud.nvim"
  :dependencies ["nvim-mini/mini.nvim"
                 "nvim-treesitter/nvim-treesitter-textobjects"]
  :keys [{1 "<leader>o"
          2 #((. (require :textobject-hud) :open))
          :desc "Textobject HUD"}]
  :opts (fn []
          (let [hud   (require :textobject-hud)
                tbobj (require :treesitter.textobjects)]
            {:sources   [hud.sources.treesitter]
             :key_hints (tbobj.hud-hints)}))}]
