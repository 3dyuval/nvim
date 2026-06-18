# RFC: Split Registration API for Diffview

**Status:** Proposal  
**Author:** Yuval Dikerman  
**Date:** 2026-06-18  
**Scope:** Feature request for `dlyongemallo/diffview-plus.nvim`

---

## Problem Statement

Diffview has a powerful **view registration system** that allows external plugins to define new view kinds (e.g., `:DiffviewGraph` as a custom view). This works well for new *primary* views.

However, there's a gap for **splits within an existing view**—custom panels/sidebars that:
- Belong to a view (not standalone)
- Participate in the view's window lifecycle
- Have coordinated focus management
- Can be registered and toggled via config

Currently, the only way to add a split is to create it **outside diffview's layout system** via hooks, which results in:
- ❌ Lifecycle mismatches (split outlives view)
- ❌ Manual focus management (no `<C-j>` / `<C-k>` navigation)
- ❌ Unmanaged buffers (no cleanup on view close)
- ❌ No session persistence

**Real-world use case:** A gitgraph or commit history sidebar that stays synced with the main diff view.

---

## Proposal

Expose a **split registration API** that mirrors the existing view registration system:

```lua
-- Similar to: diffview.register_view_kind("custom", {...})
diffview.register_split_kind("graph", {
  --- Create split for this view
  ---@param view View
  ---@param config table Split config (position, height, etc.)
  ---@return {buf: integer, win: integer, state: table?, on_close: function?}
  create = function(view, config)
    -- Create and return split
    local buf = vim.api.nvim_create_buf(false, true)
    vim.cmd("botright split | buffer " .. buf)
    local win = vim.api.nvim_get_current_win()
    
    return {
      buf = buf,
      win = win,
      state = {},  -- Optional: any state the split wants to persist
      on_close = function()  -- Optional: cleanup callback
        vim.api.nvim_buf_delete(buf, { force = true })
      end,
    }
  end,
  
  --- (Optional) Restore split from persisted session
  ---@param view View
  ---@param state table The state returned by create() -> state
  restore = function(view, state)
    -- Re-create from saved state
  end,
})

-- Then use in config:
opts.view.default.splits = {
  position = "bottom",
  kinds = { "graph" },  -- Include "graph" split in this view
  config = {
    graph = { height = 16 }  -- Pass config to split's create()
  }
}
```

---

## Detailed Design

### 1. Core API (New Module)

**File:** `lua/diffview/scene/split_registry.lua`

```lua
local M = {}
local split_kinds = {}

---Register a split kind
---@param kind_name string
---@param spec table {create, restore?, keymaps?, hooks?}
function M.register(kind_name, spec)
  assert(type(spec.create) == "function", "spec.create must be a function")
  split_kinds[kind_name] = spec
end

---Get registered split spec
---@param kind_name string
---@return table?
function M.get(kind_name)
  return split_kinds[kind_name]
end

---List all registered splits
---@return string[]
function M.list()
  return vim.tbl_keys(split_kinds)
end

return M
```

**Cost:** ~30 lines

---

### 2. View Split Management

**File:** `lua/diffview/scene/view.lua` (modifications)

```lua
--- Add splits to a view
---@param self View
---@param splits_config table {kinds: string[], config: table<string, table>}
function View:init_splits(splits_config)
  if not splits_config or not splits_config.kinds then
    return
  end
  
  self.splits = {}
  local registry = require("diffview.scene.split_registry")
  
  for _, kind_name in ipairs(splits_config.kinds) do
    local spec = registry.get(kind_name)
    if spec then
      local split_config = splits_config.config[kind_name] or {}
      local split = spec.create(self, split_config)
      
      if split then
        split.kind = kind_name
        split.spec = spec
        table.insert(self.splits, split)
        self.emitter:emit("split_added", kind_name, split)
      end
    end
  end
end

--- Close all splits
---@param self View
function View:destroy_splits()
  if not self.splits then return end
  
  for _, split in ipairs(self.splits) do
    if split.on_close then
      split.on_close()
    end
  end
  
  self.splits = {}
end

--- Call this in existing View:close()
function View:close()
  self:destroy_splits()  -- NEW
  -- ... existing close logic
end

--- Call this in existing View:open()
function View:open()
  self:init_layout()
  self:post_open()
  apply_diffopt(self)
  
  -- NEW: initialize splits after layout
  local config = config.get_config()
  if config.view[self.layout_name] and config.view[self.layout_name].splits then
    self:init_splits(config.view[self.layout_name].splits)
  end
  
  DiffviewGlobal.emitter:emit("view_opened", self, keymaps_context)
  DiffviewGlobal.emitter:emit("view_enter", self)
end
```

