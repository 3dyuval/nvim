(local {: register : del-very-lazy} (require :config.keymaps.register))

(del-very-lazy :n [:<leader>ui :<leader>uI])

(fn aerial-toggle [expand?]
  (fn []
    (let [aerial (require :aerial)]
      (aerial.toggle)
      (if expand? (aerial.tree_open_all) (aerial.tree_close_all)))))

(register "<leader>a"
  {:group "Inspect"
   :o {:cmd (fn [] ((. (require :textobject-hud) :open))) :desc "Textobject HUD"}
   :p {:cmd vim.show_pos                                  :desc "Inspect Pos"}
   :t {:cmd (fn []
              (vim.treesitter.inspect_tree)
              (vim.api.nvim_input "I"))               :desc "Inspect Tree"}
   :a {:cmd (aerial-toggle true)  :desc "Aerial (Outline, expanded)"}
   :h {:cmd (aerial-toggle false) :desc "Aerial (Outline, collapsed)"}
   :f {:cmd "<Cmd>AerialFocus<CR>" :desc "Aerial (Focus)"}
   :c {:cmd "<Cmd>AerialClose<CR>" :desc "Aerial (Close)"}})
