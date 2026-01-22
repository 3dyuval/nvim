---
name: nvim-config
description: Neovim configuration with Graphite/HAEI keyboard layout, keymap-utils declarative syntax, and modular utils architecture. Use when editing keymaps, adding plugins, configuring LSP, or modifying any Lua config files in this repo.
---

# Neovim Graphite Configuration

## Graphite/HAEI Keyboard Layout

This config uses a custom keyboard layout. **Never use standard hjkl or ia in keymaps.**

### Core Navigation (HAEI)
- `H` = left (replaces `h`)
- `A` = down (replaces `j`)
- `E` = up (replaces `k`)
- `I` = right (replaces `l`)

### Text Objects
- `R` = inner (replaces `i`) - "inneR"
- `T` = around (replaces `a`) - "exTernal"

### Operations
- `X` = delete (replaces `d`)
- `W` = change (replaces `c`)
- `C` = yank/copy (replaces `y`)
- `V` = paste (replaces `p`)
- `N` = visual mode (replaces `v`)
- `Z` = undo (replaces `u`)

## Code Quality Commands

**ALWAYS run before commits:**
```bash
make format    # stylua for Lua, prettier for JS/TS
make check     # Code quality check
make test      # Keymap conflict tests
```

## Testing

See [references/testing.md](references/testing.md) for test patterns and debugging.

Quick reference:
- `make test` - Run Plenary tests
- `scripts/kitty-nvim-debug.lua` - Remote control nvim via Kitty

## Keymap Pattern (keymap-utils)

All keymaps use `keymap-utils` with declarative tables:

```lua
local kmu = require("keymap-utils")
local map = kmu.create_smart_map()

map({
  -- Simple mapping
  h = { "h", desc = "Left" },

  -- Function action
  ["<leader>f"] = { some_function, desc = "Do something" },

  -- Vim command (becomes <Cmd>...<CR>)
  ["<leader>w"] = { cmd = "w", desc = "Save" },

  -- Command prefill without execution (becomes :...)
  ["<leader>o"] = { cmd = "Octo ", exec = false, desc = "Octo command" },

  -- With options
  gf = { notes.smart_follow_link, desc = "Follow link", expr = true },

  -- Nested groups (infinite nesting)
  ["<leader>g"] = {
    group = "Git",
    n = { cmd = "Neogit", desc = "Open Neogit" },
    d = {
      group = "Diff",
      o = { cmd = "DiffviewOpen", desc = "Open" },
    },
  },
})
```

**Key syntax:**
- `[1]` or `rhs` = action (string/function)
- `cmd = "Command"` = vim command
- `cmd = "...", exec = false` = prefill only
- `desc` = which-key description
- `group` = which-key group name
- Supports: `expr`, `silent`, `noremap`, `buffer`, `disabled`

## Architecture

### Directory Structure
```
lua/
├── config/          # Core config (autocmds, keymaps, options)
├── plugins/         # Plugin specs (lazy.nvim)
└── utils/           # Utility modules
```

### Utils Pattern
Each util in `/lua/utils/` is a focused module:
- Single responsibility per function
- Clear names (e.g., `smart_diffget`, `copy_file_path`)
- No keymaps in utils - separation of concerns
- Utils should be reusable and testable

### Plugin Pattern
```lua
return {
  {
    "author/plugin",
    opts = { ... },
    keys = {
      -- Use keymap-utils or standard format
    },
  },
}
```

## LSP Configuration

LSP servers configured in `/lua/plugins/lsp-config.lua`:

- **vtsls** - Primary TypeScript/Vue server
- **elixirls** - Elixir
- **tsgo** - Fast TS type-checking (parallel to vtsls)
- **vue_ls** - Vue (disabled in favor of vtsls hybrid mode)

Vue uses vtsls with `@vue/typescript-plugin` in hybrid mode.

## Snacks Picker Extensions

Custom picker actions in `/lua/utils/picker-extensions.lua`:
- Context detection (explorer, git_status, buffers, files)
- Copy actions with multiple format options
- Layout toggles (tree/flat, hidden files)
- Dependency injection pattern: `function(picker) ... end`

## Git Workflow

- **Neogit** - Main git interface (`<leader>gg`)
- **AI Commit** - Generate commit messages with AI (`<leader>gc` popup)
- **Diffview** - Diff viewer (`<leader>gd`)
- **Gitsigns** - Hunk operations (`<leader>gh*`)

## Surround

nvim-surround with Graphite translations. See [references/surround.md](references/surround.md) for full keymap reference.

Quick reference:
- `ys{motion}{char}` - Surround (e.g., `ysiw(` → `(word)`)
- `xs{char}` - Delete surround (Graphite)
- `ws{old}{new}` - Change surround (Graphite)
- `s{char}` - Visual surround (Graphite)
- `i` char prompts for custom delimiter pair

## File References

- Keymaps: `/lua/config/keymaps.lua`
- Autocmds: `/lua/config/autocmds.lua`
- LSP: `/lua/plugins/lsp-config.lua`
- Picker: `/lua/utils/picker-extensions.lua`
- AI Commit: `/lua/utils/ai_commit.lua`
- Surround: `/lua/plugins/surround.lua`
- Tests: `/lua/config/tests/`
