;; <leader>i* inspection (ip/it were LazyVim's ui/uI).
(local {: register : del-very-lazy} (require :config.keymaps.register))

(del-very-lazy :n [:<leader>ui :<leader>uI])

(register "<leader>i"
  {:group "Inspect"
   :o {:cmd (fn [] ((. (require :textobject-hud) :open))) :desc "Textobject HUD"}
   :p {:cmd vim.show_pos                                  :desc "Inspect Pos"}
   :t {:cmd (fn []
              (vim.treesitter.inspect_tree)
              (vim.api.nvim_input "I"))               :desc "Inspect Tree"}})
