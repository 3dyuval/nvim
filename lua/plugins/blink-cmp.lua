return {
  -- Disable friendly-snippets (use only custom snippets)
  { "rafamadriz/friendly-snippets", enabled = false },

  {
    "saghen/blink.cmp",
    dependencies = { "ribru17/blink-cmp-spell" },

    opts = {
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "spell" },
        per_filetype = {
          sql = { "dadbod", "buffer" },
          mysql = { "dadbod", "buffer" },
          plsql = { "dadbod", "buffer" },
          -- Disable snippets for JS/TS/Vue (use LSP completions only)
          javascript = { "lsp", "path", "buffer" },
          javascriptreact = { "lsp", "path", "buffer" },
          typescript = { "lsp", "path", "buffer" },
          typescriptreact = { "lsp", "path", "buffer" },
          vue = { "lsp", "path", "snippets", "buffer" }, -- custom snippets only (friendly-snippets disabled)
          html = { "lsp", "path", "buffer" },
          css = { "lsp", "path", "buffer" },
          scss = { "lsp", "path", "buffer" },
          json = { "lsp", "path", "buffer" },
        },
        providers = {
          lsp = {
            name = "lsp",
            enabled = true,
            module = "blink.cmp.sources.lsp",
            fallbacks = { "buffer" },
          },
          dadbod = {
            name = "Dadbod",
            module = "vim_dadbod_completion.blink",
          },
          spell = {
            name = "Spell",
            module = "blink-cmp-spell",
            opts = {
              enable_in_context = function()
                local curpos = vim.api.nvim_win_get_cursor(0)
                local captures = vim.treesitter.get_captures_at_pos(0, curpos[1] - 1, curpos[2] - 1)
                local in_spell_capture = false
                for _, cap in ipairs(captures) do
                  if cap.capture == "spell" then
                    in_spell_capture = true
                  elseif cap.capture == "nospell" then
                    return false
                  end
                end
                return in_spell_capture
              end,
            },
          },
        },
      },
      completion = {
        accept = {
          auto_brackets = {
            enabled = true,
            default_brackets = { "(", ")" },
            kind_resolution = {
              enabled = true,
              blocked_filetypes = { "typescriptreact", "javascriptreact", "typescript", "javascript" },
            },
            semantic_token_resolution = {
              enabled = true,
              blocked_filetypes = { "typescriptreact", "javascriptreact", "typescript", "javascript" },
              timeout_ms = 400,
            },
          },
        },
      },
    },
  },
}
