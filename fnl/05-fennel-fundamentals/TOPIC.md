# Focus: Fennel Fundamentals for This Project

The Fennel language features used in the keymap macro system — local bindings, require-macros, match, icollect, string concatenation, quasiquote/unquote, and gensym.

## Exercises to Cover
- Basic: Write `local` bindings and use `..` for string concatenation to build key strings manually
- Intermediate: Use `match` to dispatch on modifier names and `icollect` to collect results into a table
- Advanced: Write a macro using quasiquote/unquote that generates a `vim.keymap.set` call, with gensym for hygiene
- Variation: Use `require-macros` to import your macro from a separate file and verify it works at compile time only

## Key Concepts
- `local` for immutable bindings (`(local C (modifier :ctrl))`)
- `require-macros` imports macros at compile time only
- `match` for pattern matching inside macros (dispatch on `:ctrl`, `:shift`, etc.)
- `icollect` iterates and collects into a sequential table
- `..` concatenates strings (`(.. "<C-" key ">")`)
- Backtick (quasiquote) + comma (unquote) construct code in macros
- `key#` gensym prevents variable capture

## Real-World Scenarios
- Every macro in this project uses these primitives — they are the building blocks
- `require-macros` is how keymap files import the macro module

## Conceptual Questions
- What is the difference between `require` and `require-macros` in Fennel?
- Why does `key#` (gensym) matter for macro hygiene?
- What does quasiquote produce — code or data?

## Dictionary Reference
Part 5: sections 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7
