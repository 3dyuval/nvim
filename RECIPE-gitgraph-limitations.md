# Recipe: Integrating GitGraph.nvim as a Synced Split Panel

## Goal

Explore the limits of userspace extensibility: can we wire gitgraph.nvim as an interactive side panel synced with diffview using only public APIs?

**Conclusion:** Not fully. The attempt exposed real architectural gaps in both plugins.

## What We Tried

Build a `:DiffviewGraph` integration where:
- A gitgraph panel opens in a bottom split when diffview opens
- Pressing `<CR>` on a commit jumps to that diff in diffview
- Navigating in diffview syncs the graph highlight
- Keymaps work consistently (`q` to quit, prev/next navigation)

All via userspace hooks, no forking.

## The Gaps We Found

### Gap 1: gitgraph.nvim — No Stable Public Core API

**What exists:**
- `gitgraph.draw({}, opts)` — renders to current window, hijacks it
- Internal `gitgraph.core.gitgraph(config, options, args)` — returns raw graph data

**What's missing:**
- **Stable, documented public API for the core data** (we can work around this)
- **Interactive item access model** — no way to query "which commit is on line N?" without parsing rendered output
- **Keymap hooks** — no way to bind `<CR>` to "open selected commit" cleanly

**Why it matters:**
`gitgraph.draw()` expects to own the current window. Working around this by:
1. Creating a split
2. Calling `draw()` with that window focused
3. Restoring focus

...works, but leaves gitgraph stateless from our perspective. When user presses `<CR>` on a commit line, we have:
- A buffer with rendered text
- No structured access to commit objects
- Must regex-parse the line to extract a commit hash (brittle, fragile)

**Ideal solution:**
gitgraph exposes a snacks-like API:
```lua
-- Instead of just draw()
local graph = gitgraph.create_interactive_list(config, opts)
graph.on_select(function(commit) ... end)
graph.render(buf)
```

### Gap 2: diffview-plus.nvim — Doesn't Expose Critical Hooks

**What exists:**
- `view_opened` hook (fires when a view opens)
- `file_open_post` hook (fires internally when navigating commits)
- User can access `view.emitter` (semi-private) from within `view_opened`

**What's missing:**
- `view_opened` hook **does not pass keymaps context**
  - Can't read what keybind means "prev hunk" in this config
  - Must hardcode `A`/`E` or ask user for config
  
- `file_open_post` hook **not emitted to global emitter**
  - Only fires on per-view `view.emitter`, not global
  - Userspace hooks can't listen for navigation events
  - Graph panel has no signal to "re-render for this new commit"

**Why it matters:**
Diffview's architecture has these signals _internally_, but doesn't expose them as public contracts. You hit the "view navigation wall":

| Signal | Public? | Accessible Via |
|--------|---------|-----------------|
| view opened/closed | ✅ Yes | `opts.hooks.view_opened/closed` |
| panel multi-select changed | ✅ Yes | `opts.hooks.selection_changed` |
| **commit/file navigation** | ❌ No | Only `view.emitter:on("file_open_post")` (semi-private) |
| keymaps context | ❌ No | Only via `config.keymaps` (not passed to hooks) |

**Ideal solution:**
Emit two small signals to the global emitter:

```lua
-- In diffview/scene/views/standard/standard_view.lua, when navigating:
self.emitter:emit("file_open_post", target, cur_entry)
-- ADD THIS:
DiffviewGlobal.emitter:emit("file_open_post", target, cur_entry, {
  keymaps = config.get_config().keymaps.view
})

-- In diffview/scene/view.lua, when opening:
DiffviewGlobal.emitter:emit("view_opened", self)
-- CHANGE TO:
DiffviewGlobal.emitter:emit("view_opened", self, {
  keymaps = config.get_config().keymaps.view
})
```

This is ~10 lines of code, zero architectural change, fully backward compatible.

## What We Learned

### The Hard Wall

Diffview's **view/entry model** and **navigation loop** are tightly coupled to the feature set. These aren't bugs or oversights—they're core design:

- Views own their layout, their window set, their entry model
- Navigation funnels through `StandardView:_set_file()`, triggering internal signals
- Keymaps are resolved once at startup, bound to specific view contexts
- Entry lifecycle (open, select, stage, diff) is private state

You **cannot build a first-class interactive feature** (like a graph panel) entirely from outside this loop. At some point you need:
1. **Access to the data model** (which commit are we showing?)
2. **Navigation signals** (when does the user navigate?)
3. **Keymaps context** (what does `q` mean in this view?)

### The Extensibility Boundary

Public hooks work great for:
- Reacting to view open/close events ✅
- Observing multi-select changes ✅
- Side effects (logging, telemetry) ✅

Public hooks **cannot** support:
- Building an interactive sub-view synced with navigation ❌
- Contextual keybinds that mirror diffview's config ❌
- Custom rendering that reads structured data ❌

These require exposing signals and data from the view loop itself.

## Recommendation

This isn't a "we need more time" problem—it's a **design boundary**.

Two possible paths:

### Option A: Expose Minimal Public Hooks (Recommended for extensibility)

Add two small, stable signals to the global emitter:

```lua
-- Signal 1: Navigation
DiffviewGlobal.emitter:emit("file_open_post", target, cur_entry, keymaps_context)

-- Signal 2: View context
DiffviewGlobal.emitter:emit("view_opened", view, keymaps_context)
```

**Cost:** ~10 lines, zero breaking changes, fully backward compatible
**Benefit:** Unblocks userspace recipes for graph panels, status displays, custom syncing
**Maintenance:** Stable contract—these signals are already internal; just making them public

### Option B: Accept Tight Coupling (Current reality)

Acknowledge that features requiring view integration (graph panels, commit inspection UI, etc.) need to be:
- Inside diffview itself, OR
- Require forking diffview (maintenance burden)

There is no clean middle ground without Option A.

## Files Referenced

- Integration code: `/home/yuv/.config/nvim/fnl/integration/gitgraph-diffview.fnl`
- Fork attempt docs: `/home/yuv/proj/diffview.nvim/RECIPE-gitgraph-integration-ideal.md`
- This recipe: `/home/yuv/.config/nvim/RECIPE-gitgraph-limitations.md`
