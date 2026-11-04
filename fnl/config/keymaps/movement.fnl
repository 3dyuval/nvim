(local lset vim.keymap.set)
(local ufo (require :ufo))

;; SPEC.md Layer 2 G2 — structural movement = capital HAEI (treewalk)
(lset :n :H "<cmd>Treewalker Left<cr>"
      {:desc "Treewalk out (parent)" :silent true})
(lset :n :I "<cmd>Treewalker Right<cr>"
      {:desc "Treewalk in (child)" :silent true})
;; SPEC.md Layer 2 G2+G3 (fold-walk) — Alt+H/I fold AND walk together:
;;   <M-h> close the enclosing node's fold, then walk OUT to the parent
;;         (collapse-as-you-ascend).
;;   <M-i> open the enclosing node's fold to reveal children, then walk IN
;;         (expand-as-you-descend).
;; The fold always targets the START LINE of the enclosing treesitter node,
;; NOT the raw cursor line — so it behaves the same whether the cursor sits on
;; the block's brace/header or somewhere inside it (fixes off-by-a-level). We
;; move the cursor to that line before folding; the fold op (zo/zc) and the
;; subsequent treewalk then both anchor on the same node. pcall guards E490
;; (no fold under the resolved line). Composes only native treesitter + the
;; public Treewalker left/right — no plugin internals (per G2a).
;; Frees <M-h> from move.nvim (fnl/plugins/move.fnl) and the old <M-h>=gE
;; end-WORD motion (lua/config/keymaps.lua); <M-a>/<M-e> left unbound.
(fn goto-enclosing-node-start []
  ;; Climb to the nearest multi-line ancestor (the foldable block) and park the
  ;; cursor on its first line. Returns false if there's no treesitter node.
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
      ;; SPEC.md Layer 2 G2a — prev sibling, else climb out (row-unchanged proxy)
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

;; SPEC.md Layer 2 G3 — folds = z-prefix + horizontal HAEI
(lset :n :zh :zc {:desc "Close fold (one)" :noremap true})
(lset :n :zi :zo {:desc "Open fold (one)" :noremap true})
(lset :n :zH ufo.closeAllFolds {:desc "Close all folds"})
(lset :n :zI ufo.openAllFolds {:desc "Open all folds"})

(lset [ :n :o :x ] "k" :t {:desc "Till before"} )
(lset [ :n :o :x ] "K" :T {:desc "Till before backward"} )

;; SPEC.md Layer 4 P2 — buffer paging; hands off to kitty tab at the edge
;; DISABLED: <C-PageUp/Down> tab/buffer cycling commented out per request.
;; (lset :n :<C-PageUp> (fn [] ((. (require :workspace.buffer-nav) :prev)))
;;       {:desc "Prev buffer (kitty tab at edge)"})
;; (lset :n :<C-PageDown> (fn [] ((. (require :workspace.buffer-nav) :next)))
;;       {:desc "Next buffer (kitty tab at edge)"})

;; Change nav (hunk within file), global. Context-aware: native ]c/[c when
;; vim.wo.diff is set (diffview / conflicts), gitsigns nav_hunk otherwise.
;; On <C-Up/Down> rather than the g-prefix — arrows carry vertical
;; change-stepping across all buffers. (Overrides LazyVim's default
;; <C-Up/Down> = resize; must load after it.)
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

;; MCP virtual-text nav: step between nvim-mcp's add_virtual_text annotations
;; (the 'mcp_virtual_text' extmark namespace). Distinct from ]d/[d diagnostics.
(lset :n "]i" (fn [] ((. (require :workspace.mcp-virtual-text) :next)))
      {:desc "Next MCP virtual text"})
(lset :n "[i" (fn [] ((. (require :workspace.mcp-virtual-text) :prev)))
      {:desc "Prev MCP virtual text"})

;; Scroll one line (HAEI vertical: a=down, e=up). Explicit so <C-S-A/E>
;; don't fall through to native scroll on an unmapped key.
(lset :n :<C-S-A> "<C-e>" {:desc "Scroll line down"})
(lset :n :<C-S-E> "<C-y>" {:desc "Scroll line up"})


