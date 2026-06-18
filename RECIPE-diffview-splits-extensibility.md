# Analysis: Diffview's Split/Panel Extensibility Model

## Question

Diffview is a "view" plugin. It's designed around flexible layout management. **How extensible is it for adding custom splits/panels?**

We explored this by trying to add a gitgraph panel as a second split. Here's what we found.

## Diffview's Architecture

### The View Model

```
View (abstract)
  ├─ StandardView (diff/file_history)
  │   ├─ DiffViewView
  │   ├─ FileHistoryView
  │   └─ MergeView
  └─ ...other views
```

Each view owns:
- A **layout** (the window/split structure)
- **panels** (file list, options, etc.)
- **buffers** (diff content, metadata)
- **keymaps** and **hooks**

### The Layout Model

```
Layout (abstract, one per view)
  ├─ Diff1, Diff2Hor, Diff2Ver, Diff3, etc.
  └─ Each layout owns:
      ├─ Windows (split objects with IDs)
      ├─ Files (content per window)
      └─ Creation logic (how to create splits)
```

A layout is **fixed at view creation time**. It's not meant to be dynamic or extensible at runtime.

### Panels

Panels are **buffers with special semantics**. Examples:
- `FilePanel` — file list with multi-select
- `FileHistoryPanel` — commit list with expand/collapse
- `OptionPanel` — merge conflict options

Panels are **owned by the view** and managed as part of its window layout.

## Where Custom Splits Hit Walls

### Wall 1: Layouts Are Baked In

**Problem:** Layouts are created once, at view startup, and are rigid.

```lua
-- In StandardView:init_layout()
self.default_layout = opt.default_layout or View.get_default_layout()
-- Later:
self.layout = layout_class({ emitter = self.emitter })
await(self.layout:create())
```

To add a gitgraph split, you'd need to:
- Create a new layout class (e.g., `Diff2GraphHor`)
- Register it in config
- The user selects it in `opts.view.default.layout`

**Why it's a wall:** This requires the **user to choose a layout at startup**. You can't dynamically add splits after the view opens.

**Implication:** A graph panel can't be optional or toggled with a keymap—it has to be part of the layout.

### Wall 2: Panels Are Not Composable

**Problem:** Panels are tightly coupled to their view.

Example: `FilePanel` is hardcoded into `DiffViewView`:

```lua
-- In diffview/scene/views/diff/diff_view.lua
function DiffViewView:init_layout()
  -- ...
  self.file_panel = FilePanel({ ... })
  -- Panel is owned by the view, part of its state
end
```

Panels have:
- Custom render logic
- Selection/multi-select state
- Lifecycle hooks (`on_select`, `on_focus_change`, etc.)
- Integration with the entry model

**Why it's a wall:** You can't bolt on a new panel (gitgraph) that participates in the view's state machine without modifying the view class itself.

**Implication:** A gitgraph panel would need to be:
1. Declared in the layout upfront, OR
2. Added as a new panel type integrated into the view

Both require forking.

### Wall 3: No Dynamic Split Management

**Problem:** Splits are created during `Layout:create()` and never changed.

```lua
-- Layout.create_wins creates windows once
Layout.create_wins = async.void(function(self, pivot, win_specs, win_order)
  -- Creates windows and closes the pivot
  -- No API for "add a new window to this layout"
end)
```

There's no:
- `Layout:add_window(sym, cmd)` — add a window dynamically
- `Layout:get_window(sym)` — query existing windows
- `Layout:reflow()` — recalculate layout after changes

**Implication:** You can't open a graph split via a keymap inside diffview and have it participate in the layout. The split would be **outside** the managed layout, making focus management and state sync fragile.

### Wall 4: Buffers Are Owned

**Problem:** Every buffer in the layout is owned and managed by the view.

```lua
function Layout:destroy()
  for _, win in ipairs(self.windows) do
    win:destroy()  -- Closes buffers, triggers cleanup
  end
end

function View:close()
  -- ...
  self.layout:destroy()
end
```

If you create a gitgraph buffer/window outside this system, you'd need to:
- Manually sync it with view open/close
- Manage its keymaps separately
- Ensure cleanup on view destruction

