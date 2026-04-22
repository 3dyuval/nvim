-- Helper to run LSP code action by kind
local function lsp_action(kind)
  vim.lsp.buf.code_action({
    apply = true,
    context = {
      only = { kind },
      diagnostics = {},
    },
  })
end

-- Helper to execute vtsls command with file path
local function vtsls_cmd(command, filepath)
  vim.lsp.buf.execute_command({
    command = command,
    arguments = { filepath },
  })
end

-- Export organize imports function for use in keymaps
local M = {}

M.organize_imports = function()
  -- Organize + Remove unused imports (Biome + TypeScript hybrid)
  local bufnr = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(bufnr)

  if filepath == "" or vim.fn.filereadable(filepath) == 0 then
    vim.notify("No valid file to organize and clean imports", vim.log.levels.WARN)
    return
  end

  local biome_available = vim.fn.executable("biome") == 1

  if biome_available then
    -- Use biome for both organize imports and remove unused imports
    local cmd = {
      "biome",
      "check",
      "--write",
      "--unsafe", -- Enable unsafe fixes to remove unused imports
      "--formatter-enabled=false", -- Only assist/linter actions
      filepath,
    }
    vim.fn.system(cmd)
    vim.cmd("silent! checktime")
    -- Format to fix indentation (biome organize uses 4-space, we want 2)
    require("conform").format({
      bufnr = bufnr,
    })
  else
    -- Fallback: Use vtsls commands
    vtsls_cmd("typescript.organizeImports", filepath)
    vim.schedule(function()
      vtsls_cmd("typescript.removeUnusedImports", filepath)
    end)
  end
end

M.organize_imports_and_fix = function()
  -- First organize imports
  M.organize_imports()

  -- Then fix all diagnostics using vtsls
  vim.schedule(function()
    lsp_action("source.fixAll.ts")
  end)
end

return {
  "stevearc/conform.nvim",
  dependencies = { "mason-org/mason.nvim" }, -- Ensure Mason loads first
  opts = {
    default_format_opts = {
      timeout_ms = 3000,
      async = false,
      quiet = false,
      lsp_format = "fallback", -- Use LSP when no formatter configured (e.g., Vue)
    },
    formatters_by_ft = {
      lua = { "lua-formatter" },
      dts = { "zmk_keymap_formatter" }, -- Custom ZMK keymap formatter
      go = { "goimports", "gofumpt" }, -- Go: organize imports + format
      rust = { "rustfmt" },
      ruby = { "rubocop" },
      elixir = { "mix" },
      typescript = { "biome" },
      javascript = { "biome" },
      typescriptreact = { "biome" },
      javascriptreact = { "biome" },
      json = { "biome" },
      html = { "biome" },
      vue = { "biome" },
      css = { "biome" },
      scss = { "biome" },
    },
    formatters = {
      -- RuboCop with global config
      rubocop = {
        command = "rubocop",
        args = {
          "--autocorrect-all",
          "--config",
          vim.fn.stdpath("config") .. "/formatters/rubocop.yml",
          "--format",
          "quiet",
          "--stderr",
          "--stdin",
          "$FILENAME",
        },
        stdin = true,
      },
      -- Custom ZMK keymap formatter
      zmk_keymap_formatter = {
        command = function()
          -- Look for format_keymap.py in the current project root
          local root = vim.fs.find({ "format_keymap.py" }, {
            upward = true,
          })[1]
          if root then
            return vim.fs.dirname(root) .. "/format_keymap.py"
          end
          -- Fallback to clang-format if custom formatter not found
          return "clang-format"
        end,
        stdin = true,
        args = {},
      },
    },
  },
  -- Export functions for extern access
  organize_imports = M.organize_imports,
  organize_imports_and_fix = M.organize_imports_and_fix,
}
