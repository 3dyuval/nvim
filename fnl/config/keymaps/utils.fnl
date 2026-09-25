(local lset vim.keymap.set)

(lset :n :<leader>rk (. (require :utils.editor) :reload_keymaps) {:desc "Reload keymaps"})

(lset :n :<leader>as "ScratchIssues <CR>"
      {:desc "Scratch: All Issues"})

(lset :n :<leader>?
      (fn [] ((. (require :which-key) :show) {:global false}))
      {:desc "Which-key: this buffer's keymaps"})

(lset :n :<leader>gG ":DiffviewGraph<CR>"
      {:desc "Diffview graph"})

(lset :n :<leader>gn
      (fn [] (vim.cmd (.. "Neogit kind=vsplit cwd=" (vim.fn.expand "%:p:h"))))
      {:desc "Neogit (side)"})

(lset :n :<leader>gc
      ":Neogit commit<CR>"
      {:desc "Neogit commit"})

(lset :n :<leader>gl
      (fn [] (vim.cmd "Neogit log a"))
      {:desc "Neogit log"})


(lset :n :<leader>gs ":Gitsigns stage_hunk<CR>"
      {:desc "Stage hunk (Gitsigns)"})

(lset :n :<leader>gh (fn [] (vim.cmd "DiffviewFileHistory ."))
      {:desc "Diffview repo log"})
(lset :n :P (fn [] ((. (require :hover) :open)))
                   {:desc "Hover"})

;; Override LazyVim's <leader>cf: it delegates to conform.format with no
;; lsp_format, so filetypes without a conform formatter (e.g. json -> jsonls)
;; report "No formatter available". Call conform directly with the LSP fallback.
(lset [:n :x] :<leader>cf
      (fn [] ((. (require :conform) :format) {:lsp_format :fallback}))
      {:desc "Format"})
