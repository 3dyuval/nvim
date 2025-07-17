# Keymap Conflict Resolution Guide

This document provides comprehensive strategies for resolving keymap conflicts in the Neovim configuration, with special focus on Graphite layout compliance and which-key integration.

## Quick Reference

### Health Check Commands
```bash
# Run comprehensive keymap health check
:checkhealth config

# Check which-key specific conflicts  
:checkhealth which-key

# Test specific keymaps for conflicts
echo 'keymaps_table' | lua lua/config/test-utils/test_keymaps.lua

# Run automated keymap checks
make check-keymaps
```

## Conflict Categories

### 1. Overlapping Key Patterns

#### Problem: Base vs Extended Keys
- `<x>` overlaps with `<xs>` (Delete vs Delete surrounding)
- `<w>` overlaps with `<ws>` (Change vs Change surrounding)
- `<g>` overlaps with `<g.*>` (LSP and motion conflicts)

#### Solutions:
```lua
-- BAD: Overlapping patterns
vim.keymap.set("n", "x", "delete_action")
vim.keymap.set("n", "xs", "delete_surrounding")

-- GOOD: Use which-key groups
local wk = require("which-key")
wk.register({
  x = {
    name = "Delete Operations",
    x = { "delete_action", "Delete" },
    s = { "delete_surrounding", "Delete Surrounding" },
    w = { "delete_word", "Delete Word" },
  }
}, { prefix = "" })

-- ALTERNATIVE: Use different key combinations
vim.keymap.set("n", "x", "delete_action")
vim.keymap.set("n", "<leader>xs", "delete_surrounding")
```

### 2. Graphite Layout Violations

#### Problem: Standard Vim Keys in Graphite Layout
The Graphite layout uses different conventions:
- **Navigation**: HAEI (h=left, a=down, e=up, i=right) instead of hjkl
- **Text Objects**: RT (r=inner, t=around) instead of ia
- **Operations**: XWCVNZ instead of standard Vim operations

#### Solutions:
```lua
-- BAD: Standard Vim navigation
vim.keymap.set("n", "j", "move_down")
vim.keymap.set("n", "k", "move_up")

-- GOOD: Graphite navigation
vim.keymap.set("n", "a", "move_down", { desc = "Move down (Graphite)" })
vim.keymap.set("n", "e", "move_up", { desc = "Move up (Graphite)" })
vim.keymap.set("n", "h", "move_left", { desc = "Move left (Graphite)" })
vim.keymap.set("n", "i", "move_right", { desc = "Move right (Graphite)" })

-- BAD: Standard text objects
vim.keymap.set("o", "i", "inner_text_object")
vim.keymap.set("o", "a", "around_text_object")

-- GOOD: Graphite text objects
vim.keymap.set("o", "r", "inner_text_object", { desc = "Inner (Graphite)" })
vim.keymap.set("o", "t", "around_text_object", { desc = "Around (Graphite)" })
```

### 3. Critical Built-in Overrides

#### Problem: Overriding Essential Vim Functionality
```lua
-- DANGEROUS: These override critical Vim commands
vim.keymap.set("n", "<C-c>", "custom_action") -- Breaks cancel/interrupt
vim.keymap.set("n", "<C-w>", "custom_window") -- Breaks window commands
vim.keymap.set("i", "<C-h>", "custom_help")   -- Breaks backspace
```

#### Solutions:
```lua
-- SAFE: Use leader keys or different combinations
vim.keymap.set("n", "<leader>cc", "custom_action", { desc = "Custom action" })
vim.keymap.set("n", "<leader>ww", "custom_window", { desc = "Custom window" })
vim.keymap.set("i", "<M-h>", "custom_help", { desc = "Custom help" })

-- SAFE: Use function keys
vim.keymap.set("n", "<F2>", "custom_action", { desc = "Custom action" })

-- SAFE: Use unused key combinations
vim.keymap.set("n", "gz", "custom_action", { desc = "Custom action" })
```

### 4. Leader Key Conflicts

