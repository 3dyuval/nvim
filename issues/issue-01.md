# debug: conform default_format_opts override discrepancy

context:
LazyVim uses `LazyVim.format()` for format-on-save which delegates to conform.nvim. User config's `opts.default_format_opts` completely replaces LazyVim's defaults instead of merging.

files:

- lua/plugins/conform.lua
- ~/.local/share/nvim/lazy/LazyVim/lua/lazyvim/plugins/formatting.lua (external)
- ~/.local/share/nvim/lazy/LazyVim/lua/lazyvim/util/format.lua (external)
- library-id: /lazyvim/lazyvim

reproduction:

1. Set `default_format_opts = { lsp_format = "fallback" }` in conform.lua
2. Save a file - formatting may behave unexpectedly

what to find and where and how to find it:

**LazyVim's expected defaults** (formatting.lua:66-72):

```lua
default_format_opts = {
  timeout_ms = 3000,
  async = false,
  quiet = false,
  lsp_format = "fallback",
},
```

**User config had** (conform.lua):

```lua
default_format_opts = {
  lsp_format = "fallback",  -- Only this!
},
```

**Flow:**

1. LazyVim creates `BufWritePre` autocmd → calls `LazyVim.format()`
2. `LazyVim.format()` calls registered conform formatter: `require("conform").format({ bufnr = buf })`
3. `conform.format()` merges with `default_format_opts` from user config
4. Missing fields use conform's internal defaults (not LazyVim's)

the tricky part and why:

Lua table `opts` **replaces** rather than **deep merges** with LazyVim defaults. This is standard lazy.nvim behavior but not obvious when only overriding one field.

**Secondary issue discovered:** `organize_imports` uses biome with `--formatter-enabled=false`, but biome's organize action still applies 4-space indentation. Subsequent format fixes to 2-space, but if format doesn't run, imports stay 4-space indented.

## Resolution

1. Added missing fields to `default_format_opts`:

```lua
default_format_opts = {
  timeout_ms = 3000,
  async = false,
  quiet = false,
  lsp_format = "fallback",
},
```

2. Added `conform.format()` call after `organize_imports` to fix indentation.
