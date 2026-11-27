;; nvim-surround v4 auto-binds ys/ds/cs itself; only the visual triggers are
;; owned here (spec sets nvim_surround_no_visual_mappings).
(local lset vim.keymap.set)

(lset :x :s "<Plug>(nvim-surround-visual)"
      {:desc "Surround visual selection"})
(lset :x :gS "<Plug>(nvim-surround-visual-line)"
      {:desc "Surround visual selection (newlines)"})

((. (require :which-key) :add)
 [["ys" {:group "Add surround"}]
  ["yS" {:group "Add surround (newlines)"}]
  ["ds" {:group "Delete surround"}]
  ["cs" {:group "Change surround"}]
  ["cS" {:group "Change surround (newlines)"}]
  ["s" {:mode :x :group "Surround"}]
  ["gS" {:mode :x :group "Surround (newlines)"}]])
