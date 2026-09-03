{1   "3dyuval/heatsync.nvim"
    :dev true
    :enabled false
    :build "make hooks server"
    :dependencies [  "nvzone/volt" "nvzone/menu"  ]
    :opts {
      :actions [{
          :label "Copy date"
          :key :y
          :action (fn [item]
            (vim.fn.setreg "+" item.date)
            (vim.notify (.. "Copied: " item.date)))}]}
}
