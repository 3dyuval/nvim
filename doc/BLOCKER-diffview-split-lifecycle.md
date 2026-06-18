# Core Blocker: Diffview Split/Window Lifecycle Management

## The Real Problem

Whether you use vim-flog, gitgraph.nvim, or any other graph tool, the blocker is the same:

**Diffview doesn't expose an API for managing custom splits at runtime.**

You can create a graph split outside diffview's layout, but it becomes a **second-class citizen** without:
- Lifecycle management (open/close with view)
- Focus management (keyboard navigation between splits)
- State sync (window IDs, buffer handles)
- Event coordination (when does the split get destroyed?)

---

## Current Reality: Overlaid Splits

When you open a graph split via hooks, you're doing this:

```lua
-- In view_opened hook
vim.cmd("botright split")
graph_win = vim.api.nvim_get_current_win()
-- Render graph...
vim.api.nvim_set_current_win(src_win)  -- Restore focus manually
```

**Problems with this approach:**

1. **Lifecycle mismatch** — Graph window outlives the view if user closes diffview with `q`
2. **Window management** — No awareness of window IDs in diffview's layout system
3. **Focus management** — Can't use diffview's `<C-j>` / `<C-k>` to move between splits
4. **Buffer lifecycle** — Graph buffer isn't cleaned up when view closes
5. **State tracking** — Diffview doesn't know the split exists

---

## What's Needed: Dynamic Split API

Diffview should expose something like this:

```lua
-- Register a split type (once, at startup)
diffview.register_split("graph", {
  create = function(view, config)
    -- Return a split object with (buf, win, render function)
    return {
      buf = buf_id,
      win = win_id,
      render = function(buf, view) ... end,
      on_destroy = function() ... end,
    }
  end,
  
  keymaps = {
    select = "<CR>",
    prev = "A",
    next = "E",
  },
})

-- Add to view at creation time
opts.view.default.splits = { "graph" }  -- Alongside "file_panel"

-- Or: dynamically at runtime
view:add_split("graph", { position = "bottom", height = 16 })
view:remove_split("graph")
```

### What This Would Enable

✅ **Coordinated lifecycle** — Split opens/closes with view
✅ **Integrated focus** — `<C-j>/<C-k>` navigate between splits
✅ **Buffer management** — Diffview cleans up split buffers
✅ **Window tracking** — Diffview knows about all windows in the view
✅ **State consistency** — View and split state stay in sync

---

## Why vim-flog and gitgraph Both Hit This Wall

**vim-flog approach:**
```lua
-- Open flog buffer
vim.cmd("Flog")
-- Now we have TWO uncoordinated buffers
-- - diffview owns the diff windows
-- - flog owns its own window
-- - They don't know about each other
```

**gitgraph approach:**
```lua
-- Create split outside diffview
vim.cmd("botright split")
-- Same problem: two separate window trees
```

**What we need:**
```lua
-- Diffview knows about the split
view:add_split("graph", {...})
-- Now it's ONE coordinated layout
```

---

## Current Workarounds (All Fragile)

### Workaround 1: Overlay (Current)
Create split outside diffview layout via hooks. Problems: lifecycle mismatch, manual focus management.

### Workaround 2: Dual Mode
Use vim-flog or gitgraph standalone (not integrated with diffview). Problems: no sync, separate keybindings.

### Workaround 3: Fork Diffview
Add split management to diffview internals. Problems: maintenance burden, tight coupling.

---

## Implementation Path

### Phase 1: Layout API (Minimal)

Expose read-only access to diffview's layout system:

```lua
-- In diffview/scene/view.lua
function View:get_layout()
  return {
    windows = self.layout.windows,    -- [Window]
    config = self.layout.config,      -- Layout config
  }
end

function View:get_main_window()
  return self.layout:get_main_win()
end
```

**Cost:** ~20 lines
**Benefit:** Let recipes read what windows exist

---