**Cost:** ~60 lines

---

### 3. Config Integration

**File:** `lua/diffview/config.lua` (modifications)

Add to view defaults:

```lua
local defaults = {
  view = {
    default = {
      layout = "diff2_horizontal",
      winbar_info = true,
      splits = {
        -- position = "bottom",  -- or "top", "left", "right"
        kinds = {},  -- Empty by default; user configures
        config = {},  -- Per-split config
      },
    },
  },
}
```

**Cost:** ~15 lines

---

### 4. Session Persistence

**File:** `lua/diffview/session.lua` (modifications)

Add splits to session record:

```lua
--- In session:record_view(view)
local function record_view(view)
  local splits_data = {}
  if view.splits then
    for _, split in ipairs(view.splits) do
      if split.state and split.spec.restore then
        splits_data[split.kind] = split.state
      end
    end
  end
  
  local entry = {
    kind = view.kind,
    layout = view.layout_name,
    splits = splits_data,  -- NEW
    -- ... rest of entry
  }
  
  return entry
end

--- In session:restore_view(lib, entry)
local function restore_view(lib, entry)
  local view_spec = view_registry.get(entry.kind)
  local view = view_spec.create(lib, entry)
  
  -- Restore splits
  if entry.splits then
    local registry = require("diffview.scene.split_registry")
    for kind_name, state in pairs(entry.splits) do
      local spec = registry.get(kind_name)
      if spec and spec.restore then
        spec.restore(view, state)
      end
    end
  end
  
  return view
end
```

**Cost:** ~40 lines

---

### 5. Public Entry Point

**File:** `lua/diffview/init.lua` (modifications)

```lua
local M = require("diffview.init")

---Register a split kind for use in views
---@param kind_name string
---@param spec table {create, restore?, keymaps?, hooks?}
function M.register_split_kind(kind_name, spec)
  require("diffview.scene.split_registry").register(kind_name, spec)
end

return M
```

**Cost:** ~10 lines

---

## Usage Examples

### Example 1: vim-flog as a Split

```lua
-- user config
require("diffview").register_split_kind("flog", {
  create = function(view, config)
    vim.cmd("Flog")
    local flog_win = vim.api.nvim_get_current_win()
    local flog_buf = vim.api.nvim_get_current_buf()
    
    return {
      buf = flog_buf,
      win = flog_win,
      on_close = function()
        if vim.api.nvim_buf_is_valid(flog_buf) then
          vim.api.nvim_buf_delete(flog_buf, { force = true })
        end
      end,
    }
  end,
})

-- In diffview config:
require("diffview").setup({
  view = {
    default = {
      layout = "diff2_horizontal",
      splits = {
        kinds = { "flog" },
        config = {
          flog = { position = "left" }  -- Passed to create()
        }
      },
    },
  },
})
```

### Example 2: Custom gitgraph Split

```lua
require("diffview").register_split_kind("gitgraph", {
  create = function(view, config)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.cmd("botright split")
    local win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(win, buf)
    vim.api.nvim_win_set_height(win, config.height or 16)
    
    -- Render graph
    local gitgraph = require("gitgraph")
    local graph = gitgraph.open({
      config = gitgraph.config,
      args = { all = true, max_count = 256 },
      on_select = function(commit)
        -- Jump to commit in diffview
        vim.cmd("DiffviewOpen " .. commit.hash .. "^!")
      end,
    })
    graph:render(buf)
    
    return {
      buf = buf,
      win = win,
      state = { graph_data = graph },
      on_close = function()
        vim.api.nvim_buf_delete(buf, { force = true })
      end,
    }
  end,
})
```

