# Advanced Keymap Management with lil.nvim

## Why We Built This

After [our previous exploration](https://www.reddit.com/r/neovim/comments/1n1a8qc/i_finally_discovered_how_to_organize_key_maps/) of keymap organization, we discovered something important: **most keymap solutions focus on syntax, but ignore the real problems** - conflict detection, maintainability at scale, and introspection.

We built upon lil.nvim to create a **two-form approach** that solves real problems:

## Form 1: Drop-in Replacement (with Superpowers)

Replace your `vim.keymap.set` with our enhanced mapper that provides **automatic conflict detection** and **flat table output**:

```lua
-- Old way: scattered and conflict-prone
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { desc = 'Live grep' })
vim.keymap.set('n', '<leader>gc', '<cmd>Git commit<cr>', { desc = 'Git commit' })
-- ... 200+ more scattered across files

-- New way: enhanced mapper with introspection
local keymap = require('keymap-introspect')

keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { desc = 'Find files' })
keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { desc = 'Live grep' })
keymap.set('n', '<leader>gc', '<cmd>Git commit<cr>', { desc = 'Git commit' })

-- Get comprehensive analysis
local analysis = keymap.analyze()
print(string.format("Total keymaps: %d", analysis.count))
print(string.format("Conflicts found: %d", #analysis.conflicts))
print(string.format("Coverage: Normal=%d, Visual=%d, Insert=%d",
  analysis.by_mode.n, analysis.by_mode.v, analysis.by_mode.i))
```

**Output Example:**
```
=== Keymap Analysis ===
Total keymaps: 239
Conflicts found: 0
Coverage: Normal=121, Visual=18, Insert=12

=== Top-level Leader Mappings ===
<leader>f (12 keymaps) - File operations
<leader>g (8 keymaps)  - Git operations
<leader>c (15 keymaps) - Code operations
<leader>t (20 keymaps) - Todo operations

✅ No conflicts detected
✅ All descriptions present
⚠️  3 keymaps missing in mode 'x'
```

## Form 2: Elegant Composition (for Complex Setups)

For power users managing 200+ keymaps with custom layouts (like Graphite keyboard), use **composable architecture**:

```lua
local lil = require('keymap-introspect').lil

-- Nested structure with inheritance and conflict prevention
lil.map({
  -- File operations cluster
  ["<leader>f"] = {
    [lil.opts] = { silent = true }, -- Cascades to all children
    f = desc("Find files (snacks + fff)", files.find_files),
    s = desc("Save file", files.save_file),
    S = desc("Save and stage file", files.save_and_stage),
  },

  -- Git operations with mode inheritance
  ["<leader>g"] = {
    [lil.mode] = { "n", "v" }, -- Both normal and visual modes
    c = desc("Git commit", cmd("Neogit commit")),
    d = desc("Diff view open", cmd("DiffviewOpen")),
    h = desc("Current file history", ":DiffviewFileHistory %"),

    -- Nested conflict resolution
    conflict = {
      P = desc("Resolve file: ours", smart_diff.smart_resolve_ours),
      O = desc("Resolve file: theirs", smart_diff.smart_resolve_theirs),
      U = desc("Resolve file: union", smart_diff.smart_resolve_union),
    }
  },

  -- Custom Graphite layout navigation
  g = {
    i = desc("Go to top", "gg"),           -- Graphite: i = up
    h = desc("Go to bottom", "G"),          -- Graphite: h = down
    o = desc("Get hunk (smart)", smart_diff.smart_diffget),
    p = desc("Put hunk (smart)", smart_diff.smart_diffput),
  }
})
```

## The Real Benefits We Discovered

### 1. **Conflict Detection That Actually Works**
```lua
-- Automatic detection of:
-- - Duplicate keymaps in same mode
-- - Leader sequence conflicts (<leader>gc vs <leader>g)
-- - Plugin conflicts (your maps vs LSP defaults)
-- - Mode-specific overlaps
```

### 2. **Documentation Generation**
```lua
-- Auto-generate keymap documentation
keymap.generate_docs("KEYMAPS.md")

-- Output: Organized by category, with descriptions and examples
```

### 3. **File-Specific Testing**
```lua
-- Test keymap behavior by file type
keymap.test_file_context("biome.json")  -- Tests JSON-specific keymaps
keymap.test_file_context("README.md")   -- Tests markdown + checkmate.nvim
keymap.test_file_context("init.lua")    -- Tests Lua LSP integration
```

### 4. **Real-World Scale Management**
Our test configuration successfully manages **239 keymaps** across:
- Normal mode: 121 keymaps
- Visual/select modes: 18 keymaps
- Insert mode: 12 keymaps
- Operator-pending: 7 keymaps
- Custom text objects: 45+ mappings

## Architecture Insights

What makes this approach different from standard solutions:

1. **Separation of Concerns**: Keymap logic ≠ keymap setting
2. **Introspection by Design**: Built-in analysis and conflict detection
3. **Composable Structure**: Inheritance, cascading, and nesting
4. **Custom Layout Support**: Works with non-QWERTY layouts (Graphite, Dvorak, etc.)

## Migration Path

### Step 1: Start with Form 1 (Drop-in)
```lua
-- Replace vim.keymap.set with keymap.set
-- Get immediate conflict detection and analysis
```

### Step 2: Evolve to Form 2 (Composed)
```lua
-- Group related keymaps into nested structures
-- Add mode inheritance and option cascading
-- Implement custom layout mappings
```

### Step 3: Advanced Features
```lua
-- File-specific keymap testing
-- Auto-documentation generation
-- Plugin conflict resolution
```

## Repository

[keymap-introspect.nvim](https://github.com/user/keymap-introspect) - *Coming soon*

Built on the solid foundation of [lil.nvim](https://github.com/va9iff/lil) with enhanced introspection capabilities.

---

*This evolved from our earlier work on [keymap organization](https://www.reddit.com/r/neovim/comments/1n1a8qc/i_finally_discovered_how_to_organize_key_maps/), addressing the feedback about complexity while proving the architectural benefits through real-world usage.*