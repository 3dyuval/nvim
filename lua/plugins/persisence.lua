return {
  "folke/persistence.nvim",
  opts = {
    options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" },
    -- Add patterns to ignore
    pre_save = function()
      -- Close neogit buffers before saving session
      vim.api.nvim_exec_autocmds("User", { pattern = "PersistenceSavePre" })
    end,
  },
}
