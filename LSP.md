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

## tsgo LSP Capabilities

tsgo (TypeScript native compiler rewritten in Go) now provides full LSP support:

| Capability | Status | Notes |
|------------|--------|-------|
| `textDocument/completion` | ✅ | Full completions with snippets |
| `textDocument/definition` | ✅ | Go to definition |
| `textDocument/references` | ✅ | Find references |
| `textDocument/implementation` | ✅ | Go to implementation |
| `textDocument/hover` | ✅ | Hover documentation |
| `textDocument/signatureHelp` | ✅ | Function signatures |
| `textDocument/codeAction` | ✅ | Code actions |
| `textDocument/codeLens` | ✅ | Code lens |
| `textDocument/rename` | ✅ | Symbol rename |
| `textDocument/documentHighlight` | ✅ | Highlight references |
| `textDocument/documentSymbol` | ✅ | Document symbols |
| `workspace/symbol` | ✅ | Workspace symbols |
| `callHierarchy/incomingCalls` | ✅ | Incoming call hierarchy |
| `callHierarchy/outgoingCalls` | ✅ | Outgoing call hierarchy |
| `workspace/willRename` | ✅ | File rename support |
| `workspace/didRename` | ✅ | File rename support |

## Notes

- **vtsls** - Primary TS server with Vue support via `@vue/typescript-plugin`
- **tsgo** - Fast alternative TS server (10x faster type-checking)
- Both can run simultaneously; vtsls handles Vue hybrid mode
