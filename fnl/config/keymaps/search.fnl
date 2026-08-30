(local lset vim.keymap.set)

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