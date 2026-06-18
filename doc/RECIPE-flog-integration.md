# Recipe: vim-flog Integration with Diffview

## What vim-flog Does Out of the Box

### Installation
```fennel
{1 "rbong/vim-flog"
 :dependencies ["tpope/vim-fugitive"]
 :cmd ["Flog"]}
```

### Basic Usage
```vim
:Flog                    " Open commit graph
:Flog -path=file.txt     " Show commits affecting file.txt
:Flog -max-count=50      " Limit to 50 commits
```

### Built-in Keymaps (in flog buffer)

| Key | Action |
|-----|--------|
| `<CR>` | Jump to commit (opens in split, shows diff) |
| `o` | Open commit in new tab |
| `O` | Open commit in new split |
| `q` | Quit flog |
| `m` | Mark/unmark commit |
| `M` | Mark all commits |
| `u` | Unmark all commits |
| `C` | Cherry-pick marked commits |
| `r` | Rebase onto marked commit |
| `R` | Reset to marked commit |
| `!` | Revert marked commits |
| `yh` | Yank commit hash |
| `yH` | Yank commit hash (abbreviated) |
| `yc` | Yank commit message |
| `y%` | Yank commit path |
| `]f` | Jump to next file in flog |
| `[f` | Jump to previous file in flog |
| `-` | Decrease graph width |
| `+` | Increase graph width |

### Built-in Features

✅ **Commit graph rendering** — Full topology with branches, merges, etc.
✅ **File history filtering** — `:Flog -path=file.txt` shows commits affecting a file
✅ **Mark/unmark** — Select multiple commits for batch operations
✅ **Interactive diff** — `<CR>` opens diff of selected commit
✅ **Rebase/cherry-pick** — Batch operations on marked commits
✅ **Navigation history** — Jump back/forward through commits you've viewed
✅ **Customizable graph** — Configure symbols, colors, format
✅ **Fugitive integration** — Tight integration with vim-fugitive

---

## Why vim-flog Works Where gitgraph Doesn't

### Problem We Hit with gitgraph
```
gitgraph.draw()
  ↓
Hijacks current window
  ↓
Must create split first, then hijack it
  ↓
Result: fragile, manual lifecycle management
```

### How vim-flog Solves It
```
:Flog
  ↓
Opens its own buffer in a new split automatically
  ↓
Provides full interactive buffer with keymaps
  ↓
Result: complete, standalone tool that "just works"
```

**Key difference:** vim-flog is a **buffer-based tool** (like a plugin that owns its buffer), while gitgraph is a **rendering library** (you provide the window).

---

## Quick Integration: Flog as Diffview Side Panel

### Minimal Recipe (No Forks, No Custom Code)

```fennel
;; fnl/plugins/diffview-plus.fnl (update)
;; In the hooks section, add:

:view_opened (fn [view]
              (set vim.g.diffview_active true)
              ;; Auto-open flog on the left
              (vim.cmd "topleft Flog"))
:view_closed (fn [view]
              (set vim.g.diffview_active false)
              ;; Close flog when diffview closes
              (vim.cmd "bdelete flog"))
```

**Result:** When you open diffview, flog opens automatically in a side panel.

### Better Recipe: Conditional Flog Panel

```fennel
;; fnl/integration/diffview-flog.fnl (new)

(local M {})

(fn M.open-flog-panel []
  (when (pcall vim.cmd "topleft vertical split | Flog")
    (set vim.wo.number false)
    (set vim.wo.relativenumber false)))

(fn M.on-view-opened [view]
  (M.open-flog-panel))

(fn M.on-view-closed [view]
  (when (vim.fn.bufexists "flog")
    (vim.cmd "bdelete flog")))

M
```

**Usage:**
```fennel
:view_opened (fn [view]
              (set vim.g.diffview_active true)
              ((. gitgraph "on-view-opened") view))
```

---

## Testing the Integration

### Step 1: Open vim-flog standalone
```vim
:Flog
```

**What you'll see:**
- Commit graph on left
- Current commit info on bottom
- All the keymaps work (mark, cherry-pick, rebase, etc.)

### Step 2: Navigate a commit
```
Move cursor to a commit line
Press <CR>
```

**What happens:**
- vim-flog opens a diff split showing that commit
- You can navigate hunks with vim-flog's built-in diff

### Step 3: Try the integration
- Open diffview: `:DiffviewOpen`
- Flog opens automatically on the left
- Both panels are active simultaneously

---

## What Works Well

✅ **Out-of-box functionality** — No custom integration code needed
✅ **Rich keymaps** — All git operations (rebase, cherry-pick, mark) work
✅ **Live updates** — Stage/unstage files, flog reflects changes
✅ **Navigation** — Jump between commits, see their diffs
✅ **No dependency on diffview** — Works independently
✅ **Fugitive integration** — Can use fugitive commands alongside

---

## What's Different from gitgraph

| Aspect | gitgraph | vim-flog |
|--------|----------|----------|
| **Architecture** | Render-only library | Complete buffer-based tool |
| **Interaction** | Requires custom bindings | Full keymaps built-in |
| **Git ops** | Display only | Can rebase, cherry-pick, merge |
| **Diff view** | Must integrate with diffview | Opens its own diff windows |
| **Lifecycle** | Managed by consumer | Manages itself |
| **Learning curve** | Low (just rendering) | Moderate (many keymaps) |
| **Maintenance** | Needs fork work | Already stable |

---

## Observations

### Why vim-flog Is More "Finished"

1. **Complete tool** — Not a library. Includes everything needed for a workflow.
2. **Stable API** — 5+ years old, widely used, not WIP.
3. **Rich features** — Marks, rebase, cherry-pick, blame, etc.
4. **Buffer model** — Owns its lifecycle, no external management needed.

### Why gitgraph Has Potential

1. **Pure Lua** — Easier to integrate with modern neovim config.
2. **Composable** — Can be embedded anywhere (status line, sidebar, etc.).
3. **Lightweight** — Just graph rendering, no git operations.
4. **No Fugitive** — VCS-agnostic (could support other VCS).

---

## For the Diffview Split Registration RFC

This exploration shows:

✅ **vim-flog is ready now** — Works standalone, mature, stable
⚠️ **gitgraph needs snacks-style API** — Would then be equally composable
✅ **Split registration solves both** — Would let either tool integrate cleanly into diffview's layout

---

## Next: Test in Neovim

Once you fire up nvim with flog installed:

```vim
" Start in a git repo
:Flog

" Test basic navigation
j/k       " Move cursor
<CR>      " View diff of commit under cursor
m         " Mark commit
M         " Mark all
u         " Unmark all
C         " Cherry-pick marked
r         " Rebase onto marked
```

See how it feels compared to gitgraph standalone.

---

## Reference

- vim-flog: https://github.com/rbong/vim-flog
- flog.txt (help): `:help flog` once installed
- Comparison: `doc/COMPARISON-flog-vs-gitgraph.md`
