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

;; pickers

(lset :n :<leader>of
      (fn []
        ((. (require :utils.picker-extensions) :open_explorer)
         {:layout {:preset :fullscreen} :focus :list}))
      {:desc "Explorer (fullscreen)"})

(lset :n :<leader>ff
      (fn []
        ((. (require :utils.picker-extensions) :open_explorer)
         {:layout {:preset :fullscreen} :focus :input}))
      {:desc "Explorer (fullscreen, focus input)"})

(lset :n :<leader>fE
      (fn []
        ((. (require :utils.picker-extensions) :open_explorer)
         {:layout {:preset :sidebar} :focus :list :auto_close false}))
      {:desc "Explorer (persistent, no auto-close)"})

(lset :n :<leader>fF
      (fn []
        (Snacks.picker.buffers {:layout {:preset :fullscreen}}))
      {:desc "Buffers (fullscreen)"})

(lset :n :<C-/>
      (fn [] (Snacks.picker.grep))
      {:desc "Grep (top level)"})

(lset :n :<leader>/
      (fn [] ((. (require :workspace.grep) :grep-current-buffer-dir)))
      {:desc "Grep (current buffer's dir)"})
