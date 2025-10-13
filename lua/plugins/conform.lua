local function js_formatter(bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local dirname = vim.fn.fnamemodify(bufname, ":h")

  local prettier_configs = {
    ".prettierrc",
    ".prettierrc.json",
    ".prettierrc.yml",
    ".prettierrc.yaml",
    ".prettierrc.json5",
    ".prettierrc.js",
    ".prettierrc.cjs",
    ".prettierrc.mjs",
    ".prettierrc.toml",
    "prettier.config.js",
    "prettier.config.cjs",
    "prettier.config.mjs",
  }

  local has_prettier = vim.fs.find(prettier_configs, {
    path = dirname,
    upward = true,
    limit = 1,
  })[1] ~= nil

  if has_prettier then
    return { "prettier" }
  else
    return { "biome" }
  end
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
  else
    -- Fallback: Use TypeScript tools for both actions
    vim.cmd("TSToolsOrganizeImports")
    vim.schedule(function()
      vim.cmd("TSToolsRemoveUnusedImports")
    end)
  end
end

M.organize_imports_and_fix = function()
  -- First organize imports
  M.organize_imports()

  -- Then fix all diagnostics using TypeScript tools
  vim.schedule(function()
    vim.cmd("TSToolsFixAll")
  end)
end

return {
  "stevearc/conform.nvim",
  dependencies = { "mason-org/mason.nvim" }, -- Ensure Mason loads first
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      dts = { "zmk_keymap_formatter" }, -- Custom ZMK keymap formatter
      typescript = js_formatter,
      javascript = js_formatter,
      typescriptreact = js_formatter,
      javascriptreact = js_formatter,
      json = js_formatter,
      html = js_formatter,
      htmlangular = js_formatter,
      vue = js_formatter,
      css = js_formatter,
      scss = js_formatter,
    },
    formatters = {
      -- Custom ZMK keymap formatter
      zmk_keymap_formatter = {
        command = function()
          -- Look for format_keymap.py in the current project root
          local root = vim.fs.find({ "format_keymap.py" }, { upward = true })[1]
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
