# Focus: Nested Grouping with defgroup

Tree structure where modifiers and semantic labels nest. The macro walks the tree at compile time, maintaining two independent accumulators, and emits flat `vim.keymap.set` calls.

## Exercises to Cover
- Basic: Implement the `walk` function with a single accumulator (key-acc only, no semantic groups)
- Intermediate: Add the second accumulator (group-acc) for which-key semantic labels
- Advanced: Handle modifier nesting where inner modifiers append (`<C-A-f>`) and semantic groups compose independently (`files/`)
- Variation: Add compile-time duplicate detection — error when the same full key appears twice

## Key Concepts
- Two independent accumulators: key-acc (modifier chars) and group-acc (semantic labels)
- Modifiers extend key-acc only; semantic groups extend group-acc only
- Leaf nodes read both accumulators to emit one registration
- Nesting accumulates — inner modifiers append, they don't replace
- Compile-time duplicate detection eliminates silent-overwrite bugs structurally

## Real-World Scenarios
- Grouping `ctrl` > `files` and `ctrl` > `shift` > `files` in one tree
- Which-key integration where group names like `files/` appear in the popup

## Conceptual Questions
- Why are the two accumulators independent rather than a single combined state?
- How does structural nesting prevent the duplicate-key bug that flat tables allow?
- What is the walk trace for `(defgroup :n (ctrl (alt :f "Find" action)))`?

## Dictionary Reference
Part 3: sections 3.1, 3.2, 3.3, 3.4, 3.5, 3.6
