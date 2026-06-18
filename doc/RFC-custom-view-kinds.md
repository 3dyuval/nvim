# RFC: Custom View Kind Registration API

**Status:** Design proposal  
**Use Case:** Allow plugins to extend diffview with custom view kinds (graph views, custom diffs, structured data views)

---

## Problem

Currently, diffview hardcodes view instantiation in `lua/diffview/lib.lua`:

```lua
function M.diffview_open(args)
  -- ...
  local v = DiffView({ ... })  -- Only DiffView supported
  table.insert(M.views, v)
end
```

To create a custom view (like gitgraph integrated with diffs), you must:
1. Fork diffview-plus
2. Patch `lib.lua` to instantiate your custom class
3. Manually register views in `M.views`

**Result:** No pluggable extension point. Each custom view requires a fork.

---

## Solution: Custom View Registration API

Expose a public API for plugins to register custom view **kinds** that extend built-in view classes.

### Design

```lua
local api = require("diffview.api")

-- Register a custom view kind
api.register_view_kind({
  name = "graph",                              -- unique kind identifier
  desc = "Gitgraph view",                      -- for debugging
  parent = "DiffView",                         -- inherit from DiffView or FileView
  
  -- Factory function: given parsed args, return a view instance or nil
  create = function(adapter, rev_arg, path_args, opts)
    -- Custom logic: e.g., augment file list with graph data
    local view = require("diffview.api.views.diff").DiffView({
      adapter = adapter,
      rev_arg = rev_arg,
      path_args = path_args,
      left = opts.left,
      right = opts.right,
      files = add_graph_files(opts.files),  -- Custom file list
    })
    return view
  end,
  
  -- Optional: parse custom command flags
  -- parse = function(argo) ... return custom_opts end,
})

-- Then use it:
-- :DiffviewOpen main..HEAD --kind=graph
```

### Core Implementation

#### 1. View Kind Registry

```lua
-- lua/diffview/view_kind.lua
local M = {}

---@class ViewKindSpec
---@field name string
---@field desc string
---@field parent "DiffView" | "FileView"
---@field create function
---@field parse? function

M.kinds = {}

function M.register(spec)
  assert(spec.name and spec.desc and spec.parent and spec.create)
  M.kinds[spec.name] = spec
  return spec
end

function M.get(name)
  return M.kinds[name]
end

function M.list()
  return M.kinds
end

return M
```

#### 2. Public API Exposure

```lua
-- lua/diffview/api/init.lua (add to existing)

M.view_kinds = lazy.require("diffview.view_kind")

-- Convenience wrapper
function M.register_view_kind(spec)
  M.view_kinds.register(spec)
end
```

#### 3. Integration into `diffview_open`

Modify `lua/diffview/lib.lua`:

```lua
function M.diffview_open(args)
  local default_args = config.get_config().default_args.DiffviewOpen
  local argo = arg_parser.parse(utils.flatten({ default_args, args }))
  local rev_arg = argo.args[1]
  
  -- ... adapter setup ...
  
  -- NEW: Check for --kind flag
  local kind_name = argo:get_flag("kind")
  if kind_name then
    local view_kind = require("diffview.view_kind").get(kind_name)
    if not view_kind then
      utils.err("Unknown view kind: " .. kind_name)
      return
    end
    
    local v = view_kind.create(adapter, rev_arg, adapter.ctx.path_args, opts)
    if v then
      table.insert(M.views, v)
      session.record_view(v, "diffview_open", args)
      logger:debug("Custom view '" .. kind_name .. "' instantiated!")
      return v
    end
    return
  end
  
  -- Fallback: default behavior
  local v = DiffView({ ... })
  -- ...
end
```

#### 4. Which-Key Integration (Optional)

```lua
-- Expose registered kinds in which-key
-- :Diffview<Tab> could show available kinds
```

---

## Example: Graph View Kind

