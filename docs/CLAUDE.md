# AGENTS.md - Neovim Configuration Manager

## Role & Workflow

You are a Neovim configuration manager. Tasks come from GitHub CLI (`gh issue list`, `gh pr list`). Main focus: keymaps and plugins. **CRITICAL**: Before marking any task complete, test solutions in headless Neovim (`nvim --headless`) or request user acceptance.
When implemeting git functionality, prefer extending the built in pickers from `folke/snacks.nvim` sources such

```lua
{
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        git_branches = {
 ...
```

When implementing custom Github functionality use `pwntester/octo.nvim`.

**MANDATORY**: Before making ANY implementation changes, you MUST:

1. Test for conflicts using test_keymaps_conflicts.lua
2. Ask for explicit permission to proceed with changes
3. Only make changes when explicitly authorized

## Build/Lint/Test Commands

- **Lua formatting**: `stylua .` (2 spaces, 120 column width)
- **JS/TS formatting**: `biome format --write .` or `prettier --write .`
- **Headless testing**: `nvim --headless -u NONE -c 'source test.lua'`
- **Keymap conflict check**:
  - Location: `lua/config/test-utils/test_keymaps.lua`
  - Usage: `echo 'lua_table' | lua lua/config/test-utils/test_keymaps.lua`
  - Format: Lua table with mode, lhs, rhs, desc fields
  - Example:

    ```bash
    echo '{
      { mode = "n", lhs = "<leader>hf", rhs = "function() vim.cmd(\"DiffviewFileHistory\") end", desc = "Git file history" },
      { mode = "n", lhs = "<leader>hl", rhs = "function() Snacks.picker.git_log() end", desc = "Git log" }
    }' | lua lua/config/tests/test_keymaps_conflicts.lua
    ```

  - Output: "NO CONFLICTS FOUND" or detailed conflict list
  - Tests against actual loaded Neovim keymaps in headless mode
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

## Test Structure

- **Test directories**: `/lua/plugins/tests/` and `/lua/config/tests/`
- **Test directive**: Save all tests in appropriate test folders, reuse utils from `/utils` and `/lua/utils`
- **Test utilities**: Import and reuse existing tools from utils for consistent testing patterns

## Custom Layout (Graphite)

- **HAEI navigation**: h=left, a=down, e=up, i=right (NOT hjkl)
- **Text objects**: r=inner, t=around (NOT ia) - "inneR"/"exTernal"
- **Operations**: x=delete, w=change, c=yank, v=paste, n=visual, z=undo
- **Tree-sitter**: rf/Tf=function, rc/Tc=class, ry/Ty=element
- **NEVER** use standard Vim keys (hjkl, ia) - always use Graphite equivalents