---

## Benefits

### For Users

✅ **Integrated splits** — Custom panels are true citizens of the view
✅ **Lifecycle management** — Splits open/close with the view
✅ **Session persistence** — Splits are restored across sessions
✅ **Declarative config** — No hooks needed, just config
✅ **Focus coordination** — Unified window navigation

### For Plugin Developers

✅ **Clear contract** — Know exactly what to implement
✅ **Lifecycle signals** — When to create, when to cleanup
✅ **State persistence** — How to save/restore session state
✅ **Composition** — Register once, use in any view

### For Diffview

✅ **Extensibility** — Unlock custom split use cases
✅ **Backward compatible** — Existing views unchanged
✅ **Low maintenance** — Plugins own their split logic
✅ **Proven pattern** — Already works for views (copy-paste design)

---

## Implementation Effort

| Phase | Work | Cost |
|-------|------|------|
| Core API | `split_registry.lua` | ~30 LOC |
| View integration | `view.lua` changes | ~60 LOC |
| Config | `config.lua` defaults | ~15 LOC |
| Session | `session.lua` restore | ~40 LOC |
| Entry point | `init.lua` public API | ~10 LOC |
| **Total** | | **~155 LOC** |

**Estimated time:** 4-6 hours (familiar codebase pattern)

---

## Precedent

This design mirrors the **existing view registration system**:

| Aspect | Views | Splits (Proposed) |
|--------|-------|-------------------|
| Registry | `view_registry.lua` | `split_registry.lua` |
| Public API | `diffview.register_view_kind()` | `diffview.register_split_kind()` |
| Create callback | `view:create(lib, args)` | `split:create(view, config)` |
| Restore callback | `view:restore(lib, state)` | `split:restore(view, state)` |
| Config | `opts.view.default.layout` | `opts.view.default.splits.kinds` |
| Session | Persisted in session file | Persisted in view entry |

**Why this works:** You've already solved this problem for views. This is the same pattern, one level deeper.

---

## Open Questions

1. **Focus navigation** — Should diffview automatically wire `<C-j>` / `<C-k>` to cycle through splits? Or let splits define their own focus logic?
2. **Split positioning** — Support `top`, `bottom`, `left`, `right`? Or keep it simple (just height config)?
3. **Multiple splits** — Can a view have multiple splits of the same kind? Different kinds?
4. **Keymaps** — Should split specs export their own keymaps? Or let them set up via hooks?
5. **Shared state** — Can splits access view state (current entry, layout, etc.)? Full access or read-only?

---

## Next Steps

1. **Feedback** — Does this align with diffview's vision?
2. **Design discussion** — Iterate on API if needed
3. **Implementation** — Build in phases
4. **Testing** — Validate with vim-flog and gitgraph integrations
5. **Documentation** — Cookbook for plugin developers

---

## Related Issues / Discussions

- Diffview issue #240 (stateful view integration)
- vim-flog maturity comparison
- gitgraph.nvim API stability
- Session persistence for custom views

---

## Appendix: Why Not Just Use Hooks?

**Current approach** (hooks-only):
```lua
opts.hooks = {
  view_opened = function(view)
    -- Create split manually
    vim.cmd("botright split")
    -- ... manual management
  end,
}
```

**Problems:**
- ❌ Lifecycle mismatch (view closes, split remains)
- ❌ No cleanup signals
- ❌ No session persistence
- ❌ Manual focus management
- ❌ Each recipe reimplements the same pattern

**Split registration approach:**
```lua
diffview.register_split_kind("graph", { create = ... })
opts.view.default.splits.kinds = { "graph" }
```

**Benefits:**
- ✅ Coordinated lifecycle
- ✅ Automatic cleanup
- ✅ Session persistence
- ✅ Integrated focus
- ✅ DRY (define once, use everywhere)

It's the difference between "I can bolt something on" and "it's a first-class feature."