### Phase 2: Split Registration (Medium)

Allow registration of split types:

```lua
-- New: diffview/scene/split_registry.lua
local M = {}
local splits = {}

function M.register(name, spec)
  splits[name] = spec
end

function M.get(name)
  return splits[name]
end

return M
```

**Cost:** ~50 lines
**Benefit:** Recipes can define split behavior once

---

### Phase 3: View Split Management (Substantial)

Expose split add/remove on views:

```lua
-- In diffview/scene/view.lua
function View:add_split(name, config)
  local split_spec = require("diffview.scene.split_registry").get(name)
  local split = split_spec.create(self, config)
  
  table.insert(self.splits, split)
  self.emitter:emit("split_added", name, split)
end

function View:remove_split(name)
  -- Find and remove split, cleanup
  self.emitter:emit("split_removed", name)
end
```

**Cost:** ~100 lines
**Benefit:** Dynamic split management, lifecycle coordination

---

### Phase 4: Integration (Refinement)

Coordinate splits with layout operations:

```lua
-- When view closes, close all registered splits
function View:close()
  for _, split in ipairs(self.splits) do
    if split.on_destroy then
      split.on_destroy()
    end
  end
  -- ... existing close logic
end

-- When focusing windows, iterate splits
function View:next_window()
  -- Move focus through layout windows + registered splits
end
```

**Cost:** ~100 lines
**Benefit:** Splits are true citizens of the view

---

## What This Solves

### For vim-flog Integration

```lua
-- Register flog as a split
diffview.register_split("flog", {
  create = function(view, config)
    vim.cmd("Flog")  -- Open flog window
    return {
      buf = vim.fn.bufnr("flog"),
      win = vim.api.nvim_get_current_win(),
      on_destroy = function()
        vim.cmd("bdelete")  -- Clean up flog buffer
      end,
    }
  end,
})

-- Add to diffview view
opts.view.default.splits = { "flog" }  -- Now integrated!
```

### For gitgraph Integration

```lua
-- Register gitgraph as a split
diffview.register_split("gitgraph", {
  create = function(view, config)
    local buf = vim.api.nvim_create_buf(false, true)
    -- Render gitgraph into buf
    return {
      buf = buf,
      win = ...,
      render = function(buf, view) ... end,
    }
  end,
})
```

### For Any Custom Panel

```lua
-- Register custom status/info panel
diffview.register_split("status", {
  create = function(view, config)
    -- Show custom status
  end,
})
```

---

## Key Insight

The **architecture** doesn't change. You're not asking diffview to understand graphs. You're asking it to:

1. Let you register what a split looks like
2. Call your `create()` function when a view opens
3. Call your `on_destroy()` function when a view closes
4. Emit signals when splits are added/removed
5. Include registered splits in focus navigation

This is **pure composition**—diffview stays agnostic, plugins define the behavior.

---

## Why This Should Be Diffview's Responsibility

Diffview is "a view plugin." It manages windows, layout, lifecycle. A **split is part of the window hierarchy**. It belongs in diffview's scope:

- ❌ Diffview should NOT understand graphs
- ❌ Diffview should NOT understand commit data
- ✅ Diffview SHOULD manage window/split lifecycle
- ✅ Diffview SHOULD coordinate focus between splits
- ✅ Diffview SHOULD clean up split buffers on close

This is the core of its domain.

---

## Next Steps

1. **Document this as an RFC** — Post on diffview issues/discussions as a feature request
2. **Sketch the API** — Propose concrete function signatures (done above)
3. **Estimate effort** — ~250 lines of code across 3-4 phases
4. **Offer to implement** — If maintainer agrees, you can build it

---

## Related Documents

- `RECIPE-diffview-splits-extensibility.md` — Analysis of why splits are hard
- `gitgraph-integration-forks.md` — Current gap analysis
- `COMPARISON-flog-vs-gitgraph.md` — Graph tool comparison
