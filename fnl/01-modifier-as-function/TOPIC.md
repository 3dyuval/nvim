# Focus: Modifier as a Function

A modifier is a function that wraps a key with a prefix string. Declare it once, apply it everywhere — resolved at compile time with zero runtime cost.

## Exercises to Cover
- Basic: Write a `modifier` macro that handles a single modifier (`:ctrl` -> `<C-key>`)
- Intermediate: Extend to compose multiple modifiers (`(modifier :ctrl :shift)` -> `<C-S-key>`)
- Advanced: Verify compile-time resolution — confirm the output Lua contains plain string literals, no function calls
- Variation: Compare with the Lua `[ctrl]` table key approach and identify the silent-overwrite bug it prevents

## Key Concepts
- Macro returns a function that prepends modifier prefix to a key
- Multiple modifiers compose via `icollect` + `match`
- No runtime cost — resolves during Fennel compilation
- Eliminates silent-overwrite bugs from duplicate table keys

## Real-World Scenarios
- Defining `C`, `CS`, `CA` modifier shorthands used across all keymap files
- Ensuring `<C-f>` and `<C-S-f>` are distinct, composable bindings

## Conceptual Questions
- Why does a macro-based modifier have zero runtime cost while a Lua table key does not?
- What happens in the Lua DSL when two `[ctrl]` blocks appear in the same table?

## Dictionary Reference
Part 1: sections 1.1, 1.2, 1.3, 1.4
