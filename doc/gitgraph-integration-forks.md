# GitGraph + Diffview Integration: Fork State & Actions

## Goal

Document the minimal changes needed in both forks to enable userspace gitgraph integration recipes, and track what's been done vs. what remains.

## Fork Status

### gitgraph.nvim Fork

**Location:** `~/proj/gitgraph.nvim`
**Branch:** `feat/stable-render-api`
**Upstream:** `isakbm/gitgraph.nvim`

| Status | File | Change | Rationale |
|--------|------|--------|-----------|
| ✅ Done | `lua/gitgraph/core.lua` | Added `render_data()` function returning `{lines, highlights, head_commit}` | Exposes stable API for custom rendering without hijacking the window |
| ⚠️ Gap | — | No public hook API for item selection/keymaps | Users can't bind `<CR>` to "open commit" without parsing rendered output |
| ⚠️ Gap | `lua/gitgraph.lua` | `render_data()` not exported from main module | Users must `require("gitgraph.core")` directly; should be `gitgraph.render_data()` |

**What's Working:**
- Core render data is stable and documented
- Can fetch raw graph, lines, highlights

**What's Broken:**
- No way to query "what commit is on line N?" from outside
- No keymap hooks or interactive callbacks

---

### diffview-plus.nvim Fork

**Location:** `~/proj/diffview.nvim`
**Branch:** `feat/expose-keymaps-in-hooks` 
**Upstream:** `dlyongemallo/diffview-plus.nvim`

| Status | File | Change | Rationale |
|--------|------|--------|-----------|
| ✅ Done | `lua/diffview/scene/view.lua` | `view_opened` hook now passes `keymaps_context` with resolved keymaps | Allows recipes to read `q`, prev/next keybinds instead of hardcoding |
| ✅ Done | `lua/diffview/scene/views/standard/standard_view.lua` | `file_open_post` emitted to global emitter with `keymaps_context` | Enables graph panel to sync when diffview navigates commits |
| ⚠️ Gap | — | No hook for dynamic split management (add/remove splits at runtime) | Graph panel must be created outside the layout (fragile, unmanaged) |
| ⚠️ Gap | — | No panel registration API for custom panels | Can't integrate gitgraph as a first-class panel in the view lifecycle |

**What's Working:**
- Hooks fire to global emitter
- Keymaps context is available
- Can listen for navigation events

**What's Broken:**
- Can't manage splits dynamically
- Graph panel can't participate in view lifecycle
- Focus management is manual

---

## Integration Status

**Location:** `~/.config/nvim/fnl/integration/gitgraph-diffview.fnl`
**Branch:** `main` (uncommitted changes on feat/gitgraph-diffview-hooks)

| Status | Function | What It Does | Issue |
|--------|----------|--------------|-------|
| ✅ Done | `open-graph` | Creates split, renders gitgraph data, stores in `graph-data` | Window created outside managed layout; fragile |
| ✅ Done | `close-graph` | Closes window cleanly | Doesn't integrate with view lifecycle |
| ✅ Done | `setup-graph-keymaps` | Binds `q` and `<CR>` to graph buffer | Can't read keymaps from `keymaps_context` (not passed to hook yet) |
| ❌ Broken | `open-commit-in-diffview` | Should extract commit hash and open in diffview | Regex parsing is brittle; uses line text instead of stored graph data |
| ⚠️ Missing | `on-navigate` | Should sync graph when diffview navigates | Not implemented; would require `file_open_post` hook in config |

---

## Action Items

### gitgraph.nvim Fork

| | Action | Why | Status |
|---|--------|-----|--------|
| [ ] | Export `render_data()` from main `gitgraph.lua` module | Users should call `gitgraph.render_data()`, not `gitgraph.core.render_data()` | Blocked |
| [ ] | Document `render_data()` as stable public API | Make the contract explicit (inputs, outputs, guarantees) | Blocked |
| [ ] | Add optional `on_select` callback support | Let userspace bind `<CR>` to `render_data()` result items instead of parsing | Blocked |
| [ ] | Expose item-by-line-index query (`get_commit_at_line()`) | Recipes can query "what commit is on line N?" without parsing | Blocked |

### diffview-plus.nvim Fork

| | Action | Why | Status |
|---|--------|-----|--------|
| [x] | Emit `view_opened` with `keymaps_context` | Allow recipes to read configured keybinds | Done |
| [x] | Emit `file_open_post` to global emitter | Enable graph panel to listen for navigation | Done |
| [ ] | Document these as stable hooks | Signal that recipes can depend on them | Blocked |
| [ ] | Add `split_added` / `split_removed` hooks | Let userspace react to dynamic split changes | Blocked |
| [ ] | Expose `Layout:add_window()` / `Layout:remove_window()` API | Enable dynamic split management within the managed layout | Blocked |

### nvim Config Integration

| | Action | Why | Status |
|---|--------|-----|--------|
| [x] | Store `graph-data` from `render_data()` | Use structured data instead of regex parsing | Done |
| [ ] | Implement `on-navigate()` hook | Sync graph when diffview navigates commits | Blocked |
| [ ] | Update `open-commit-in-diffview` to use graph-data | Extract commit hash from stored data, not line text | Blocked |
| [ ] | Wire `file_open_post` hook in diffview config | Connect navigation events to graph re-render | Blocked |
| [ ] | Read keymaps from `keymaps_context` in hook | Use diffview's config instead of hardcoding A/E for prev/next | Blocked |

---

## Known Gaps

### Architectural (Can't Fix Without Fork Changes)

1. **Dynamic split management** — Diffview's layouts are rigid; can't add/remove windows after view creation
2. **Panel lifecycle integration** — Custom panels can't participate in the view's state machine
3. **gitgraph item access** — No stable query API for "what item is on line N?"

### Implementation (Can Fix With Work)

1. **Fragile commit lookup** — Currently regex-parsing rendered output; should use stored graph data
2. **No navigation sync** — Graph doesn't update when diffview navigates
3. **Manual keymaps** — Can't read from `keymaps_context` yet (hook passes it, but integration doesn't consume it)

---

## References

- **Limitations analysis:** `RECIPE-gitgraph-limitations.md`
- **Split extensibility analysis:** `RECIPE-diffview-splits-extensibility.md`
- **Fork changes:** 
  - gitgraph: `git diff upstream/main`
  - diffview: `git diff upstream/main`