**Implication:** A graph panel created via hooks would be a **second-class citizen**, not managed by diffview's lifecycle system.

## The Extensibility Boundary

### What Diffview Supports Well

✅ **Custom rendering within existing panels** (via hooks + buffer manipulation)
✅ **Custom keymaps** (view context available in hooks)
✅ **Reactions to view events** (view_opened, file_open_post, etc.)
✅ **Reading view state** (current entry, file list, etc.)

### What Diffview Does NOT Support

❌ **Dynamic splits** (adding/removing windows after view creation)
❌ **Custom panels with state** (new panel types integrated into the view)
❌ **Layout composition** (mixing panels, reordering at runtime)
❌ **Layout extensibility** (hooks for "add a custom window to this layout")

## What Would Unblock Custom Splits

### Minimal API Additions

#### 1. Dynamic Split Registration

```lua
-- Before view creation, register a split type
diffview.register_split("gitgraph", {
  create = function(view, opts) 
    -- Create and return a split object
  end,
  keymaps = function(split)
    -- Define keymaps for this split
  end,
  destroy = function(split)
    -- Cleanup
  end,
})

-- In config
opts.view.default.layout = "diff2_hor"
opts.view.default.splits = { "gitgraph" }  -- Add gitgraph to all layouts
```

#### 2. Dynamic Layout Adjustment

```lua
-- After view opens, add/remove splits
view:add_split("gitgraph", { position = "bottom", height = 16 })
view:remove_split("gitgraph")
view:set_split_height("gitgraph", 20)
```

#### 3. Panel Composition API

```lua
-- Register a custom panel
diffview.register_panel("graph_panel", {
  render = function(view, buf) ... end,
  on_select = function(view, item) ... end,
  keymaps = function(panel) ... end,
})

-- Add to layout
opts.view.default.panels = { "file_panel", "graph_panel" }
```

#### 4. Lifecycle Hooks for Splits

```lua
-- Emit signals when splits change
DiffviewGlobal.emitter:emit("split_added", view, split_name)
DiffviewGlobal.emitter:emit("split_removed", view, split_name)

-- Allow userspace to hook into split lifecycle
opts.hooks = {
  split_added = function(view, split_name, opts_ctx) ... end,
}
```

## Current Workaround: Overlaid Splits (Fragile)

The hooks-based gitgraph integration creates a split **outside** the layout:

```lua
-- In view_opened hook
vim.cmd("botright split")
graph_win = vim.api.nvim_get_current_win()
gitgraph.draw(..., graph_win)
```

**Why it's fragile:**
- Not part of the managed layout
- No integration with view lifecycle (can outlive the view)
- Focus management is manual
- No state sync
- Keymaps must be manually set per buffer

This is why the integration was messy.

## Recommendations

### For Diffview Users Who Want Custom Splits

**Don't.** Until diffview has split extensibility, custom splits are:
- Unmaintainable
- Fragile across view operations
- Poorly integrated with keymaps/state

Use hooks for **side effects only** (logging, status updates), not for **structural changes** (new splits).

### For Diffview Maintainers

If you want to support custom panels/splits, consider:

**Option A: Minimal** (recommended)
- Add `register_split()` API
- Expose `split_added` / `split_removed` hooks to global emitter
- Document the contract (window ID, buffer, keymaps, lifecycle)
- Cost: ~50 lines, backward compatible

**Option B: Full** (comprehensive)
- Dynamic layout adjustment API
- Panel registration system
- Unified lifecycle for panels + splits
- Cost: ~500 lines, significant refactor, but enables "diffview as a framework"

**Option C: Acknowledge it** (honest)
- Document that custom splits aren't supported
- Recommend forking for split-based features
- Focus maintenance on the core diff/merge experience

## Files Referenced

- Layout base class: `lua/diffview/scene/layout.lua`
- Layout examples: `lua/diffview/scene/layouts/diff_2_hor.lua`
- View class: `lua/diffview/scene/view.lua`
- StandardView: `lua/diffview/scene/views/standard/standard_view.lua`
- FilePanel: `lua/diffview/scene/views/diff/file_panel.lua`
