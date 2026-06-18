# Comparison: vim-flog vs gitgraph.nvim for Diffview Integration

## Executive Summary

| Aspect | vim-flog | gitgraph.nvim |
|--------|----------|---------------|
| **API Stability** | ✅ Stable, documented | ⚠️ Internal, needs fork |
| **Commit Lookup** | ✅ Built-in (line_commits[]) | ❌ Need regex parsing |
| **Pure Lua** | ❌ Vimscript + Lua | ✅ Pure Lua |
| **Fugitive Dependency** | ✅ Unified (VCS agnostic? No) | ❌ Zero VCS dependencies |
| **Panel Integration** | ⚠️ Standalone buffer model | ✅ Render-only, composable |
| **Fork Required** | ❌ Already stable | ✅ Need render_data() API |
| **Maturity** | ✅ 5+ years, battle-tested | ⚠️ Active but WIP |
| **Code Cleanliness** | ⚠️ Legacy optimizations | ✅ Modern, focused |

---

## vim-flog: The Stable Option

### What Works Now (No Fork Needed)

```lua
-- vim-flog's public API (from flog.txt:1213-1260)
local state = b:flog_state  -- buffer-local state object
state.line_commits          -- Maps line number → commit data
state.commits              -- All commits in buffer

-- Query what commit is on line N
local commit_on_line_5 = state.line_commits[5]
if commit_on_line_5 then
  print(commit_on_line_5.hash)  -- ✅ Works!
end

-- Format commit with placeholders
local formatted = flog#Format("%h %s", commit)  -- ✅ Stable function
```

### The Binding Mechanism

vim-flog uses **buffer-local autocommands and mappings**:

```lua
-- vim-flog's approach (autoload/flog/floggraph.vim:331-420)
nnoremap <buffer> <CR> :call flog#CommitJump()<CR>
nnoremap <buffer> q    :bdelete<CR>

-- These are always available in the flog buffer
-- No manual setup needed
```

### Built-in Features

✅ Commit jump history (back/forward)
✅ Mark/unmark commits
✅ Diff integration with Fugitive
✅ Merge/rebase operations
✅ Tag/branch creation
✅ Context menus

---

## gitgraph.nvim: The Clean Option

### What Needs Work (Requires Fork)

```lua
-- Current gap: no public commit lookup API
local graph = gitgraph.core.gitgraph(config, {}, args)
-- Returns raw graph data, but no "line N → commit" mapping

-- Current workaround: regex parsing (fragile)
local line = vim.api.nvim_get_current_line()
local hash = line:match("(%x%x%x%x%x%x%x)")  -- ❌ Brittle!
```

### The Missing API

```lua
-- What we proposed in PROPOSAL-gitgraph-snacks-api.md
local graph = gitgraph.open({
  on_select = function(commit)
    vim.cmd("DiffviewOpen " .. commit.hash .. "^!")
  end,
})

-- But this requires:
-- 1. Adding render_data() as public API
-- 2. Creating interactive wrapper (M.new, callbacks, events)
-- 3. Exposing item-by-line lookup
-- = ~200 LOC new code in gitgraph fork
```

---

## Minimal Recipe: Using vim-flog

### Setup

```lua
-- fnl/integration/diffview-flog.fnl
(local M {})

(fn M.open-flog []
  (let [ok (pcall vim.cmd "Flog")]
    (when ok
      (M.setup-keymaps))))

(fn M.setup-keymaps []
  ;; Override flog's <CR> to open in diffview
  (vim.keymap.set :n :<CR>
    (fn []
      (let [state vim.b.flog_state]
        (when state
          (let [line (vim.fn.line ".")
                commit (. state.line_commits line)]
            (when (and commit commit.hash)
              (vim.cmd (.. "DiffviewOpen " commit.hash "^!")))))))
    {:buffer true :noremap true}))

(fn M.on-view-opened [view]
  (M.open-flog))

(fn M.setup []
  M)

M
```

### Minimal Config

```fennel
{1 "rbong/vim-flog"
 :dependencies ["tpope/vim-fugitive"]
 :lazy true
 :cmd ["Flog"]
 :keys [["<leader>gl" ":Flog<CR>" :desc "Open flog"]]
 :config (fn []
           (let [flog (require :integration.diffview-flog)]
             ;; Optional: auto-open flog with diffview
             ;; (require :diffview).on(:view_opened, flog.on-view-opened)
             ))}
```

