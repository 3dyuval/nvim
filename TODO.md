
Keymaps

## Categorize

- [x] categorize fold operations (fo/fu/ff/fF/fe/fa)
- [ ] categorize copy/paste operations (c/v/C/V/cc)
- [ ] categorize change/delete operations (w/W/x/xx)
- [ ] categorize line operations (j/J/0/p/.)
- [ ] categorize buffer/window navigation operations
- [ ] categorize special key overrides (Q/gX/gU/gQ/gK/gh)

## Architecture

- [ ] implement lil.map-compatible override function for conflicting keymaps
- [ ] convert remap() calls to use lil.map pattern with override behavior
- [ ] identify vim.keymap.set calls that need override behavior vs regular mapping
- [ ] replace manual pcall(vim.keymap.del) + map patterns with override utility
- [ ] ~/.config/nvim/lua/config/keymaps.lua

## TreeSitter / TreeWalker / Surround

- [ ] Colocate TreeSitter / Surround / Treewalker @started(09/22/25 05:35)
- [ ] categorize treewalker operations
- [ ] -- map({ "n" }, "<M-C-a>", "<cmd>move .+1<cr>==", { desc = "Move line down" })
- [ ] -- map({ "n" }, "<M-C-e>", "<cmd>move .-2<cr>==", { desc = "Move line up" })
- [ ] organize TreeSitter JSX element selection (te function)
- [ ] categorize surround operator mappings (r/t with brackets/quotes)
- [ ] organize and validate surround text object mappings (r(/r)/r[/r]/r{/r}/r"/r')
- [ ] organize and validate surround around mappings (t(/t)/t[/t]/t{/t}/t"/t')

## Markdown

- [ ] recreate the defaults with t instead of T
- [ ] add metadata @started(09/22/25 05:52)
- [x] add todos
- [x] add more
- [ ] debug Conform warnings -  npx prettier --check README.md --log-level debug
checkmate metadata keymaps

## Archive

- [x] create a folder lua/functions and move all functions declarations out of keymaps.lua into files to files grouped by category
- [x] move all usage of lil and mappings from files in keymaps/*.lua to a config/keymaps.lua  
- [x] move functions declarations from keymaps/*.lua to their respective category
- [x] extract clipboard operations to utils/clipboard.lua with lil.extern
- [x] extract editor operations to utils/editor.lua with lil.extern
- [x] extract navigation operations to utils/navigation.lua with lil.extern
- [x] extract search operations to utils/search.lua with lil.extern
- [x] categorize history operations that use inline functions
- [x] categorize git operations that use inline functions
- [x] categorize Graphite layout navigation keymaps (h/a/e/i movement)

