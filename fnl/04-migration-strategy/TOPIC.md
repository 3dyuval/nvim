# Focus: Migration Strategy

Incrementally migrate from Lua keymap-utils DSL to compiled Fennel. The seam file (`keymaps.lua`) requires both old and new modules simultaneously — at no point is the config broken.

## Exercises to Cover
- Basic: Install hotpot.nvim, write a trivial `.fnl` module, verify `require()` loads it
- Intermediate: Migrate `clipboard.fnl` — write the Fennel, add the require, comment the old block, run tests
- Advanced: Migrate `ctrl.fnl` — merge multiple ctrl sections into one flat `defkeys` block, handle mixed function refs and commands
- Variation: Use `:Hotpot eval` to inspect compiled output and verify it matches expected `vim.keymap.set` calls

## Key Concepts
- `hotpot.nvim` compiles `.fnl` on demand — no Makefile needed
- `keymaps.lua` is the seam — requires both old Lua and new Fennel modules (hotpot resolves `fnl/`)
- Old blocks are commented, not deleted, until stable (one week)
- Migration order follows complexity: clipboard -> navigation -> ctrl -> files -> surround
- `keymap-utils/` stays unchanged as the registration backend

## Real-World Scenarios
- Running `make test` after each migration step to catch regressions
- Using `:Hotpot eval` and `:Hotpot log` to debug compilation issues

## Conceptual Questions
- Why comment rather than delete old blocks during migration?
- What makes `clipboard.fnl` the safest first migration target?

## Dictionary Reference
Part 4: sections 4.1, 4.2, 4.3, 4.4, 4.5
