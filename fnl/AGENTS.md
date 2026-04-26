# Fennel Keymap Migration

Incrementally migrate Neovim keymaps from the Lua `keymap-utils` DSL to a Fennel macro-based system that compiles to flat `vim.keymap.set` calls.

## Goal

Replace the runtime Lua table-walking approach (`kmu.create_smart_map()`) with compile-time Fennel macros (`defgroup`, `defkeys`, `modifier`, `cmd`). The Fennel layer compiles down to the same `vim.keymap.set` calls — no runtime cost, no silent-overwrite bugs, conflict detection at compile time.

## Language & Framework

- **Language**: Fennel (compiles to Lua)
- **Runtime**: Neovim Lua API (`vim.keymap.set`, `vim.cmd`)
- **Compiler**: `hotpot.nvim` — intercepts `require()`, compiles `.fnl` on demand, caches internally
- **Existing library**: `keymap-utils` (stays as-is, used as the registration backend)
- **Layout**: Graphite/HAEI — H=left, A=down, E=up, I=right, R=inner, T=around

## Architecture

### Two independent accumulators

The macro system tracks two things separately:

1. **key-acc** — modifier prefix that builds the actual key string (`<C-S-f>`)
2. **group-acc** — semantic label for which-key group names (`files/`)

Modifiers (`ctrl`, `shift`, `alt`) extend key-acc only. Semantic groups (`files`, `buffers`) extend group-acc only. A leaf node reads both and emits one registration.

### Source structure

```
fnl/
  config/
    keymaps/
      init.fnl          -- entry point, requires all groups
      navigation.fnl    -- ]h [h ]s [s bracket pairs
      clipboard.fnl     -- <leader>p group
      ctrl.fnl          -- all ctrl+key bindings (merged, one block)
      files.fnl         -- file operations
      surround.fnl      -- replaces keymaps-surround.lua
    macros.fnl          -- defgroup, defkeys, modifier, cmd (hotpot detects *macros.fnl)
    macro-utils.fnl     -- shared macro helpers (optional, also *macros.fnl convention)
  tests/
    keymaps_spec.fnl    -- mirrors existing keymap tests

lua/
  keymap-utils/         -- unchanged, stays as library
```

### Compilation

`hotpot.nvim` handles compilation transparently:
- `require("config.keymaps")` finds `fnl/config/keymaps/init.fnl`, compiles and caches it
- Files ending in `macros.fnl` or `macro.fnl` get the macro compiler environment automatically
- No Makefile needed — hotpot compiles on demand and caches internally
- To inspect compiled output: `:Hotpot eval` or check the cache directory

## Migration phases

1. **Macro layer** — write and test `macros.fnl`, verify compiled output with `:Hotpot eval`. No config changes.
2. **One group** — migrate `clipboard.fnl` first (self-contained, low risk). Comment out old block in `keymaps.lua`, add `require("config.keymaps.clipboard")`.
3. **Remaining groups** — migrate by complexity: navigation, ctrl, files, surround. Each follows: write `.fnl` -> add require -> comment old -> test -> delete old after stability window.
4. **Cleanup** — `keymaps.lua` becomes a list of requires. Delete old blocks.

## Safety rule

`lua/config/keymaps.lua` is the seam. It requires both old Lua blocks and new Fennel modules (loaded by hotpot) simultaneously. The old block is commented, not deleted, until stable. At no point is the config in a broken intermediate state.

## Commands

```bash
make test       # run plenary tests
make format     # stylua + fnlfmt
```

## What stays unchanged

- `keymap-utils/` — library, not config. Tested independently.
- `lua/config/autocmds.lua`, `options.lua`, `lazy.lua` — no migration needed.
- Graphite/HAEI layout remaps — these are simple enough to stay in Lua or migrate last.

## Use learning-coach for this directory

This directory uses the `learning-coach` skill. Exercises focus on writing Fennel macros and migrating keymap groups incrementally.
