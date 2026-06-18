# Insight: Split Registration as Composition Pattern

## The Realization

By exposing split registration, diffview becomes **composable** in ways that go far beyond "add a graph panel."

**Split registration** = diffview + any external tool can work together seamlessly.

---

## What This Unlocks

### 1. Snacks + Diffview Composition

```lua
-- Snacks already has a picker/list API
-- What if we could embed snacks lists IN diffview?

diffview.register_split_kind("file_search", {
  create = function(view, config)
    local picker = require("snacks.picker").open({
      source = "files",
      on_select = function(item)
        -- Open file in diffview
        vim.cmd("DiffviewOpen " .. item.path)
      end,
    })
    
    return {
      buf = picker.buf,
      win = picker.win,
    }
  end,
})

-- Now snacks' picker is part of the diffview layout!
opts.view.default.splits.kinds = { "file_search" }
```

**What this means:**
- Snacks doesn't need to know about diffview
- Diffview doesn't need to know about snacks
- They compose via the split registration contract

### 2. Telescope + Diffview

```lua
diffview.register_split_kind("telescope_files", {
  create = function(view, config)
    -- Embed telescope in a split
    require("telescope.builtin").find_files({
      layout_strategy = "horizontal",
      layout_config = { width = config.width or 0.5 },
    })
    
    return {
      buf = vim.api.nvim_get_current_buf(),
      win = vim.api.nvim_get_current_win(),
    }
  end,
})
```

### 3. Custom Status Panels

```lua
diffview.register_split_kind("git_status", {
  create = function(view, config)
    local buf = vim.api.nvim_create_buf(false, true)
    
    -- Live update of git status in the split
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
      "Repository: " .. vim.fn.getcwd(),
      "Branch: " .. get_current_branch(),
      "Dirty: " .. (is_dirty() and "Yes" or "No"),
    })
    
    return {
      buf = buf,
      win = ...,
      on_close = ...,
    }
  end,
})
```

### 4. Multi-Tool Workflows

One view, multiple tools:

```lua
opts.view.default.splits = {
  kinds = { "flog", "file_search", "git_status" },
  config = {
    flog = { position = "left", width = 40 },
    file_search = { position = "bottom", height = 10 },
    git_status = { position = "right", width = 20 },
  },
}
```

**Result:** A unified workspace where diffview orchestrates multiple external tools.

---

## Why This Matters: The Composition Model

### Before Split Registration

```
User config
    ↓
┌───────────────────────────────────────┐
│ Diffview (monolithic)                 │
│  - layouts                            │
│  - file panel                         │
│  - options panel                      │
│  - (hardcoded panels only)            │
└───────────────────────────────────────┘
    ↓
Vim windows
```

**Problem:** To add custom panels, you fork diffview or use fragile hooks.

### After Split Registration

```
User config
    ↓
┌───────────────────────────────┐
│ Diffview (with split API)     │
│  - layouts                    │
│  - file panel                 │
│  - split registration         │  ← NEW: just a registry
└───────────────────────────────┘
    ↓
    ├── split_registry.get("flog")  ───────┐
    │                                       │
    ├── split_registry.get("files") ────┐  │
    │                                   │  │
    └── split_registry.get("status")  ──┐ │
                                        │ │ │
                                        ↓ ↓ ↓
                                    External tools
                                    (flog, snacks,
                                     telescope,
                                     custom code)
```

**Benefit:** Diffview becomes a **composition layer**. Any tool can register a split, tools stay independent.

---

## Real-World Example: The Dream Workflow

```lua
-- User's config combines everything

require("diffview").setup({
  view = {
    default = {
      layout = "diff2_horizontal",
      splits = {
        kinds = {
          "flog",          -- Commit history
          "file_search",   -- Find changed files
          "status",        -- Git status
        },
        config = {
          flog = { position = "left", width = 30 },
          file_search = { position = "bottom", height = 12 },
          status = { position = "right", width = 25 },
        },
      },
    },
  },
})

-- Each "split" is registered by its plugin:
require("diffview").register_split_kind("flog", flog_split_spec)
require("diffview").register_split_kind("file_search", snacks_picker_spec)
require("diffview").register_split_kind("status", custom_status_spec)
```

