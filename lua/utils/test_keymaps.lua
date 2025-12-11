-- Neovim Plugin & Keymap Testing Utility
-- Comprehensive testing framework for headless Neovim plugin and keymap validation

local M = {}

-- Example Use Cases: File-specific testing in headless mode

-- CASE 1: Markdown File (README.md)
-- When opening README.md in headless mode:
--   1. File detection triggers (FileType markdown)
--   2. Markdown LSP/language server attaches
--   3. Treesitter parser loads for markdown
--   4. Checkmate.nvim todo plugin activates (<leader>t keymaps)
--   5. Markdown-specific surround rules load (*, _, ~ for bold/italic/strikethrough)
--   6. Potential plugins: render-markdown, markdown-preview, glow
-- Test command:
--   nvim --headless README.md -c "lua require('utils.test_keymaps').test_markdown_case()" -c "qa"

-- CASE 2: JSON Configuration (biome.json)
-- When opening biome.json in headless mode:
--   1. File detection triggers (FileType json)
--   2. JSON LSP server attaches (likely TypeScript/JSON LSP)
--   3. Treesitter parser loads for JSON
--   4. Schema validation activates
--   5. JSON-specific formatting and validation
-- Test command:
--   nvim --headless biome.json -c "lua require('utils.test_keymaps').test_json_case()" -c "qa"

-- CASE 3: Lua Configuration (init.lua)
-- When opening init.lua in headless mode:
--   1. File detection triggers (FileType lua)
--   2. Lua LSP server attaches (lua-language-server)
--   3. Treesitter parser loads for Lua
--   4. Nvim Lua API completion activates
--   5. Stylua formatting integration
--   6. Lua-specific text objects and navigation
-- Test command:
--   nvim --headless init.lua -c "lua require('utils.test_keymaps').test_lua_case()" -c "qa"

-- CASE 4: HTML Template (index.html)
-- When opening index.html in headless mode:
--   1. File detection triggers (FileType html)
--   2. HTML LSP server attaches (likely vscode-html-languageserver)
--   3. Treesitter parsers load for HTML, CSS, JavaScript
--   4. Emmet expansion keymaps activate
--   5. HTML tag surround functionality
--   6. Auto-closing tags and attribute completion
-- Test command:
--   nvim --headless index.html -c "lua require('utils.test_keymaps').test_html_case()" -c "qa"

-- General Test Command:
--   nvim --headless [filename] -c "lua require('utils.test_keymaps').run_diagnostic()" -c "qa"

-- PHASE 1: Plugin Loading Analysis
-- TODO: Implement plugin_diagnostic()
--   - Check which plugins loaded vs configured
--   - Identify lazy-loading triggers that fired
--   - Report loading times and dependencies
--   - Detect missing or failed plugins

-- PHASE 2: Keymap Conflict Detection
-- TODO: Implement keymap_conflict_analysis()
--   - Compare all active keymaps against builtin Vim commands
--   - Detect overlapping plugin keymaps
--   - Check Graphite layout conflicts (H-A-E-I navigation)
--   - Validate leader key sequences and nesting

-- PHASE 3: LSP Integration Testing
-- TODO: Implement lsp_diagnostic()
--   - Check LSP server attachment for file types
--   - Validate completion sources are active
--   - Test diagnostic providers
--   - Verify formatting and code action availability

-- PHASE 4: Treesitter Validation
-- TODO: Implement treesitter_diagnostic()
--   - Check parser installation and activation
--   - Validate syntax highlighting queries
--   - Test incremental parsing performance
--   - Verify text objects and navigation

-- PHASE 5: File-Type Specific Testing
-- TODO: Implement filetype_diagnostic()
--   - Test file detection accuracy
--   - Validate filetype-specific plugins
--   - Check indentation and formatting rules
--   - Verify syntax and semantic features

function M.run_diagnostic()
  -- Entry point for comprehensive testing
  -- Will orchestrate all diagnostic phases
end

