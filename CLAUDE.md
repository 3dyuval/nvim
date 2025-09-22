## Neovim Graphite Custom Setup

## Project Goals & Development Patterns

### Architecture Philosophy
- **Modular utils pattern**: Each utility lives in `/lua/utils/` as a focused module
- **Consistent keymap structure**: Using `lil.map` with descriptive functions
- **Separation of concerns**: Utils handle logic, keymaps just map to utils functions
- **Auto-formatting enforcement**: Always run `make format` before commits

### Code Formatting & Quality Commands
```bash
# ALWAYS run these before making changes:
make format    # Auto-format all code (stylua for Lua, prettier for JS/TS)
make check     # Check code quality
make test      # Run test suite for keymap conflicts
```

### Keymap Pattern Structure
All keymaps follow this pattern:
1. Import relevant utils at top: `local module = require("utils.module")`
2. Use `lil.map` with descriptive functions
3. Group related keymaps under leader sequences
4. Always provide `desc` for discoverability

#### Consistent Action Keys (Snacks Explorer Pattern)
My keymaps follow a consistent pattern inspired by snacks explorer and aligned with Graphite layout:
- **r** = create/add new (consistent with "r" for "inneR"/insert mode)
- **n** = toggle/change state (cycle between options)
- **a** = archive/accept/apply action
- **x** = delete/remove
- **R** = rename/refactor (uppercase for modify existing)
- **p** = path/print operations (copy path, show info)
- **v** = view/visual operations (select value, diff view)

This pattern is used consistently across:
- File explorer: `r` creates files, `R` renames
- Todo/Checkmate: `<leader>tr` creates todos, `<leader>tn` toggles state
- Git operations: Following similar patterns for consistency

#### Nested Command Structure
Complex commands use nested mappings for organization:
```lua
-- Example: Todo commands with metadata nesting
["<leader>t"] = {
  r = desc("Todo: Create new", cmd("Checkmate create")),
  n = desc("Todo: Toggle state", cmd("Checkmate toggle")),
  t = {  -- Nested metadata operations
    r = {  -- Create pattern
      s = desc("Add @started", ...),
      d = desc("Add @done", ...),
    },
    n = {  -- Toggle pattern
      s = desc("Toggle @started", ...),
    },
  },
}
```

Example pattern from keymaps.lua:
```lua
lil.map({
  [func] = func_map,
  ["<leader>g"] = {
    o = desc("Get hunk (smart)", smart_diff.smart_diffget),
    p = desc("Put hunk (smart)", smart_diff.smart_diffput),
  },
})
```

### Utils Module Pattern
Each util module exports focused functions:
- Single responsibility per function
- Clear, descriptive names (e.g., `smart_diffget`, `copy_file_path`)
- No direct keymaps in utils - separation of concerns
- Utils should be reusable and testable

## Context
I'm using a Graphite keyboard layout with custom neovim keybindings that remap standard QWERTY navigation to HAEI (H-left, A-down, E-up, I-right). My configuration replaces Vim's standard `hjkl` navigation and `ia` text objects with a more ergonomic and logical system.

## My Custom Layout Overview

### Core Navigation (HAEI)
- **H** = left (replaces `h`)
- **A** = down (replaces `j`) 
- **E** = up (replaces `k`)
- **I** = right (replaces `l`)

### Text Objects Revolution
- **R** = inner (replaces `i`) - "r" for "inneR"
- **T** = around (replaces `a`) - "t" for "around/exTernal"

### Other Key Remappings
- **X** = delete (replaces `d`)
- **W** = change (replaces `c`)
- **C** = yank/copy (replaces `y`)
- **V** = paste (replaces `p`)
- **N** = visual mode (replaces `v`)
- **Z** = undo (replaces `u`)