#### Problem: Overcrowded Leader Namespace
```lua
-- PROBLEMATIC: Too many similar leader keys
vim.keymap.set("n", "<leader>q", "quit")
vim.keymap.set("n", "<leader>qa", "quit_all")
vim.keymap.set("n", "<leader>qf", "quit_force")
vim.keymap.set("n", "<leader>qq", "quit_quick")
```

#### Solutions:
```lua
-- ORGANIZED: Use which-key groups
local wk = require("which-key")
wk.register({
  q = {
    name = "Quit Operations",
    q = { ":q<CR>", "Quit" },
    a = { ":qa<CR>", "Quit All" },
    f = { ":q!<CR>", "Force Quit" },
    w = { ":wq<CR>", "Write & Quit" },
  }
}, { prefix = "<leader>" })

-- HIERARCHICAL: Use nested groups
wk.register({
  g = {
    name = "Git Operations",
    b = { "Git Branches", ":Telescope git_branches<CR>" },
    c = { "Git Commits", ":Telescope git_commits<CR>" },
    s = { "Git Status", ":Neogit<CR>" },
    h = {
      name = "Git History",
      f = { "File History", ":DiffviewFileHistory<CR>" },
      l = { "Log", ":Telescope git_log<CR>" },
    }
  }
}, { prefix = "<leader>" })
```

### 5. Mode-Specific Conflicts

#### Problem: Same Keys in Different Modes
```lua
-- CONFLICTING: Same key behavior across modes
vim.keymap.set("n", "r", "replace_char")
vim.keymap.set("v", "r", "replace_selection") 
vim.keymap.set("o", "r", "inner_text_object") -- Graphite: inner
```

#### Solutions:
```lua
-- CONSISTENT: Maintain mode-appropriate behavior
vim.keymap.set("n", "r", "replace_char", { desc = "Replace character" })
vim.keymap.set("v", "r", "replace_selection", { desc = "Replace selection" })
vim.keymap.set("o", "r", "inner_text_object", { desc = "Inner text object (Graphite)" })

-- DOCUMENTED: Clear descriptions for each mode
local function set_mode_keymap(modes, key, action, desc)
  for _, mode in ipairs(modes) do
    vim.keymap.set(mode, key, action, { desc = desc .. " (" .. mode .. " mode)" })
  end
end

set_mode_keymap({"n", "v"}, "<leader>y", '"+y', "Copy to clipboard")
```

## Resolution Strategies

### 1. Which-Key Integration
```lua
-- Use which-key for conflict detection and organization
local wk = require("which-key")

-- Register all keymaps through which-key
wk.register({
  ["<leader>"] = {
    f = {
      name = "File Operations",
      f = { ":Telescope find_files<CR>", "Find Files" },
      r = { ":Telescope oldfiles<CR>", "Recent Files" },
      g = { ":Telescope live_grep<CR>", "Live Grep" },
    },
    g = {
      name = "Git Operations", 
      b = { ":Telescope git_branches<CR>", "Branches" },
      c = { ":Telescope git_commits<CR>", "Commits" },
      s = { ":Neogit<CR>", "Status" },
    }
  }
})

-- Check for conflicts
vim.cmd("checkhealth which-key")
```

### 2. Systematic Key Assignment
```lua
-- Follow a systematic approach to key assignment
local key_groups = {
  -- File operations: <leader>f*
  files = "<leader>f",
  -- Git operations: <leader>g*  
  git = "<leader>g",
  -- Buffer operations: <leader>b*
  buffers = "<leader>b",
  -- Window operations: <leader>w*
  windows = "<leader>w",
  -- Search operations: <leader>s*
  search = "<leader>s",
  -- LSP operations: <leader>l*
  lsp = "<leader>l",
}

-- Use consistent prefixes
vim.keymap.set("n", key_groups.files .. "f", ":Telescope find_files<CR>")
vim.keymap.set("n", key_groups.git .. "b", ":Telescope git_branches<CR>")
vim.keymap.set("n", key_groups.buffers .. "d", ":bdelete<CR>")
```

