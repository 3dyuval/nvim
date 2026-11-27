(local {: register} (require :config.keymaps.register))
(local lset vim.keymap.set)

(register "<leader>ug"
  {:group "Git Signs"
   :g {:cmd "<leader>uG"                          :desc "Toggle Git Signs"}
   :l {:cmd ":Gitsigns toggle_linehl<CR>"         :desc "Toggle line highlights"}
   :n {:cmd ":Gitsigns toggle_numhl<CR>"          :desc "Toggle number highlights"}
   :w {:cmd ":Gitsigns toggle_word_diff<CR>"      :desc "Toggle word diff"}
   :b {:cmd ":Gitsigns toggle_current_line_blame<CR>" :desc "Toggle current line blame"}})

(lset :n :<leader>ul (fn [] ((. (require :lensline) :toggle_view)))
      {:desc "Toggle lensline"})

(lset :n :<leader>um ":Neominimap Toggle<CR>"
      {:desc "Toggle minimap"})

(register "<leader>un"
  {:group "Notifications"
   :n {:cmd (fn [] ((. (require :snacks) :notifier :hide))) :desc "Dismiss All Notifications"}
   :a {:cmd ":NoiceAll<CR>"  :desc "Show all notifications"}
   :l {:cmd ":NoiceLast<CR>" :desc "Show last notification"}})

(lset :n :<leader>unp
      (fn []
        (let [messages ((. (require :noice.message.manager) :get) {} {:history true :sort true})
              last (. messages (length messages))]
          (when last
            (vim.fn.setreg "+" (last:content))
            (vim.notify "Copied to clipboard"))))
      {:desc "Copy last notification to clipboard"})
