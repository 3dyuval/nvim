(local {: register} (require :config.keymaps.register))

(register "<leader>c"
  {:d {:group "Database"
       :u {:cmd ":DBUIToggle<CR>"        :desc "Toggle DBUI"}
       :f {:cmd ":DBUIFindBuffer<CR>"    :desc "Find DB buffer"}
       :a {:cmd ":DBUIAddConnection<CR>" :desc "Add connection"}
       :r {:cmd ":DBUIRenameBuffer<CR>"  :desc "Rename buffer"}
       :l {:cmd ":DBUILastQueryInfo<CR>" :desc "Last query info"}}})