function M.plugin_status()
  -- Quick plugin loading status check
end

function M.keymap_conflicts()
  -- Focused keymap conflict detection
end

function M.test_graphite_layout()
  -- Specific test for custom Graphite keyboard layout
end

-- Keymap Introspection Functions
function M.get_all_keymaps()
  -- Load the keymap utils module
  local keymap_utils = require("keymap-utils")

  -- Clear any previous collected data
  keymap_utils.clear_collected_keymaps()

  -- Local collection for vim.keymap.set interception
  local collected_keymaps = {}

  -- Create mock utility modules that keymaps.lua requires
  local mock_utils = {
    clipboard = {},
    code = {},
    editor = {},
    files = {},
    git = {},
    history = {},
    navigation = {},
    search = {},
    smart_diff = {},
  }

  -- Create mock functions for all utility methods
  local function mock_function()
    return function() end
  end
  for _, module_table in pairs(mock_utils) do
    setmetatable(module_table, {
      __index = function()
        return mock_function
      end,
    })
  end

  -- Store originals
  local original_require = require
  local original_keymap_set = vim.keymap.set

  -- Intercept vim.keymap.set to capture keymaps
  vim.keymap.set = function(mode, key, action, opts)
    local info = debug.getinfo(2, "Sl")

    local function get_clean_filename(source)
      if not source then
        return "unknown"
      end
      local file = source:match("@(.+)") or source
      local filename = file:match("[^/]+$") or file
      if filename:match("%.config/nvim/") then
        filename = filename:gsub(".*%.config/nvim/", "")
      end
      return filename
    end

    table.insert(collected_keymaps, {
      mode = mode,
      key = key,
      action = action,
      opts = opts or {},
      source = {
        file = info.source and get_clean_filename(info.source) or "unknown",
        line = info.currentline or 0,
        short_src = info.short_src or "unknown",
      },
    })
  end

  -- Mock require function to return mock utils
  _G.require = function(module_name)
    if module_name:match("^utils%.") then
      local util_name = module_name:match("^utils%.(.+)")
      return mock_utils[util_name:gsub("%-", "_")] or {}
    end
    return original_require(module_name)
  end

  -- Reload keymaps.lua to collect data
  package.loaded["config.keymaps"] = nil
  local success = pcall(function()
    require("config.keymaps")
  end)

  -- Restore everything
  _G.require = original_require
  vim.keymap.set = original_keymap_set

  if not success then
    return {}
  end

  return collected_keymaps
end

function M.print_keymap_table()
  local keymaps = M.get_all_keymaps()

  -- Group by mode
  local by_mode = {}
  for _, keymap in ipairs(keymaps) do
    if not by_mode[keymap.mode] then
      by_mode[keymap.mode] = {}
    end
    table.insert(by_mode[keymap.mode], keymap)
  end

  return keymaps
end

