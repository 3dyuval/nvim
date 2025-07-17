return {
  "stevearc/conform.nvim",
  dependencies = { "williamboman/mason.nvim" }, -- Ensure Mason loads first
  opts = {
    -- Enhanced error handling and logging
    notify_on_error = true,
    log_level = vim.log.levels.DEBUG,
    
    formatters_by_ft = {
      typescript = { "biome" },
      javascript = { "biome" }, 
      typescriptreact = { "biome" },
      javascriptreact = { "biome" },
      json = { "biome" },
      html = { "prettier" },
      htmlangular = { "prettier" },
      vue = { "prettier" },
    },
    formatters = {
      biome = {
        command = "biome",
        args = {
          "format",
          "--config-path",
          vim.fn.stdpath("config") .. "/biome.json",
          "--stdin-file-path",
          "$FILENAME",
        },
        stdin = true,
        -- Only consider exit code 0 as success
        exit_codes = { 0 },
        -- Custom error handling
        env = function(self, ctx)
          return { BIOME_LOG_LEVEL = "debug" }
        end,
      },
      -- prettier config would go here if you need to override it
    },
    
  },
  
  init = function()
    -- Enhanced error notification
    vim.api.nvim_create_autocmd("User", {
      pattern = "ConformFormatterError",
      callback = function(args)
        vim.notify(
          string.format("Formatter %s failed. Run :ConformInfo for details", args.data.formatter_name),
          vim.log.levels.ERROR
        )
        
        -- Auto-run ConformInfo after a short delay
        vim.defer_fn(function()
          vim.cmd("ConformInfo")
        end, 1000)
      end
    })
    
    -- Add keymap for easy access to ConformInfo
    vim.keymap.set("n", "<leader>ci", "<cmd>ConformInfo<cr>", { desc = "Conform Info" })
  end,
}
