-- We fully opt out of LazyVim's nvim-lspconfig behaviour: this `config` replaces
-- LazyVim's config fn (lazy.nvim keeps only the last `config` per plugin), so its
-- formatter registration / keymaps / diagnostics / inlay-hint / codelens setup
-- never runs. All server config + the meaningful defaults (diagnostics, inlay
-- hints, <leader>cx/cL) live natively in fnl/lsp/setup.fnl instead.
--
-- NOTE on keymaps: <leader>cr/ca/cR and gd/gD/gR moved to Neovim 0.11 native gr*
-- defaults (grn rename · gra code action · grr references · gd definition ·
-- gri implementation · grt type definition · gO document symbols), wired up as
-- nudges in fnl/lsp/setup.fnl.
return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "b0o/schemastore.nvim", -- JSON schemas for jsonls
  },
  config = function()
    require("lsp.setup")
  end,
}
