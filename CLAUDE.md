## Neovim Graphite Custom Setup

## Project Goals & Development Patterns

### Architecture Philosophy
- **Modular utils pattern**: Each utility lives in `/lua/utils/` as a focused module
- **Consistent keymap structure**: Using `keymap-utils` with simple declarative tables
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
All keymaps use `keymap-utils` with simple table syntax:

```lua
local kmu = require("keymap-utils")
local map = kmu.create_smart_map()

map({
  -- Simple: action at [1], desc as named key
  h = { "h", desc = "Left" },

  -- Function as action
  ["<leader>f"] = { some_function, desc = "Do something" },

  -- With vim keymap options
  gf = { notes.smart_follow_link, desc = "Follow link", expr = true },

  -- Nested groups (infinite nesting supported)
  ["<leader>g"] = {
    group = "Git",  -- which-key group name
    n = { cmd("Neogit"), desc = "Open Neogit" },
    d = {
      group = "Diff",
      o = { cmd("DiffviewOpen"), desc = "Open" },
    },
  },
})
```

Key points:
1. Action at `[1]` or use `rhs = action` (both work)
2. `desc` for which-key description
3. `group` for which-key group names
4. Supports `expr`, `silent`, `noremap`, `buffer`, etc.

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
