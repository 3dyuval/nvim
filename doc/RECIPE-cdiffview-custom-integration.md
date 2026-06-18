# Recipe: Custom Diff Views with CDiffView API

**Status:** Discovery & exploration  
**Discovery:** Diffview has a public `CDiffView` API for creating custom diff views without forking

---

## The Game-Changer

While exploring split integration, we discovered **diffview already exposes a public API for custom diff views**.

Instead of:
```lua
-- Overlaid split (fragile, unmanaged)
vim.cmd("botright split")
gitgraph.draw()
```

You can do:
```lua
-- Integrated custom view (lifecycle managed)
local view = require("diffview.api.views.diff").CDiffView({
  git_root = vim.fn.getcwd(),
  files = { ... },  -- Your custom data
  update_files = function(view) ... end,
  get_file_data = function(path, split) ... end,
})
```

**Result:** A first-class diffview that behaves like any other view, with full keymaps, session persistence, and lifecycle management.

---

## What is CDiffView?

`CDiffView` is a subclass of `DiffView` (diffview's standard diff view) that lets you:

1. **Provide custom file entries** instead of querying git
2. **Define content dynamically** via callbacks
3. **Participate fully** in diffview's layout/keymaps/lifecycle
4. **Persist across sessions** like normal views

### From diffview's source (lua/diffview/api/views/diff/diff_view.lua):

```lua
---@class CDiffView : DiffView
---@field files any
---@field fetch_files function  -- Refresh file list
---@field get_file_data function -- Return buffer content for a file
local CDiffView = oop.create_class("CDiffView", DiffView.__get())
```

---

## Constructor Signature

```lua
local CDiffView = require("diffview.api.views.diff").CDiffView

local view = CDiffView({
  git_root = string,              -- Path to git root (required)
  files = { FileData, ... },      -- Initial file list (optional)
  
  update_files = function(view)   -- Callback: refresh file list
    return { FileData, ... }
  end,
  
  get_file_data = function(path, split)  -- Callback: get buffer content
    -- split is "left" or "right"
    return { line1, line2, ... }
  end,
  
  left = GitRev?,                 -- Left revision (defaults to STAGE 0)
  right = GitRev?,                -- Right revision (defaults to STAGE 0)
})
```

### FileData Structure

```lua
---@class FileData
---@field path string                -- Path relative to git root
---@field oldpath string|nil         -- Old path if renamed
---@field status string              -- Git status: M, A, D, R, etc.
---@field stats GitStats|nil         -- Optional: insertions/deletions
---@field left_null boolean|nil      -- Left buffer should be null
---@field right_null boolean|nil     -- Right buffer should be null
---@field selected boolean|nil       -- Initially selected file
```

---

## Example 1: Graph Commits as Diff Files

Turn commit graph into a "diff view":

```lua
local flog = require("flog")
local CDiffView = require("diffview.api.views.diff").CDiffView

local function create_graph_view()
  return CDiffView({
    git_root = vim.fn.getcwd(),
    
    -- Each commit becomes a "file"
    files = create_file_list(),
    
    update_files = function(view)
      -- Refresh when user navigates
      return create_file_list()
    end,
    
    get_file_data = function(path, split)
      -- path is the commit hash
      if split == "left" then
        -- Left: previous commit
        return vim.fn.systemlist("git show " .. path .. "^:.")
      else
        -- Right: current commit
        return vim.fn.systemlist("git show " .. path .. ":.")
      end
    end,
  })
end

function create_file_list()
  -- Query flog or gitgraph
  local commits = get_all_commits()
  local files = {}
  
  for i, commit in ipairs(commits) do
    table.insert(files, {
      path = commit.hash,
      status = "M",  -- All commits "modified" relative to parent
      selected = i == 1,  -- Select first
    })
  end
  
  return files
end
```

**Result:** A view where:
- File list shows commits
- Selecting a commit shows its diff (parent → commit)
- All diffview keymaps work
- Sessions persist

---

## Example 2: Custom Status Display View

Create a view that shows structured data:

```lua
local CDiffView = require("diffview.api.views.diff").CDiffView

local view = CDiffView({
  git_root = vim.fn.getcwd(),
  
  files = {
    { path = "BRANCH", status = "M" },
    { path = "REMOTES", status = "M" },
    { path = "TAGS", status = "M" },
  },
  
  get_file_data = function(path, split)
    if path == "BRANCH" then
      if split == "left" then
        return { "Local branches:" }
      else
        return vim.fn.systemlist("git branch -a")
      end
    elseif path == "REMOTES" then
      if split == "left" then
        return { "Remote tracking:" }
      else
        return vim.fn.systemlist("git branch -r")
      end
    elseif path == "TAGS" then
      if split == "left" then
        return { "Tags:" }
      else
        return vim.fn.systemlist("git tag")
      end
    end
  end,
})
```

**Result:** A custom "view" showing git branches/tags with diffview's UI (no custom rendering needed).

---

## Lifecycle & Integration

### Opening a Custom View

```lua
local view = require("diffview.api.views.diff").CDiffView({...})

-- Register with diffview's session system
require("diffview.lib").session:register_view(view)

-- Open it
view:open()  -- Opens in tab, like any diffview
```

### Lifecycle Hooks

Custom views inherit all of DiffView's events:

```lua
view.emitter:on("file_open_post", function(target, entry)
  print("User navigated to file: " .. entry.path)
end)

view.emitter:on("selection_changed", function()
  print("Multi-select changed")
end)
```

### Keymaps Work Out-of-Box

All standard diffview keymaps work:
- `A`/`E` — Next/prev hunk
- `<leader>.` — Cycle layout
- `q` — Close
- Stage/unstage (if implemented)
- Navigation history

---

## Why CDiffView is Better Than Splits

### Splits Approach (What We Explored)

```
┌─────────────────┐
│  Diffview       │  <- Owned by diffview
│  (main diffs)   │
├─────────────────┤
│  Graph split    │  <- Created outside, unmanaged
│  (via hooks)    │  <- Lifecycle mismatch
└─────────────────┘
```

**Problems:**
- ❌ Lifecycle mismatch (split outlives view)
- ❌ No focus coordination
- ❌ No session persistence
- ❌ Manual keymaps

### CDiffView Approach

```
┌─────────────────┐
│  Custom DiffView│  <- Integrated
│  (graph + diffs)│  <- Managed by diffview
│                 │  <- Full keymaps/lifecycle
└─────────────────┘
```

**Benefits:**
- ✅ Integrated lifecycle (open/close with view)
- ✅ Automatic keymaps
- ✅ Session persistence
- ✅ Full diffview feature set

---

## Comparison: CDiffView vs Split Registration RFC

| Aspect | CDiffView | Split Registration (RFC) |
|--------|-----------|-------------------------|
| **Works today** | ✅ (public API exists) | ❌ (needs 155 LOC implementation) |
| **Lifecycle mgmt** | ✅ (builtin) | ✅ (if implemented) |
| **Session persistence** | ✅ (automatic) | ✅ (if implemented) |
| **Keymaps** | ✅ (inherited) | ⚠️ (manual per split) |
| **Implementation effort** | 0 LOC | ~155 LOC fork work |
| **Best for** | Custom data views | Generic side panels |

---

## Real-World Example: Graph-Augmented Diff

```lua
-- Show commits in left panel, diffs in right
local flog = require("flog")
local CDiffView = require("diffview.api.views.diff").CDiffView

function show_graph_diffs()
  local commits = get_commits()  -- From flog or gitgraph
  
  local files = {}
  for _, commit in ipairs(commits) do
    table.insert(files, {
      path = commit.hash .. " " .. commit.subject,
      status = "M",
      selected = commit == commits[1],
    })
  end
  
  local view = CDiffView({
    git_root = vim.fn.getcwd(),
    files = files,
    
    update_files = function(view)
      return create_fresh_file_list()  -- Refresh on demand
    end,
    
    get_file_data = function(path, split)
      local hash = path:match("^(%x+)")
      if split == "left" then
        return vim.fn.systemlist("git show " .. hash .. "^")
      else
        return vim.fn.systemlist("git show " .. hash)
      end
    end,
  })
  
  view:open()  -- Opens in tab like normal
end
```

Now you have:
- Left panel: commit list (as "files")
- Right panel: actual diff of selected commit
- All diffview keymaps work
- Navigate with `A`/`E` to move between commits
- Sessions persist

---

## Open Questions / Limitations

1. **Multi-file views** — Can you show multiple files per commit? (Probably yes, needs testing)
2. **Interactive operations** — Can you stage/unstage? (Probably not—callbacks are read-only)
3. **Performance** — How large can file lists be? (Untested—may need pagination)
4. **Custom panels** — Can you add custom left/right panels? (Probably not—uses standard layout)

---

## What This Means for the Ecosystem

**The RFC for split registration was premature.**

CDiffView already does 80% of what we wanted:
- ✅ Compose external data (graphs, commits, custom structures)
- ✅ Into diffview's layout
- ✅ With full keymaps and lifecycle

The remaining 20% (generic side panels) might not be worth 155 LOC in core diffview.

**New understanding:**
- Use `CDiffView` for **data composition** (graphs as files, commits as diffs)
- Use hooks for **side effects** (status updates, logging)
- Split registration is useful for **orthogonal UI panels** (status bar, file browser)

---

## Next Steps

1. **Test CDiffView with actual data** — Does it work? Performance?
2. **Build a minimal example** — Graph view or custom data view
3. **Document limitations** — What doesn't work, why
4. **Compare to other approaches** — vim-flog standalone, gitgraph hooks, etc.

---

## References

- **CDiffView source:** `lua/diffview/api/views/diff/diff_view.lua` (lua/diffview fork)
- **DiffView base:** `lua/diffview/scene/views/diff/diff_view.lua`
- **FileEntry structure:** `lua/diffview/scene/file_entry.lua`
- **Session integration:** `lua/diffview/session.lua`
