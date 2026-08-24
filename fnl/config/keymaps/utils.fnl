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
      (fn [] ((. (require :workspace.session) :open)))
      {:desc "Session picker"})

(lset :n :<leader>tt
      (fn [] (vim.api.nvim_feedkeys ":terminal " :t false))
      {:desc "Terminal prefill"})

(lset [:n :x] :<leader>rs
      (fn [] ((. (require :workspace.kitty-send) :send)))
      {:desc "Kitty: send line/selection"})

(lset :n :<leader>rr
      (fn [] ((. (require :workspace.kitty-send) :open) :hsplit))
      {:desc "Kitty: open runner (bottom)"})

(lset :n :<leader>rR
      (fn [] ((. (require :workspace.kitty-send) :open) :vsplit))
      {:desc "Kitty: open runner (right)"})

(lset :n :<leader>rg
      (fn []
        (let [grug-far (require :grug-far)
              entry (grug-far.get_last_history_entry)]
          (grug-far.open {:prefills entry})))
      {:desc "Find and replace - last search (GrugFar)"})

(lset :n :<leader>rG
      (fn []
        ((. (require :grug-far) :open)
         {:prefills {:paths (vim.fn.expand :%)}}))
      {:desc "Find and replace - current file (GrugFar)"})

(lset :n :<leader>rt
      (fn [] ((. (require :workspace.grug-history) :pick)))
      {:desc "Find and replace - history picker (GrugFar)"})

(lset :v :<leader>rg
      (fn []
        ((. (require :grug-far) :with_visual_selection)
         {:visualSelectionUsage :prefill-search}))
      {:desc "Find and replace - selection as search (GrugFar)"})

(lset :v :<leader>rG
      (fn []
        ((. (require :grug-far) :with_visual_selection)
         {:visualSelectionUsage :operate-within-range}))
      {:desc "Find and replace - within selection (GrugFar)"})