-- Built-in Vim keymaps that don't show up in vim.keymap but exist
local builtin_keymaps = {
  -- Normal mode built-ins
  n = {
    -- Movement
    ["h"] = { desc = "Left", action = "cursor left" },
    ["j"] = { desc = "Down", action = "cursor down" },
    ["k"] = { desc = "Up", action = "cursor up" },
    ["l"] = { desc = "Right", action = "cursor right" },
    ["w"] = { desc = "Word forward", action = "next word" },
    ["b"] = { desc = "Word backward", action = "previous word" },
    ["e"] = { desc = "End of word", action = "end of word" },
    ["0"] = { desc = "Beginning of line", action = "start of line" },
    ["^"] = { desc = "First non-blank character", action = "first non-blank" },
    ["$"] = { desc = "End of line", action = "end of line" },
    ["gg"] = { desc = "Go to top", action = "first line" },
    ["G"] = { desc = "Go to bottom", action = "last line" },

    -- Text objects and operations
    ["d"] = { desc = "Delete", action = "delete operator" },
    ["c"] = { desc = "Change", action = "change operator" },
    ["y"] = { desc = "Yank", action = "yank operator" },
    ["p"] = { desc = "Paste after", action = "paste after cursor" },
    ["P"] = { desc = "Paste before", action = "paste before cursor" },
    ["u"] = { desc = "Undo", action = "undo last change" },
    ["r"] = { desc = "Replace character", action = "replace single char" },
    ["x"] = { desc = "Delete character", action = "delete char under cursor" },
    ["X"] = { desc = "Delete character before", action = "delete char before cursor" },
    ["s"] = { desc = "Substitute character", action = "substitute char" },
    ["S"] = { desc = "Substitute line", action = "substitute line" },

    -- Modes
    ["i"] = { desc = "Insert mode", action = "enter insert mode" },
    ["I"] = { desc = "Insert at beginning", action = "insert at line start" },
    ["a"] = { desc = "Append", action = "enter insert after cursor" },
    ["A"] = { desc = "Append at end", action = "insert at line end" },
    ["o"] = { desc = "Open line below", action = "new line below" },
    ["O"] = { desc = "Open line above", action = "new line above" },
    ["v"] = { desc = "Visual mode", action = "enter visual mode" },
    ["V"] = { desc = "Visual line mode", action = "enter visual line mode" },

    -- Search and navigation
    ["/"] = { desc = "Search forward", action = "forward search" },
    ["?"] = { desc = "Search backward", action = "backward search" },
    ["n"] = { desc = "Next search", action = "repeat search forward" },
    ["N"] = { desc = "Previous search", action = "repeat search backward" },
    ["*"] = { desc = "Search word forward", action = "search current word forward" },
    ["#"] = { desc = "Search word backward", action = "search current word backward" },

    -- Other common built-ins
    ["."] = { desc = "Repeat last command", action = "repeat last change" },
    ["%"] = { desc = "Jump to matching bracket", action = "jump to matching paren/bracket" },
    ["f"] = { desc = "Find character", action = "find char forward" },
    ["F"] = { desc = "Find character backward", action = "find char backward" },
    ["t"] = { desc = "Till character", action = "till char forward" },
    ["T"] = { desc = "Till character backward", action = "till char backward" },
    [";"] = { desc = "Repeat find", action = "repeat last f/F/t/T" },
    [","] = { desc = "Repeat find reverse", action = "repeat last f/F/t/T reverse" },
  },

  -- Visual mode built-ins
  v = {
    ["d"] = { desc = "Delete selection", action = "delete visual selection" },
    ["c"] = { desc = "Change selection", action = "change visual selection" },
    ["y"] = { desc = "Yank selection", action = "yank visual selection" },
    ["x"] = { desc = "Delete selection", action = "delete visual selection" },
    ["s"] = { desc = "Substitute selection", action = "substitute visual selection" },
    ["o"] = { desc = "Switch cursor to other end", action = "toggle visual selection end" },
  },

  -- Insert mode built-ins
  i = {
    ["<C-h>"] = { desc = "Backspace", action = "delete char before cursor" },
    ["<C-w>"] = { desc = "Delete word", action = "delete word before cursor" },
    ["<C-u>"] = { desc = "Delete line", action = "delete line before cursor" },
  },
}

function M.get_builtin_keymaps()
  return builtin_keymaps
end

