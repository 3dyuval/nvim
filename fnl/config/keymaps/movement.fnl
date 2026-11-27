(local lset vim.keymap.set)

;; SPEC.md Layer 2 G2 — structural movement = capital HAEI (treewalk).
;; H/I skip folded targets: closed fold = opaque.
;; dir (left/right); if in a closed fold,
;; then next sibling (down); repeat till unfolded or stuck.
(fn treewalk-skip-folded [dir]
  (fn []
    (let [tw (require :treewalker)
          origin (vim.api.nvim_win_get_cursor 0)]
      ((. tw dir))
      ;; if `down` in the same fold (no progress),
      ;; then stuck — restore origin.
      (var guard 50)
      (var stuck false)
      (while (and (not stuck) (> guard 0)
                  (not= (vim.fn.foldclosed (vim.fn.line ".")) -1))
        (set guard (- guard 1))
        (let [fold-start (vim.fn.foldclosed (vim.fn.line "."))]
          (tw.down)
          (when (= (vim.fn.foldclosed (vim.fn.line ".")) fold-start)
            (set stuck true))))
      (when (or stuck (= guard 0))
        (vim.api.nvim_win_set_cursor 0 origin)))))
(lset :n :H (treewalk-skip-folded :left)
      {:desc "Treewalk out (skip folded)" :silent true})
(lset :n :I (treewalk-skip-folded :right)
      {:desc "Treewalk in (skip folded)" :silent true})
;; SPEC.md Layer 2 G2b — fold-walk: Alt+H/I fold + walk together.
;;   <M-h> close enclosing fold, then out.
;;   <M-i> open enclosing fold, then in.
;; fold on enclosing node's START LINE, not cursor line — stable in block.
(fn goto-enclosing-node-start []
  ;; cursor to first line of nearest multi-line ancestor (foldable block).
  ;; if no treesitter node, then false.
  (if (not (pcall vim.treesitter.get_parser 0))
      false
      (let [node (vim.treesitter.get_node)]
        (if (not node)
            false
            (do
              (var block nil)
              (var iter node)
              (while (and iter (not block))
                (let [(sr _ er _) (iter:range)]
                  (if (> er sr)
                      (set block iter)
                      (set iter (iter:parent)))))
              (when block
                (let [(sr sc) (block:range)]
                  (vim.api.nvim_win_set_cursor 0 [(+ sr 1) sc])))
              (not= block nil))))))
(lset :n :<M-h>
      (fn []
        (when (goto-enclosing-node-start)
          (pcall vim.cmd "normal! zc"))
        ((. (require :treewalker) :left)))
      {:desc "Close enclosing fold + treewalk out" :silent true})
(lset :n :<M-i>
      (fn []
        (when (goto-enclosing-node-start)
          (pcall vim.cmd "normal! zo"))
        ((. (require :treewalker) :right)))
      {:desc "Open enclosing fold + treewalk in" :silent true})
(lset :n :E
      ;; SPEC.md Layer 2 G2a — prev sibling; if row unchanged, then out.
      (fn []
        (when (pcall vim.treesitter.get_parser 0)
          (let [tw (require :treewalker)
                row (vim.fn.line ".")]
            (tw.move_up)
            (when (= row (vim.fn.line "."))
              (tw.move_out)))))
      {:desc "Treewalk prev sibling (else out)" :silent true})
(lset :n :A "<cmd>Treewalker Down<cr>"
      {:desc "Treewalk next sibling" :silent true})

;; SPEC.md Layer 2 G3 — folds = z-prefix + horizontal HAEI.
(lset :n :zh :zc {:desc "Close fold (one)" :noremap true})
(lset :n :zi :zo {:desc "Open fold (one)" :noremap true})
(lset :n :zH :zM {:desc "Close all folds" :noremap true})
(lset :n :zI :zR {:desc "Open all folds" :noremap true})

(lset [ :n :o :x ] "k" :t {:desc "Till before"} )
(lset [ :n :o :x ] "K" :T {:desc "Till before backward"} )

;; buffer paging, wraps at ends.
(lset :n :<C-k> "<cmd>bprevious<cr>" {:desc "Previous buffer"})
(lset :n :<C-y> "<cmd>bnext<cr>" {:desc "Next buffer"})

;; change nav (hunk in file), global.
;; if vim.wo.diff (diffview/conflicts), then native ]c/[c; else gitsigns nav_hunk.
;; on <C-Up/Down>, not g-prefix. overrides LazyVim resize — load after it.
(local gs (require :gitsigns))
(lset :n :<C-Down>
      (fn []
        (if vim.wo.diff
            (vim.cmd.normal {1 "]c" :bang true})
            (gs.nav_hunk "next" {:target "all"})))
      {:desc "Next git hunk"})
(lset :n :<C-Up>
      (fn []
        (if vim.wo.diff
            (vim.cmd.normal {1 "[c" :bang true})
            (gs.nav_hunk "prev" {:target "all"})))
      {:desc "Prev git hunk"})

;; MCP virtual-text nav.
;; targets nvim-mcp 'mcp_virtual_text' extmark ns.
;; not ]d/[d diagnostics.
(lset :n "]i" (fn [] ((. (require :workspace.mcp-virtual-text) :next)))
      {:desc "Next MCP virtual text"})
(lset :n "[i" (fn [] ((. (require :workspace.mcp-virtual-text) :prev)))
      {:desc "Prev MCP virtual text"})

;; scroll one line (HAEI vertical: a=down, e=up).
;; explicit, else <C-S-A/E> fall through to native scroll on unmapped key.
(lset :n :<C-S-A> "<C-e>" {:desc "Scroll line down"})
(lset :n :<C-S-E> "<C-y>" {:desc "Scroll line up"})


