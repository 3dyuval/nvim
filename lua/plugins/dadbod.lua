-- [nfnl] fnl/plugins/dadbod.fnl
local function _1_()
  vim.g.db_ui_use_nerd_fonts = 1
  vim.g.db_ui_show_database_icon = 1
  vim.g.db_ui_force_echo_notifications = 1
  vim.g.db_ui_win_position = "left"
  vim.g.db_ui_winwidth = 40
  vim.g.db_ui_save_location = (vim.fn.stdpath("data") .. "/db_ui")
  vim.g.db_ui_auto_execute_table_helpers = 1
  return nil
end
return {{"tpope/vim-dadbod"}, {"kristijanhusak/vim-dadbod-ui", dependencies = {"tpope/vim-dadbod"}, cmd = {"DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer"}, init = _1_}, {"kristijanhusak/vim-dadbod-completion", dependencies = {"tpope/vim-dadbod"}, ft = {"sql", "mysql", "plsql"}}}
