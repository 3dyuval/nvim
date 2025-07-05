# AGENTS.md - Neovim Configuration Development Guide

## Build/Lint/Test Commands
- **Lua formatting**: `stylua .` (2 spaces, 120 column width)
- **JS/TS formatting**: `biome format --write .` or `prettier --write .`
- **TypeScript check**: `tsc --noEmit` (available via `<leader>ct` keymap)
- **Plugin sync**: `nvim +Lazy sync +qa` or `<leader>rl` keymap
- **Config reload**: `:source $MYVIMRC` or `<leader>rr` keymap

## Code Style Guidelines
- **Lua**: 2-space indentation, snake_case for variables/functions, PascalCase for modules
- **JS/TS**: Single quotes, no semicolons, trailing commas off (biome config)
- **Imports**: Organize on save for TS/JS files, prefer non-relative imports
- **Error handling**: Use `pcall()` for Lua error handling, LSP diagnostics for TS/JS
- **Naming**: Descriptive function names, `local` variables, `require()` at top of files

## Key Architecture
- **Custom keymaps**: HAEI navigation (h=left, a=down, e=up, i=right)
- **Text objects**: r=inner (replaces i), t=around (replaces a)
- **Operations**: x=delete, w=change, c=yank, v=paste, n=visual, z=undo
- **LSP**: vtsls for TypeScript, volar for Vue, angularls for Angular
- **Formatters**: Conform.nvim with biome/prettier, auto-organize imports on save
- **Plugins**: LazyVim base with custom overrides in `lua/plugins/`

## Custom Keyboard Layout (Graphite)
This config uses a completely remapped layout replacing standard Vim navigation:
- **HAEI navigation**: h=left, a=down, e=up, i=right (replaces hjkl)
- **Text objects**: r=inner, t=around (replaces ia) - "r" for "inneR", "t" for "exTernal"
- **Tree-sitter objects**: rf/Tf=function, rc/Tc=class, ry/Ty=element (HTML/JSX)
- **Common patterns**: crf=copy function, wrd=change word, xr"=delete in quotes
- **Surround**: ysrd"=surround word with quotes, cs"'=change quotes to single

## Testing
- No specific test framework configured - check individual plugin documentation
- Use `:checkhealth` to verify plugin configurations
- Test keymaps with `utils/test_keymaps.lua` if needed