### Advantages Over gitgraph

✅ **Works immediately** — No fork, no fork changes
✅ **Reliable commit lookup** — `state.line_commits[line]` is documented API
✅ **Rich integration** — All vim-flog commands (marks, diffs, etc.) work
✅ **No regex parsing** — No brittle line-text extraction

---

## Minimal Recipe: Using gitgraph.nvim (Proposed)

### Prerequisites (Fork Work)

Implement the snacks-style API from PROPOSAL-gitgraph-snacks-api.md:

```lua
-- In gitgraph fork: lua/gitgraph/interactive.lua
local graph = gitgraph.open({
  on_select = function(commit) ... end,
  keymaps = { select = "<CR>" },
})
graph:render(buf)
```

### Setup

```lua
-- fnl/integration/diffview-gitgraph.fnl
(local M {})

(fn M.open-graph []
  (let [(ok gitgraph) (pcall require :gitgraph)]
    (when ok
      (let [graph (gitgraph.open
                    {:config gitgraph.config
                     :args {:all true :max_count 256}
                     :on_select (fn [commit]
                                  (vim.cmd (.. "DiffviewOpen " commit.hash "^!")))
                     :keymaps {:select "<CR>" :close "q"}})]
        (vim.cmd "botright split")
        (let [buf (vim.api.nvim_create_buf false true)]
          (graph:render buf))))))

(fn M.setup []
  M)

M
```

### Advantages Over vim-flog

✅ **Pure Lua** — No Vimscript, consistent with Neovim ecosystem
✅ **Flexible rendering** — Can render anywhere, not buffer-bound
✅ **Composable** — Can use in other plugins (status line, sidebar)
✅ **No Fugitive dependency** — VCS-agnostic, works with git-only setups
✅ **Modern codebase** — No legacy optimizations, easier to maintain

---

## Decision Matrix

**Choose vim-flog if:**
- ✅ You want working integration **today**
- ✅ You're okay with Fugitive dependency
- ✅ You want rich out-of-box features (marks, diffs, etc.)
- ✅ You can work with Vimscript in your codebase

**Choose gitgraph.nvim if:**
- ✅ You want pure Lua, consistent with neovim ecosystem
- ✅ You're willing to invest in fork/API work
- ✅ You want VCS-agnostic solution
- ✅ You need composable rendering (not just a buffer)

---

## Implementation Effort

### vim-flog Recipe

**Time:** 1-2 hours
**Work:**
1. Create integration module (20 lines)
2. Override `<CR>` keymap (5 lines)
3. Test

**Risks:**
- Fugitive conflicts with existing setup
- Autocommand interactions with diffview hooks
- vim-flog buffer-local state may conflict with view lifecycle

### gitgraph.nvim + Snacks API

**Time:** 2-3 weeks (fork + tests + docs)
**Work:**
1. Implement `interactive.lua` (~150 lines)
2. Create `list.lua` data layer (~50 lines)
3. Update entry point in `gitgraph.lua` (~10 lines)
4. Documentation and examples (~100 lines)
5. Tests (~100 lines)

**Benefits:**
- Reusable for other plugins
- Stable contract (no future fork changes)
- Pure Lua ecosystem

---

## Recommendation

### Short-term (This Week)

**Build vim-flog recipe** to validate the concept:
- Proves that bitirectional diffview ↔ graph navigation is feasible
- Gives you working integration immediately
- Costs 2 hours

### Long-term (Next Month)

**If vim-flog approach works:**
- Keep vim-flog as the working integration
- Maybe contribute improvements back to vim-flog
- Document as a "vim-flog recipe" in your config

**If you need gitgraph**:
- Propose snacks-style API to gitgraph.nvim maintainer
- Build it as a fork feature
- OR: stick with the hooks-based approach but acknowledge the architectural gaps

---

## Files Referenced

- vim-flog API: https://github.com/rbong/vim-flog (flog.txt:1213-1260)
- vim-flog state model: https://github.com/rbong/vim-flog/blob/master/autoload/flog/floggraph.vim:1-50
- gitgraph proposal: `doc/PROPOSAL-gitgraph-snacks-api.md`
- gitgraph gaps: `doc/gitgraph-integration-forks.md`
