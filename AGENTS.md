# AGENTS.md - Neovim Configuration Manager

## Role & Workflow
You are a Neovim configuration manager. Tasks come from GitHub CLI (`gh issue list`, `gh pr list`). Main focus: keymaps and plugins. **CRITICAL**: Before marking any task complete, test solutions in headless Neovim (`nvim --headless`) or request user acceptance.

**MANDATORY**: Before making ANY implementation changes, you MUST:
1. Test the existing state/functionality 
2. Ask for explicit permission to proceed with changes
3. Only make changes when explicitly authorized

## Build/Lint/Test Commands
- **Lua formatting**: `stylua .` (2 spaces, 120 column width)
- **JS/TS formatting**: `biome format --write .` or `prettier --write .`
- **Headless testing**: `nvim --headless -u NONE -c 'source test.lua'`
- **Keymap conflict check**: 
  - `echo 'keymap_table' | lua utils/test_keymaps.lua` (direct table input)
  - `echo '{ { mode = "n", lhs = "cs", rhs = "test", desc = "Test" } }' | lua utils/test_keymaps.lua` (example)
  - If lua not found: `echo 'keymap_table' | nvim --headless -c 'luafile utils/test_keymaps.lua' -c 'qa'`
- **Plugin sync**: `nvim +Lazy sync +qa` or `<leader>rl` keymap
- **Config reload**: `:source $MYVIMRC` or `<leader>rr` keymap
- **Health check**: `:checkhealth` for plugin verification

## Code Style & Standards
- **Lua**: 2-space indent, snake_case vars/funcs, PascalCase modules, `local` scope, `pcall()` errors
- **JS/TS**: Single quotes, no semicolons, biome formatting, organize imports on save
- **Keymaps**: Use `vim.keymap.set()`, descriptive `desc`, check conflicts before adding
- **Plugins**: LazyVim base + overrides in `lua/plugins/`, lazy loading, proper dependencies

## Utils Tooling (`/utils` & `/lua/utils`)
- **test_keymaps.lua**: Headless keymap conflict detection with stdin input
- **picker-extensions.lua**: Snacks.nvim picker actions, context menus, file operations
- **save-patterns.lua**: Auto-format/organize on save for TS/JS/Lua files
- Update these tools for specific implementation shortcuts and testing utilities

## Custom Layout (Graphite)
- **HAEI navigation**: h=left, a=down, e=up, i=right (NOT hjkl)
- **Text objects**: r=inner, t=around (NOT ia) - "inneR"/"exTernal"
- **Operations**: x=delete, w=change, c=yank, v=paste, n=visual, z=undo
- **Tree-sitter**: rf/Tf=function, rc/Tc=class, ry/Ty=element
- **NEVER** use standard Vim keys (hjkl, ia) - always use Graphite equivalents