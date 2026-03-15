# Focus: Flat Bindings with defkeys

A flat list of key-description-action triples. No nesting, no grouping structure — comments provide visual sections. The `cmd` helper wraps Neovim commands.

## Exercises to Cover
- Basic: Write the `cmd` macro that wraps a command name in `<Cmd>...<CR>`
- Intermediate: Write a `defkeys` macro that walks triples and emits `vim.keymap.set` calls
- Advanced: Migrate a real group of ctrl bindings (files, buffers, search) into a single `defkeys` block with comment sections
- Variation: Compare the compiled Lua output against hand-written `vim.keymap.set` calls for equivalence

## Key Concepts
- `defkeys` walks bindings in triples: key, description, action
- `cmd` expands `(cmd "bprev")` to `"<Cmd>bprev<CR>"`
- Comments are visual sections for the author — compiler sees a flat list
- Merging groups is a non-issue because there are no block boundaries to conflict

## Real-World Scenarios
- Defining all ctrl-key bindings in one flat file (`ctrl.fnl`)
- Mixing function references (`files.find_files`) and command strings (`(cmd "bprev")`) in the same block

## Conceptual Questions
- Why does a flat triple list avoid the merging problem that nested Lua tables create?
- When would you choose `defkeys` over `defgroup`?

## Dictionary Reference
Part 2: sections 2.1, 2.2, 2.3, 2.4
