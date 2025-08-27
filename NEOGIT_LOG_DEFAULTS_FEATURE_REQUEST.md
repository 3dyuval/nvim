**Describe the bug**

Log display switches (`graph`, `decorate`, `color`) don't persist between sessions despite `remember_settings = true`, causing `:NeogitLogCurrent` to ignore user preferences.

**To Reproduce**
1. Open `:Neogit log` popup
2. Enable `graph`, `decorate`, `color` switches
3. Run any log action → see beautiful graph display
4. Later run `:NeogitLogCurrent` → plain log without preferences

**Expected behavior**

All log commands should respect last-used display preferences, consistent with other persisted switches like `reverse`.

**Root cause**

Display switches are marked `internal = true` which prevents persistence:
```lua
:switch("g", "graph", "Show graph", { enabled = true, internal = true })  -- ❌ Not persisted
:switch("r", "reverse", "Reverse order")  -- ✅ Persisted  
```

**Proposed fix**

Remove `internal = true` from display switches or add `persisted = true` override:
```lua
:switch("g", "graph", "Show graph", {
  enabled = true,
  -- internal = true,  -- REMOVE THIS
})
```

**Environment**
- OS: Linux/macOS/Windows
- Neovim version: 0.10+
- Neogit version: latest
