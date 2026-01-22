# Testing

Tests location: `/lua/config/tests/`

## Running Tests

```bash
make test      # Run all tests
make check     # Code quality check
```

## Test Files

| File | Purpose |
|------|---------|
| `keymaps.test.lua` | Entry point, Graphite layout tests (insert, paste, navigation) |
| `test_keymaps_conflicts.lua` | Standalone conflict checker against built-in Vim commands |
| `fences/test.lua` | Fenced code block text objects (`r\``, `t\``) |
| `tags/test.lua` | HTML tag selection (`it`, `at`, self-closing) |

## Test Patterns

Tests use Plenary with helpers:
```lua
local function set_curpos(pos)
  vim.api.nvim_win_set_cursor(0, { pos[1], pos[2] - 1 })
end

local function set_lines(lines)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end

local function check_lines(lines)
  assert.are.same(lines, vim.api.nvim_buf_get_lines(0, 0, -1, false))
end
```

## Keymap Conflict Testing

Standalone script (no nvim required for initial parse):
```bash
lua lua/config/tests/test_keymaps_conflicts.lua
```

Checks against built-in commands with severity levels:
- `ERROR` - Explicit keymap conflicts
- `WARNING` - Important built-in overrides
- `INFO` - Less critical overrides

## Kitty Debug Script

Remote control Neovim via Kitty for live testing.

Location: `scripts/kitty-nvim-debug.lua`

```bash
# List nvim instances
lua scripts/kitty-nvim-debug.lua list

# Send keystrokes (test surround)
lua scripts/kitty-nvim-debug.lua send "ysiwi"

# Send ex command
lua scripts/kitty-nvim-debug.lua cmd "KMUInspect"
lua scripts/kitty-nvim-debug.lua cmd "lua print(vim.inspect(vim.keymap.get('n')))"

# Reload config
lua scripts/kitty-nvim-debug.lua reload

# Launch nvim with test file
lua scripts/kitty-nvim-debug.lua launch /tmp/test.lua
```

Requires Kitty with `allow_remote_control yes`.
