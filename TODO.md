## keymaps

- [x] create a folder lua/functions and move all functions declarations out of keymaps.lua into files to files grouped by category
- [x] move all usage of lil and mappings from files in keymaps/*.lua to a config/keymaps.lua  
- [x] move functions declarations from keymaps/*.lua to their respective category
- [x] extract clipboard operations to utils/clipboard.lua with lil.extern
- [x] extract editor operations to utils/editor.lua with lil.extern
- [x] extract navigation operations to utils/navigation.lua with lil.extern
- [x] extract search operations to utils/search.lua with lil.extern
- [x] categorize history operations that use inline functions
- [x] categorize git operations that use inline functions
- [ ] convert remaining vim.keymap.set calls to lil.map pattern where applicable
- [ ] categorize Graphite layout navigation keymaps (h/a/e/i movement)
- [ ] categorize text object operations (r/t inner/around mappings)
- [ ] categorize fold operations (fo/fu/ff/fF/fe/fa)
- [ ] categorize copy/paste operations (c/v/C/V/cc)
- [ ] categorize change/delete operations (w/W/x/xx)
- [ ] categorize visual mode operations (n/N/X)
- [ ] categorize line operations (j/J/0/p/.)
- [ ] categorize jumplist/search operations (o/O/m/M/;/g;/-)
- [ ] categorize word movement operations (l/d/L/D)
- [ ] categorize treewalker operations (vim.keymap.set calls)
- [ ] categorize buffer/window navigation operations
- [ ] categorize special key overrides (Q/gX/gU/gQ/gK/gh)
- [ ] categorize F-key operations (F1/F2)
- [ ] categorize terminal operations
- [ ] create utils/override.lua with map function that handles key deletion/overriding
- [ ] convert remap() calls to use lil.map pattern with override behavior
- [ ] identify vim.keymap.set calls that need override behavior vs regular mapping
- [ ] implement lil.map-compatible override function for conflicting keymaps
- [ ] replace manual pcall(vim.keymap.del) + map patterns with override utility

## TreeSitter

- [ ] categorize TreeSitter text object operations (rf/tf/rc/tc functions)
- [ ] organize TreeSitter JSX element selection (te function)
- [ ] consider extracting TreeSitter operations to utils/treesitter.lua

## Surround

- [ ] categorize surround operator mappings (r/t with brackets/quotes)
- [ ] organize surround text object mappings (r(/r)/r[/r]/r{/r}/r"/r')
- [ ] organize surround around mappings (t(/t)/t[/t]/t{/t}/t"/t')
- [ ] consider extracting surround operations to utils/surround.lua
- [ ] surround with and without space is backwards

## TBD

- [ ] checkmate.nvim is conflicting with markdown tables