function M.analyze_keymap_conflicts()
  local keymaps = M.get_all_keymaps()
  local conflicts = {}
  local key_usage = {}

  -- First, populate with built-in keymaps
  local builtins = M.get_builtin_keymaps()
  for mode, mode_builtins in pairs(builtins) do
    if not key_usage[mode] then
      key_usage[mode] = {}
    end
    for key, builtin_info in pairs(mode_builtins) do
      key_usage[mode][key] = {
        mode = mode,
        key = key,
        action = builtin_info.action,
        opts = { desc = builtin_info.desc },
        source = {
          file = "vim-builtin",
          line = 0,
        },
        builtin = true,
      }
    end
  end

  -- Track key usage per mode
  for _, keymap in ipairs(keymaps) do
    if not key_usage[keymap.mode] then
      key_usage[keymap.mode] = {}
    end

    if key_usage[keymap.mode][keymap.key] then
      local existing = key_usage[keymap.mode][keymap.key]
      local conflict_type = existing.builtin and "builtin-override" or "duplicate"

      table.insert(conflicts, {
        mode = keymap.mode,
        key = keymap.key,
        first = existing,
        duplicate = keymap,
        -- Enhanced conflict info with locations
        first_location = string.format("%s:%d", existing.source.file, existing.source.line),
        duplicate_location = string.format("%s:%d", keymap.source.file, keymap.source.line),
        type = conflict_type,
        builtin_override = existing.builtin or false,
      })
    else
      key_usage[keymap.mode][keymap.key] = keymap
    end
  end

  -- Count conflicts by type
  local duplicates = {}
  local builtin_overrides = {}
  for _, conflict in ipairs(conflicts) do
    if conflict.type == "builtin-override" then
      table.insert(builtin_overrides, conflict)
    else
      table.insert(duplicates, conflict)
    end
  end

  -- Print analysis summary
  print("=== Keymap Conflict Analysis ===")
  print(string.format("Total keymaps analyzed: %d", #keymaps))
  print(string.format("Conflicts found: %d", #conflicts))
  print(string.format("  - Duplicate keymaps: %d", #duplicates))
  print(string.format("  - Built-in overrides: %d", #builtin_overrides))
  print("")

  -- Show duplicate conflicts
  if #duplicates > 0 then
    print("=== DUPLICATE KEYMAP CONFLICTS ===")
    for _, conflict in ipairs(duplicates) do
      print(string.format("⚠️  Mode: %s, Key: %s", conflict.mode, conflict.key))
      print(
        string.format(
          "  First:  %s (%s) at %s",
          type(conflict.first.action) == "string" and conflict.first.action or "[function]",
          conflict.first.opts.desc or "No description",
          conflict.first_location
        )
      )
      print(
        string.format(
          "  Second: %s (%s) at %s",
          type(conflict.duplicate.action) == "string" and conflict.duplicate.action or "[function]",
          conflict.duplicate.opts.desc or "No description",
          conflict.duplicate_location
        )
      )
      print("---")
    end
    print("")
  else
    print("✅ No duplicate keymap conflicts found!")
    print("")
  end

  -- Show built-in overrides
  if #builtin_overrides > 0 then
    print("=== BUILT-IN VIM KEYMAP OVERRIDES ===")
    for _, conflict in ipairs(builtin_overrides) do
      print(string.format("ℹ️  Mode: %s, Key: '%s'", conflict.mode, conflict.key))
      print(
        string.format(
          "  Built-in: %s (%s)",
          conflict.first.action,
          conflict.first.opts.desc or "No description"
        )
      )
      print(
        string.format(
          "  Override: %s (%s) at %s",
          type(conflict.duplicate.action) == "string" and conflict.duplicate.action or "[function]",
          conflict.duplicate.opts.desc or "No description",
          conflict.duplicate_location
        )
      )
      print("---")
    end
  else
    print("ℹ️  No built-in Vim keymaps overridden")
  end

  return conflicts
end

-- File-specific test cases
function M.test_markdown_case()
  print("=== Markdown File Diagnostic ===")
  -- TODO: Test checkmate.nvim keymaps, markdown surround rules, LSP attachment
end

function M.test_json_case()
  print("=== JSON File Diagnostic ===")
  -- TODO: Test JSON LSP, schema validation, formatting integration
end

function M.test_lua_case()
  print("=== Lua File Diagnostic ===")
  -- TODO: Test Lua LSP, nvim API completion, stylua integration
end

function M.test_html_case()
  print("=== HTML File Diagnostic ===")
  -- TODO: Test HTML LSP, treesitter multi-language, emmet keymaps
end

return M
