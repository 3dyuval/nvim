;; Surround keymaps (nvim-surround v4). v4 auto-binds ys/ds/cs from the
;; plugin's plugin/ dir; the plugin spec disables the default visual `S`/`gS`
;; (nvim_surround_no_visual_mappings), so the visual trigger is owned here:
;; native v/V enter visual, select, then `s` surrounds.
(local lset vim.keymap.set)

(lset :x :s "<Plug>(nvim-surround-visual)"
      {:desc "Surround visual selection"})
(lset :x :gS "<Plug>(nvim-surround-visual-line)"
      {:desc "Surround visual selection (newlines)"})

((. (require :which-key) :add)
 [["ys" :group "Add surround"]
  ["yS" :group "Add surround (newlines)"]
  ["ds" :group "Delete surround"]
  ["cs" :group "Change surround"]
  ["cS" :group "Change surround (newlines)"]
  ["s" :mode :x :group "Surround"]
  ["gS" :mode :x :group "Surround (newlines)"]])
