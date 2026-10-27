[{1 "tpope/vim-dadbod"}
 {1 "kristijanhusak/vim-dadbod-ui"
  :dependencies ["tpope/vim-dadbod"]
  :cmd ["DBUI" "DBUIToggle" "DBUIAddConnection" "DBUIFindBuffer"]
  :init (fn []
          (set vim.g.db_ui_use_nerd_fonts 1)
          (set vim.g.db_ui_show_database_icon 1)
          (set vim.g.db_ui_force_echo_notifications 1)
          (set vim.g.db_ui_win_position "left")
          (set vim.g.db_ui_winwidth 40)
          (set vim.g.db_ui_save_location (.. (vim.fn.stdpath "data") "/db_ui"))
          (set vim.g.db_ui_auto_execute_table_helpers 1))}
 {1 "kristijanhusak/vim-dadbod-completion"
  :dependencies ["tpope/vim-dadbod"]
  :ft ["sql" "mysql" "plsql"]}]
