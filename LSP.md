# LSP Capabilities Reference

## Active Configuration

Three servers run together for Vue files:

| Server | Filetypes | Role |
|--------|-----------|------|
| vtsls | ts, tsx, js, jsx, vue | TypeScript diagnostics, completions, commands |
| vue_ls | vue | Template diagnostics (hybrid mode) |
| cssls | css, scss, less, vue | CSS/SCSS diagnostics |

`vue_ls` runs in `hybridMode: true` — it handles the template and delegates TypeScript
to vtsls via `@vue/typescript-plugin`. Its `renameProvider` and `documentSymbolProvider`
are disabled on init so vtsls owns those features.

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
| `source.organizeImports` | — | Used by conform |

## LSP Server Capabilities

| Capability | Owner | Notes |
|------------|-------|-------|
| `documentSymbolProvider` | vtsls | vue_ls disabled on init |
| `renameProvider` | vtsls | vue_ls disabled on init |
| `inlayHintProvider` | vtsls | Enabled on LspAttach |

## Known Limitation: Document Symbols in Vue SFCs

**Root cause:** Volar hybrid mode emits no document symbols, and the only client that
could (vue_ls in non-hybrid/takeover mode) is disabled by design.

In `hybridMode: true`, vue_ls produces zero document symbols and defers script symbols
to vtsls via `@vue/typescript-plugin`. vtsls in turn only sees the generated virtual TS
file, so it returns flat import declarations — all `kind: 5` (Class), no component body
symbols (refs, computed, functions). Neither server yields anything usable for
`<script setup>`.

A handler in `fnl/lsp/setup.fnl` filters vtsls's noisy import symbols by name pattern,
leaving an empty list. Re-enabling `documentSymbolProvider` on vue_ls does **not** help —
verified empirically, vue_ls returns 0 symbols in hybrid mode.

**Empirical check** (`Passengers.vue`, via `textDocument/documentSymbol` to each client):

| Client | Count | Notes |
|--------|-------|-------|
| vue_ls (hybrid) | 0 | emits nothing |
| vtsls | 0 | flat imports, stripped by filter |
| cssls | 171 | junk — `script lang`, `import`, `from`… all `kind: 5`, misparsed `<script>` block |

cssls answering `documentSymbol` for `.vue` is a separate noise source worth suppressing.

**Avenues:** switch Volar out of hybrid mode (vue_ls owns TS + symbols, lose vtsls
commands), or split servers by filetype (see below). `typescript-tools.nvim` produced
correct Vue symbols via custom tsserver protocol wrapping.

### Server Comparison

| Feature | vtsls | typescript-tools | ts_ls |
|---------|-------|-----------------|-------|
| Vue hybrid mode | ✅ | ❌ | ✅ |
| `willRenameFiles` | ✅ (after #288) | ✅ | ✅ |
| Vue document symbols | ❌ | ✅ | unknown |
| vtsls commands (gD, gR…) | ✅ | ❌ (TSTools*) | ❌ |
| Status | recommended | active | deprecated |

### Potential Fix

Split TypeScript servers by filetype:
- **vtsls** → `.ts`, `.tsx`, `.js`, `.jsx` — full commands, clean symbols
- **typescript-tools** → `.vue` — proper Vue SFC symbol support
- **vue_ls** → `.vue` — template diagnostics (hybrid mode)

Filed: [yioneko/vtsls#287](https://github.com/yioneko/vtsls/issues/287) (willRenameFiles — resolved)
Pending: vtsls Vue document symbols — no open issue yet

## tsgo LSP Capabilities

tsgo (TypeScript native compiler rewritten in Go) provides full LSP support and is
10x faster for type-checking. Can run alongside vtsls; vtsls handles Vue hybrid mode.

| Capability | Status |
|------------|--------|
| `textDocument/completion` | ✅ |
| `textDocument/definition` | ✅ |
| `textDocument/references` | ✅ |
| `textDocument/documentSymbol` | ✅ |
| `workspace/willRename` | ✅ |
| `workspace/didRename` | ✅ |
