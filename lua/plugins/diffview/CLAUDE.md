# Diffview and Git Keybindings Documentation

## Overview
This document explains all git-related keybindings in the Neovim configuration, particularly focusing on diffview.nvim operations and conflict resolution.

## Key Binding Categories

### Visual Mode Selection
- `gv` - Standard Vim: Reselect last visual selection (built-in Vim functionality)

### Git Operations in Normal Mode

#### File-wide Operations
- `<leader>gO` - Resolve entire file as OURS (keep current branch version)
- `<leader>gP` - Resolve entire file as THEIRS (take incoming branch version)
- `<leader>gU` - Resolve entire file as UNION (keep both versions)
- `<leader>gv` - Open git-resolve-conflict picker to choose resolution strategy

#### Hunk-level Operations (in Diffview)

**Pure Diff Mode (comparing versions without conflicts):**
- `go` - Get hunk from other buffer (diffget)
- `gp` - Put hunk to other buffer (rarely works - target usually read-only)

**Conflict Mode (when there are conflict markers):**
- `gho` - Resolve current conflict hunk as OURS
- `ghp` - Resolve current conflict hunk as THEIRS  
- `ghu` - Resolve current conflict hunk as UNION (keep both)

### Navigation
- `A` - Next diff hunk or conflict (context-aware)
- `E` - Previous diff hunk or conflict (context-aware)
- `]]` - Next conflict (conflicts only)
- `[[` - Previous conflict (conflicts only)
- `]x` / `[x` - Next/previous conflict in normal buffers (via git-conflict.nvim)

## Context-Specific Behavior

### In Diffview
- When viewing file history: Only `go` (diffget) works to get changes from historical version
- When in merge conflicts: All hunk operations (`go`, `gho`, `ghp`, `ghu`) work
- When in regular diff: Only `go` works (no conflict markers to resolve)

### In Normal Buffers
- `<leader>gv` works globally to open conflict resolution picker
- `]x`/`[x` navigate between conflict markers
- File-wide resolution commands work when in conflicted files

### In Snacks Pickers
- `A`/`E` navigate to next/previous conflicted file

## Important Notes

1. **Union vs Get**: 
   - Union (`gV`, `ghu`) only makes sense for conflicts where you want both versions
   - In pure diff mode, use `go` to get specific changes

2. **Modifiable Buffers**:
   - Historical file versions are read-only
   - `diffput` rarely works because target buffers are often read-only
   - Always work from the working tree buffer when possible

3. **Conflict Detection**:
   - Conflict operations only work when Git conflict markers are present
   - Pure diff operations work when comparing any two versions

## Quick Reference

| Key | Context | Action |
|-----|---------|--------|
| `go` | Diff view | Get hunk from other buffer |
| `gho` | Conflict | Resolve hunk as OURS |
| `ghp` | Conflict | Resolve hunk as THEIRS |
| `ghu` | Conflict | Resolve hunk as UNION |
| `<leader>gO` | Any | Resolve file as OURS |
| `<leader>gP` | Any | Resolve file as THEIRS |
| `<leader>gU` | Any | Resolve file as UNION |
| `<leader>gv` | Any | Open resolve picker |
| `A`/`E` | Any | Navigate diffs/conflicts |
| `]x`/`[x` | Normal buffer | Navigate conflicts |