```lua
-- in your plugin config
local diffview = require("diffview")

diffview.api.register_view_kind({
  name = "graph",
  desc = "Commit graph with diffs",
  parent = "DiffView",
  
  create = function(adapter, rev_arg, path_args, opts)
    local gitgraph = require("gitgraph")
    local CDiffView = require("diffview.api.views.diff").CDiffView
    
    -- Render gitgraph
    local graph_data = gitgraph.core.render_data(gitgraph.config, {}, {
      all = true,
      max_count = 256,
    })
    
    -- Create virtual "commit files" for the graph
    local files = {}
    for i, line in ipairs(graph_data.lines) do
      table.insert(files, {
        path = "commit:" .. i,
        status = "M",
        _graph_line = line,
      })
    end
    
    -- Create custom view with graph as file list
    local view = CDiffView({
      git_root = adapter.ctx.toplevel,
      files = files,
      
      get_file_data = function(path, split)
        -- Extract commit hash from path and show diff
        local hash = path:match("commit:(.+)")
        if split == "left" then
          return vim.fn.systemlist("git show " .. hash .. "^")
        else
          return vim.fn.systemlist("git show " .. hash)
        end
      end,
    })
    
    return view
  end,
  
  parse = function(argo)
    -- Handle graph-specific flags like --layout=compact
    return { layout = argo:get_flag("layout") or "default" }
  end,
})
```

Usage:
```vim
:DiffviewOpen main..HEAD --kind=graph
```

---

## Comparison: Before vs After

### Before (Current)

```
Plugin author wants graph view
  ↓
Fork diffview-plus
  ↓
Patch lib.lua to hardcode graph instantiation
  ↓
Maintain fork indefinitely
```

### After (With Registration API)

```
Plugin author wants graph view
  ↓
Call api.register_view_kind({ ... })
  ↓
Use :DiffviewOpen --kind=graph
  ↓
No fork needed
```

---

## Backward Compatibility

- ✅ Default behavior unchanged (no `--kind` flag = use DiffView as always)
- ✅ Existing commands work identically
- ✅ No breaking changes to public API
- ✅ CDiffView still works as-is

---

## Benefits

1. **Zero-fork composition** — Plugins don't need to fork diffview
2. **Discoverable** — `:Diffview<Tab>` could list available kinds
3. **Composable** — Stack views (e.g., `:DiffviewOpen --kind=graph --layout=two-pane`)
4. **Session persistence** — Views persist across sessions (inherited from base)
5. **Full keymaps** — Custom views inherit all diffview actions

---

## Open Questions

1. **Should kinds be per-project?** — `nvim_dir/diffview.lua` to auto-register kinds
2. **Lifecycle hooks?** — `on_create`, `on_open`, `on_close` for setup/teardown
3. **View composition?** — Can kinds wrap other kinds? (e.g., `--kind=graph --base=file_history`)
4. **Async creation?** — What if creating a view needs async work (git queries)?

---

## Implementation Roadmap

**Phase 1:** Core registration API
- [ ] Add `view_kind.lua` registry
- [ ] Expose `api.register_view_kind()`
- [ ] Parse `--kind` flag in `diffview_open`
- [ ] Route to custom factory if kind registered

**Phase 2:** Enhanced CLI
- [ ] Tab-completion for `--kind` values
- [ ] Help text showing registered kinds
- [ ] Error messages when kind not found

**Phase 3:** Integration
- [ ] Session persistence for custom views
- [ ] Which-key grouping for view kinds
- [ ] Built-in kinds (e.g., `--kind=file_history` as alias for `:DiffviewFileHistory`)

---

## References

- **Current integration:** `/home/yuv/.config/nvim/fnl/integration/diffview-cdiffview.fnl`
- **View architecture:** `lua/diffview/lib.lua`, `lua/diffview/scene/view.lua`
- **CDiffView API:** `lua/diffview/api/views/diff/diff_view.lua`