**User now has:**
- Diff view (center)
- Commit graph (left) — from vim-flog
- File picker (bottom) — from snacks
- Status info (right) — custom

**All coordinated:**
- Open/close together
- Session persists
- Focus navigation unified
- Keymaps integrated
- Window management handled

**Zero integration code needed.** Each tool just registers itself once.

---

## The Snacks Angle (From Your Comment)

You said: "it even means snacks could potentially use diffs everywhere"

**The reverse is true too:**

Snacks + any diff-enabled plugin = integrated workflows.

```lua
-- Snacks picker with diffview integration
local picker = require("snacks.picker").open({
  source = "git_files",
  preview = function(item)
    -- Preview diffs in diffview!
    vim.cmd("DiffviewOpen -- " .. item.path)
  end,
  on_select = function(item)
    vim.cmd("DiffviewOpen -- " .. item.path)
  end,
})
```

But with split registration, it goes further:

```lua
-- Snacks doesn't need special diffview code
-- Diffview doesn't need special snacks code
-- User wires them together in config:

register_split("snacks_picker", {
  create = function(view, config)
    local picker = require("snacks.picker").open({...})
    return { buf = picker.buf, win = picker.win }
  end,
})

opts.view.default.splits.kinds = { "snacks_picker" }
```

**Result:** Snacks picker becomes a native part of diffview. No special integration code needed.

---

## Architectural Elegance

### The Unix Philosophy Applied

```
Each tool does one thing well:
  - vim-flog: render commit graph
  - snacks: provide interactive list
  - diffview: manage windows and layout
  - teliscope: file finder

They don't know about each other.
They compose via contracts (split registration).
```

### Why This Is Better Than Monolithic Integration

| Monolithic | Split Registration |
|------------|-------------------|
| Diffview owns all panels | Plugins own their panels |
| Tight coupling | Loose coupling |
| Hard to extend | Easy to extend |
| One codebase | Multiple independent tools |
| Maintenance burden | Distributed ownership |

---

## Future Possibilities

Once split registration exists:

### 1. Split Marketplace

Community creates split specs that work with diffview:
- `flog-split` — vim-flog integration
- `snacks-files-split` — file picker
- `telescope-split` — telescope integration
- `git-blame-split` — blame info
- `lsp-symbols-split` — symbol browser
- `test-runner-split` — test results
- Custom splits for any use case

### 2. Diffview + X Workflows

```lua
-- Every tool becomes "diffview-aware" without special code
diffview + flog       -- Commit graph
diffview + snacks     -- File picker
diffview + telescope  -- Smart search
diffview + toggleterm -- Terminal in diff
diffview + gitsigns   -- Hunk preview
```

### 3. Layout Presets

```lua
-- Community-created layouts
configs = {
  minimal = { splits.kinds = {} },
  standard = { splits.kinds = { "flog" } },
  advanced = { splits.kinds = { "flog", "file_search", "status" } },
  terminal = { splits.kinds = { "flog", "terminal" } },
}
```

---

## Why This Matters for The Ecosystem

**Current state:**
- Diffview is a diff viewer
- vim-flog is a commit graph viewer
- Snacks is a picker/list library
- They exist in isolation

**With split registration:**
- Diffview becomes a **composition platform**
- Tools integrate without coupling
- Users get seamless workflows
- Ecosystem becomes more interconnected

**This is how neovim plugins scale.**

---

## Implementation Consequence

The RFC's 155 LOC isn't just "adding a graph panel."

It's enabling:
- ✅ Reusable composition contracts
- ✅ Ecosystem integration
- ✅ Decoupled tool development
- ✅ User-defined workflows
- ✅ Future extensibility

One small API, massive composability unlock.

---

## Related Documents

- `RFC-diffview-split-registration.md` — The technical proposal
- `BLOCKER-diffview-split-lifecycle.md` — Why this is needed
- `COMPARISON-flog-vs-gitgraph.md` — Original use case
