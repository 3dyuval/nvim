(local lset vim.keymap.set)

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

(lset :n :<leader>qs
      (fn [] ((. (require :utils.session-picker) :open)))
      {:desc "Session picker"})

(lset :n :<leader>tt
      (fn [] (vim.api.nvim_feedkeys ":terminal " :t false))
      {:desc "Terminal prefill"})

(lset :n :<leader>fo
      (fn []
        ((. (require :utils.picker-extensions) :open_explorer)
         {:layout {:preset :default} :focus :list}))
      {:desc "Explorer (float)"})

(lset :n :<leader>fO
      (fn []
        ((. (require :utils.picker-extensions) :open_explorer)
         {:layout {:preset :default} :focus :input}))
      {:desc "Explorer (float, focus input)"})

(lset :n :<leader>of
      (fn []
        ((. (require :utils.picker-extensions) :open_explorer)
         {:layout {:preset :sidebar} :focus :list}))
      {:desc "Explorer (sidebar)"})

(lset :n :<leader>oF
      (fn []
        ((. (require :utils.picker-extensions) :open_explorer)
         {:layout {:preset :sidebar} :focus :input}))
      {:desc "Explorer (sidebar, focus input)"})

(lset :n :<C-/>
      (fn [] ((. (require :picker.grep) :grep-current-buffer-dir)))
      {:desc "Grep in current file's directory"})

(lset :n :<leader>rg
      ":GrugFar<CR>"
      {:desc "Find and replace (GrugFar)"}
      )

(lset :n :<leader>rG
      (fn []
        ((. (require :grug-far) :open)
         {:prefills {:paths (vim.fn.expand :%)}}))
      {:desc "Find and replace - current file (GrugFar)"})

;; rr: reopen grug-far prefilled with the last history entry.
;; TODO: implement when approved — grug-far.nvim#590
;; [Request]: top level grug-far.history_entries to open with last search
(lset :n :<leader>rr
      (fn []
        (vim.notify "grug-far: last-search reopen pending API (see grug-far.nvim#590)"
                    vim.log.levels.INFO))
      {:desc "Find and replace - last search (GrugFar) [TODO #590]"})

;; visual rg: use selection as the search string
(lset :v :<leader>rg
      (fn []
        ((. (require :grug-far) :with_visual_selection)
         {:visualSelectionUsage :prefill-search}))
      {:desc "Find and replace - selection as search (GrugFar)"})

;; visual rG: operate only within the selected range
(lset :v :<leader>rG
      (fn []
        ((. (require :grug-far) :with_visual_selection)
         {:visualSelectionUsage :operate-within-range}))
      {:desc "Find and replace - within selection (GrugFar)"})
