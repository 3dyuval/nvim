# Feature Request: Make Log Display Options Persistable (Magit-Aligned)

**Is your feature request related to a problem? Please describe.**

Log commands like `:NeogitLogCurrent` don't respect my preferred display settings (`--graph`, `--decorate`, `--color`) even though Neogit has excellent settings persistence (`remember_settings = true`) because these switches are marked as `internal = true` in the log popup, preventing them from being persisted.

**Current behavior:**
1. Open `:Neogit log` popup
2. Enable `graph`, `decorate`, `color` switches  
3. Run log action → beautiful graph display
4. Later run `:NeogitLogCurrent` → plain log without graph/decorations
5. Settings aren't remembered because switches are `internal = true`

**Describe the solution you'd like**

Make log display switches persistable while maintaining magit's philosophy:

### Option 1: Remove `internal = true` (Simplest)
```lua
-- In popups/log/init.lua
:switch("g", "graph", "Show graph", {
  enabled = true,
  -- internal = true,  -- REMOVE THIS
  incompatible = { "reverse" },
  dependent = { "color" },
})
:switch("d", "decorate", "Show refnames", { 
  enabled = true, 
  -- internal = true  -- REMOVE THIS
})
```

### Option 2: Add persistence exception for display switches
```lua  
:switch("g", "graph", "Show graph", {
  enabled = true,
  internal = true,
  persisted = true,  -- OVERRIDE: persist even though internal
})
```

### Option 3: New `display_internal` category
```lua
:switch("g", "graph", "Show graph", {
  enabled = true,
  display_internal = true,  -- Internal for git CLI, but persist for UX
})
```

**Expected behavior (magit-like):**
- User enables graph/decorate in log popup → settings are remembered
- `:NeogitLogCurrent` respects last-used display preferences
- All log operations (popup actions, direct commands) use persisted settings
- Works with existing `use_per_project_settings` for project-specific preferences

**Why this aligns with magit philosophy:**

1. **Magit has `C-x C-s`** to save transient arguments permanently
2. **Display preferences ARE user choices** - not just git CLI arguments
3. **Persistence is core magit behavior** - not a snacks.nvim pattern
4. **Progressive disclosure maintained** - user still discovers options via popup
5. **Respects existing neogit infrastructure** - no new config patterns needed

**Describe alternatives you've considered**

1. **Builders Pattern (Current Workaround):**
   ```lua
   builders = {
     NeogitLogPopup = function(popup)
       for _, arg in ipairs(popup.state.args) do
         if arg.cli == "graph" then arg.enabled = true end
       end
     end,
   }
   ```
   - ✅ Works but verbose and requires internal knowledge

2. **opts.log Configuration Pattern:**
   ```lua  
   log = { graph = true, decorate = true }
   ```
   - ❌ This would be more "snacks-like" than "magit-like"
   - ❌ Bypasses the popup discovery mechanism

3. **CLI Parameter Parsing (Future Enhancement):**
   ```bash
   :Neogit log -g -d l  # --graph --decorate then log_current
   ```
   - ✅ Would complement persistence nicely for power users

**Additional context**

**Root cause analysis:**
```lua
-- Current log popup switches (internal = not persisted)
:switch("g", "graph", "Show graph", { enabled = true, internal = true })
:switch("d", "decorate", "Show refnames", { enabled = true, internal = true })
```

The `internal = true` flag was likely added because these affect display rendering, not git CLI arguments. However, **display preferences are user choices that should persist**.

**Comparison with other switches:**
```lua
-- These ARE persisted (no internal = true)  
:switch("r", "reverse", "Reverse order")
:switch("f", "follow", "Follow renames")

-- These are NOT persisted (internal = true)
:switch("g", "graph", "Show graph", { internal = true })  -- ❌ Should persist
:switch("d", "decorate", "Show refnames", { internal = true })  -- ❌ Should persist
```

**Impact:**
- **All log commands** would respect user preferences: `:NeogitLogCurrent`, popup actions, API calls
- **Maintains magit philosophy** of persistent user choices
- **Uses existing infrastructure** - no new config patterns
- **Project-specific settings** work automatically via `use_per_project_settings`

This change would make neogit's log persistence behavior match magit's transient persistence, where display preferences are treated as persistable user choices.