### 3. Conflict Prevention
```lua
-- Create a keymap registration function with conflict checking
local function safe_keymap(mode, lhs, rhs, opts)
  opts = opts or {}
  
  -- Check for existing mapping
  local existing = vim.fn.maparg(lhs, mode, false, true)
  if existing and existing.lhs ~= "" then
    vim.notify(
      string.format("Warning: Overriding existing mapping %s in mode %s", lhs, mode),
      vim.log.levels.WARN
    )
  end
  
  -- Set the keymap
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- Use safe_keymap instead of vim.keymap.set
safe_keymap("n", "<leader>ff", ":Telescope find_files<CR>", { desc = "Find Files" })
```

## Testing and Validation

### 1. Automated Testing
```bash
# Run all keymap tests
make check-keymaps

# Test specific keymap changes
echo '{
  { mode = "n", lhs = "<leader>ff", rhs = ":Telescope find_files<CR>", desc = "Find Files" }
}' | lua lua/config/test-utils/test_keymaps.lua

# Check health after changes
nvim --headless -c 'checkhealth config' -c 'qa'
```

### 2. Manual Validation
```vim
" Check current keymaps
:map
:imap  
:vmap

" Find specific mappings
:map <leader>
:map <C-

" Check which-key conflicts
:checkhealth which-key

" Test keymap functionality
:verbose map <key>
```

### 3. Documentation Requirements
```lua
-- Always include descriptive documentation
vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>", {
  desc = "Find Files",           -- Required: Clear description
  silent = true,                 -- Optional: Suppress command echo
  noremap = true,               -- Optional: Non-recursive mapping
})

-- Use which-key for complex mappings
local wk = require("which-key")
wk.register({
  f = {
    name = "📁 File Operations",  -- Use emojis for visual grouping
    f = { ":Telescope find_files<CR>", "🔍 Find Files" },
    r = { ":Telescope oldfiles<CR>", "📚 Recent Files" },
    g = { ":Telescope live_grep<CR>", "🔎 Live Grep" },
  }
}, { prefix = "<leader>" })
```

## Best Practices

### 1. Key Assignment Hierarchy
1. **Critical Vim commands** - Never override
2. **Graphite layout** - Follow HAEI/RT conventions  
3. **Leader keys** - Organize with which-key groups
4. **Function keys** - Use for less common operations
5. **Alt/Meta keys** - Alternative namespace
6. **Unused combinations** - gz, gZ, etc.

### 2. Conflict Resolution Priority
1. **Fix critical overrides** - Restore essential Vim functionality
2. **Resolve explicit conflicts** - Same key, different actions
3. **Address overlapping patterns** - Base vs extended keys
4. **Optimize leader namespace** - Group related operations
5. **Document all mappings** - Clear descriptions and organization

### 3. Maintenance Workflow
1. **Before adding keymaps** - Test with `test_keymaps.lua`
2. **After changes** - Run `:checkhealth config`
3. **Regular audits** - Review with `:checkhealth which-key`
4. **Document changes** - Update this guide and README.md
5. **Test functionality** - Ensure all mappings work as expected

## Common Patterns

### Safe Key Combinations
```lua
-- These are generally safe to use:
local safe_keys = {
  leader = "<leader>*",           -- Leader namespace
  function = "<F1>-<F12>",        -- Function keys
  alt = "<M-*>",                  -- Alt/Meta combinations
  unused_g = "gz, gZ, g<C-*>",    -- Unused g combinations
  unused_z = "zx, zX, z<C-*>",    -- Unused z combinations
  space = "<Space>*",             -- Space as leader
}
```

### Dangerous Overrides
```lua
-- NEVER override these:
local dangerous_keys = {
  "<C-c>",    -- Cancel/interrupt
  "<C-z>",    -- Suspend
  "<C-w>",    -- Window commands
  "<C-r>",    -- Redo
  "<C-o>",    -- Jump back
  "<C-i>",    -- Jump forward
  "<C-h>",    -- Backspace (insert mode)
  "<C-u>",    -- Delete line (insert mode)
  "<C-n>",    -- Completion next
  "<C-p>",    -- Completion previous
}
```

This guide should be referenced whenever adding new keymaps or resolving conflicts detected by the health check system.