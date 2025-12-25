# LSP Capabilities Reference

## vtsls-specific Commands (`workspace/executeCommand`)

| Command | Keymap | Description |
|---------|--------|-------------|
| `typescript.organizeImports` | `<leader>co` | Organize imports |
| `typescript.removeUnusedImports` | `<leader>cu` | Remove unused imports |
| `typescript.selectTypeScriptVersion` | `<leader>cV` | Select TS version |
| `typescript.goToSourceDefinition` | `gD` | Go to source definition |
| `typescript.findAllFileReferences` | `gR` | File references |

## Code Actions (`source.*`)

| Action | Keymap | Description |
|--------|--------|-------------|
| `source.addMissingImports.ts` | `<leader>cI` | Add missing imports |
| `source.fixAll.ts` | `<leader>cF` | Fix all diagnostics |
| `source.organizeImports` | - | Used by conform |

## LSP Server Capabilities Used

| Capability | Location | Purpose |
|------------|----------|---------|
| `inlayHintProvider` | typescript-tools LspAttach | Inline type hints |
| `renameProvider` | files.lua smart_rename | Symbol/file rename |
| `documentSymbolProvider` | lsp-config.lua | Navic breadcrumbs |

## Autocommands

| Event | Plugin | Action |
|-------|--------|--------|
| `LspAttach` | typescript-tools | Enable inlay hints |
| `LspAttach` | project-diagnostics | Populate workspace diagnostics |

## Notes

- These features require **vtsls** or **typescript-tools** LSP
- **tsgo** is a compiler only - use for fast type-checking (`<leader>ct`)
- tsgo does not provide LSP features (completions, go-to-def, etc.)
