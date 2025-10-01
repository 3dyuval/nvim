return {
  {
    "tpope/vim-dadbod",
    cmd = { "DB", "DBUI" },
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = { "tpope/vim-dadbod" },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    init = function()
      -- Your DBUI configuration
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_show_database_icon = 1
      vim.g.db_ui_force_echo_notifications = 1
      vim.g.db_ui_win_position = "left"
      vim.g.db_ui_winwidth = 40

      -- Save/restore queries
      vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"

      -- Auto execute table helpers
      vim.g.db_ui_auto_execute_table_helpers = 1
    end,
  },
  {
    "kristijanhusak/vim-dadbod-completion",
    dependencies = { "hrsh7th/nvim-cmp", "tpope/vim-dadbod" },
    ft = { "sql", "mysql", "plsql" },
    config = function()
      require("cmp").setup.filetype({ "sql", "mysql", "plsql" }, {
        sources = {
          { name = "vim-dadbod-completion" },
          { name = "buffer" },
          { name = "luasnip" },
        },
      })
    end,
  },
}