# Summary: Diffview + Graph Integration Exploration

**Status:** Complete analysis with recommendations  
**Date:** 2026-06-18  
**Outcome:** Identified core architectural gap; proposed solution; evaluated alternatives

---

## What We Explored

### 1. Building a Gitgraph-Diffview Integration
- ✅ Created working hooks-based integration in `feat/gitgraph-diffview-hooks` branch
- ✅ Implemented custom rendering using `gitgraph.core.render_data()`
- ❌ Hit walls: no stable API, no commit lookup, manual lifecycle management

### 2. Understanding the Blockers
- ✅ gitgraph.nvim lacks: stable public API, item-by-line query, interactive callbacks
- ✅ diffview-plus.nvim lacks: split lifecycle management, custom panel support
- ✅ Root cause: diffview doesn't expose split registration contract

### 3. Proposing Solutions

**For gitgraph.nvim:**
- Implement snacks-style interactive list API
- ~200 LOC fork work
- See: `PROPOSAL-gitgraph-snacks-api.md`

**For diffview-plus.nvim:**
- Implement split registration API (like view registration)
- ~155 LOC, mirrors existing pattern
- See: `RFC-diffview-split-registration.md`

### 4. Exploring Alternatives
- ✅ vim-flog: mature, stable, works standalone
- ✅ Can integrate with diffview using hooks (fragile)
- ✅ Would benefit from split registration API (like gitgraph)
- See: `COMPARISON-flog-vs-gitgraph.md`, `RECIPE-flog-integration.md`

---

## Documents Created

### Analysis & Proposals

| Doc | Purpose | Status |
|-----|---------|--------|
| `RECIPE-gitgraph-limitations.md` | What we learned trying to integrate gitgraph | ✅ Complete |
| `RECIPE-diffview-splits-extensibility.md` | Why diffview doesn't support custom splits | ✅ Complete |
| `gitgraph-integration-forks.md` | Fork state and action items (tables) | ✅ Complete |
| `BLOCKER-diffview-split-lifecycle.md` | Core architectural gap identified | ✅ Complete |

### Design & Proposals

| Doc | Purpose | Status |
|-----|---------|--------|
| `PROPOSAL-gitgraph-snacks-api.md` | How to make gitgraph interactive | ✅ Complete |
| `RFC-diffview-split-registration.md` | Concrete feature request for diffview | ✅ Ready to post |
| `COMPARISON-flog-vs-gitgraph.md` | vim-flog as stable alternative | ✅ Complete |

### Insights & References

| Doc | Purpose | Status |
|-----|---------|--------|
| `INSIGHT-split-registration-enables-composition.md` | Why this matters for the ecosystem | ✅ Complete |
| `RECIPE-flog-integration.md` | vim-flog capabilities and integration | ✅ Complete |

---

## Key Findings

### The Real Blocker

It's **not** "gitgraph vs vim-flog" or "which graph tool is better."

The blocker is: **Diffview doesn't expose an API for managing custom splits at runtime.**

This affects:
- ✅ Graph panels (gitgraph, vim-flog, any other graph tool)
- ✅ Custom status displays
- ✅ File pickers (snacks, telescope)
- ✅ Any tool that needs to integrate into diffview's layout

### The Solution

Implement split registration (like diffview already does for views):

```lua
diffview.register_split_kind("graph", {
  create = function(view, config) ... end,
  restore = function(view, state) ... end,
})

opts.view.default.splits.kinds = { "graph" }
```

**Effort:** ~155 LOC
**Precedent:** Copy view registration pattern (proven, tested)
**Benefit:** Unlocks composability for entire ecosystem

---

## Recommendations

### Short-term (This Week)

1. **Install vim-flog** ✅ Done
2. **Test it standalone** — Evaluate what "mature" looks like
3. **Evaluate for immediate use** — Does vim-flog meet your needs today?

### Medium-term (Next 2 Weeks)

**Option A: Propose Split Registration RFC to Diffview**
- Post `RFC-diffview-split-registration.md` as GitHub discussion
- Make case for ~155 LOC addition
- Offer to implement if maintainer agrees

**Option B: Build vim-flog Integration Workaround**
- Use hooks to open vim-flog alongside diffview
- Document the limitations (fragile, manual lifecycle)
- Shows the value of proper split registration

### Long-term (Next Month)

**If split registration is accepted:**
- Implement in diffview-plus.nvim
- Create vim-flog split spec
- Create gitgraph split spec (with snacks-style API)
- Ecosystem gains composable splits

**If split registration is rejected:**
- Settle on vim-flog + hooks approach
- Document as "best current practice"
- OR: consider forking diffview with proper split support

---

## What This Exploration Proves

### ✅ Validated

1. Graph integration is possible but constrained by diffview architecture
2. vim-flog is mature and stable (ready to use)
3. gitgraph.nvim can be made interactive (with snacks-style API)
4. Split registration would solve the root problem

### ❌ Not Viable

1. Hooks alone cannot coordinate split lifecycle
2. Regex parsing commit data is too fragile
3. Manual window management is unmaintainable

### 🔄 Trade-offs

| Approach | Effort | Stability | Features | Maintenance |
|----------|--------|-----------|----------|-------------|
| gitgraph + snacks API | Medium (fork) | Needs work | Lightweight | Good |
| vim-flog + hooks | Low (config) | Stable | Rich | Fragile |
| vim-flog + split registration | Low (config) | Stable | Rich | Clean |
| diffview + split registration | Medium (core) | TBD | Extensible | Future |

---

## The Broader Insight

You started asking: "Can I add a graph panel to diffview?"

What you discovered: "Diffview (and the Neovim plugin ecosystem) needs a composition model for splits."

This is bigger than one feature. It's about:
- ✅ Composability (flog + diffview + snacks = integrated workflow)
- ✅ Decoupling (tools don't need to know about each other)
- ✅ Extensibility (new tools can register splits without forking)
- ✅ Ecosystem growth (UX improves when plugins work together)

---

## Next Action

**Post the RFC to diffview's GitHub discussions:**

```markdown
# RFC: Split Registration API

I've spent the last week exploring how to integrate commit graphs 
(vim-flog, gitgraph.nvim) with diffview. 

The blocker isn't the graph tool—it's that diffview doesn't expose 
a way to manage custom splits. This affects not just graphs, but 
any tool (status panels, file pickers, etc.) that wants to 
participate in the view's layout.

I'm proposing a split registration API (~155 LOC) that mirrors 
your existing view registration system. Here's the RFC:

[Link to RFC-diffview-split-registration.md]

This would unblock:
- Graph panel integration (vim-flog, gitgraph, etc.)
- Custom status/info displays
- Snacks picker integration
- Any tool that needs coordinated window management

Would you be interested in this feature? Happy to implement if 
you'd like to discuss the design first.
```

---

## Files Summary

**Exploration Results:** 9 documents, ~2500 lines of analysis
**Code Changes:** vim-flog plugin added, gitgraph integration code ready
**Status:** Ready to share findings and proposals

---

## See Also

- `feat/gitgraph-diffview-hooks` branch — Working integration (fragile)
- `~/proj/gitgraph.nvim` fork — render_data() API added
- `~/proj/diffview.nvim` fork — keymaps context exposed
