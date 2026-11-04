;; harpoon2 — a small, hand-curated set of hot files per project, reached by
;; stable keys. All bindings live under <leader>h with left-hand second keys:
;;   ha      add current file to the list
;;   he      toggle the quick menu (editable buffer: reorder/delete lines)
;;   h1..h4  jump straight to file 1..4
;; harpoon2 sets no keymaps itself, so everything is bound here via :keys.
;; The key callbacks require harpoon lazily (after :config runs setup), so the
;; list/ui handles come from the initialized singleton, not a load-time stub.
(fn add []
  (let [h (require :harpoon)] (: (h:list) :add)))

(fn menu []
  (let [h (require :harpoon)] (h.ui:toggle_quick_menu (h:list))))

(fn jump [n]
  (fn [] (let [h (require :harpoon)] (: (h:list) :select n))))

{1 "ThePrimeagen/harpoon"
 :branch "harpoon2"
 :dependencies ["nvim-lua/plenary.nvim"]
 :keys [{1 :<leader>ha 2 add  :desc "Harpoon: add file"}
        {1 :<leader>he 2 menu :desc "Harpoon: menu"}
        {1 :<leader>h1 2 (jump 1) :desc "Harpoon: file 1"}
        {1 :<leader>h2 2 (jump 2) :desc "Harpoon: file 2"}
        {1 :<leader>h3 2 (jump 3) :desc "Harpoon: file 3"}
        {1 :<leader>h4 2 (jump 4) :desc "Harpoon: file 4"}]
 :config (fn [] ((. (require :harpoon) :setup) {}))}
