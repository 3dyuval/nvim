(local lset vim.keymap.set)

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

(lset :n :<leader>fF
      (fn []
        (Snacks.picker.buffers {:layout {:preset :fullscreen}}))
      {:desc "Buffers (fullscreen)"})

(lset :n :<C-/>
      (fn [] (vim.cmd "Yazi"))
      {:desc "Yazi at current file"})

(lset :n :<M-/>
      (fn []
        (let [last (vim.fn.getreg "/")]
          (vim.api.nvim_feedkeys (.. "/" last) :t false)))
      {:desc "Search prefilled with last term"})

(lset :n :<leader>/
      (fn [] (Snacks.picker.grep))
      {:desc "Grep (top level)"})
