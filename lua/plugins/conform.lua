local function js_formatter(bufnr)
  -- Get the directory of the current buffer
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local dirname = vim.fn.fnamemodify(bufname, ":h")

  -- Use conform's built-in config definitions
  local util = require("conform.util")

  -- Simple check using vim.fs.find (more reliable)
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

  local has_biome = vim.fs.find({ "biome.json", "biome.jsonc" }, {
    path = dirname,
    upward = true,
    limit = 1,
  })[1] ~= nil

  -- Return formatter based on what's available
  -- Prefer prettier if both exist
  if has_prettier then
    return { "prettier" }
  elseif has_biome then
    return { "biome" }
  else
    -- Default to biome if no configs found (will use nvim fallback)
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
      typescript = function(bufnr)
        return js_formatter(bufnr)
      end,
      javascript = function(bufnr)
        return js_formatter(bufnr)
      end,
      typescriptreact = function(bufnr)
        return js_formatter(bufnr)
      end,
      javascriptreact = function(bufnr)
        return js_formatter(bufnr)
      end,
      json = function(bufnr)
        return js_formatter(bufnr)
      end,
      html = { "prettier" },
      htmlangular = { "prettier" },
      vue = { "biome" },
      css = { "biome" },
      scss = { "biome" },
    },
    formatters = {
      -- Only override when we want different behavior
      biome = {
        inherit = true, -- Keep all default settings
        args = function(self, ctx)
          -- Let conform find config normally
          local util = require("conform.util")
          local config_path = util.root_file({ "biome.json", "biome.jsonc" })(self, ctx)

          if config_path then
            -- Use default behavior
            return { "format", "--stdin-file-path", "$FILENAME" }
          else
            -- Fallback to nvim config
            return {
              "format",
              "--config-path",
              vim.fn.stdpath("config") .. "/biome.json",
              "--stdin-file-path",
              "$FILENAME",
            }
          end
        end,
      },
      prettier = {
        inherit = true,
        args = function(self, ctx)
          -- Check using conform's own method
          local prettierd = require("conform.formatters.prettierd")
          local has_config = prettierd.cwd(self, ctx)

          if has_config then
            return { "--stdin-filepath", "$FILENAME" }
          else
            return {
              "--config",
              vim.fn.stdpath("config") .. "/.prettierrc",
              "--stdin-filepath",
              "$FILENAME",
            }
          end
        end,
      },
      -- Stylua already handles --search-parent-directories, so we just add fallback
      stylua = {
        inherit = true,
        prepend_args = function(self, ctx)
          local util = require("conform.util")
          local has_config = util.root_file({ ".stylua.toml", "stylua.toml" })(self, ctx)

          if not has_config then
            -- Add config path before other args
            return { "--config-path", vim.fn.stdpath("config") .. "/stylua.toml" }
          end
          return {}
        end,
      },
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
