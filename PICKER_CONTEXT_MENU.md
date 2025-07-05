# Snacks.nvim Picker Context Menu System

## Overview
This document describes the data flow and architecture of the context menu system for Snacks.nvim pickers, activated by pressing "b" in any picker.

## Data Flow Diagram

```mermaid
flowchart TD
    A[User presses 'b' in Snacks picker] --> B[show_context_menu function]
    B --> C[validate_picker]
    C --> D{Picker valid?}
    D -->|No| E[Show error notification]
    D -->|Yes| F[detect_context function]
    
    F --> G[Check explorer actions]
    F --> H[Check git_status patterns]
    F --> I[Check buffer properties]
    F --> J[Check file properties]
    
    G --> K{Has explorer_* actions?}
    H --> L{Has git status patterns?}
    I --> M{Has bufnr property?}
    J --> N{Has file property?}
    
    K -->|Yes| O[Context: explorer]
    L -->|Yes| P[Context: git_status]
    M -->|Yes| Q[Context: buffers]
    N -->|Yes| R[Context: files]
    
    K -->|No| H
    L -->|No| I
    M -->|No| J
    N -->|No| S[Context: unknown]
    
    O --> T[get_items for explorer]
    P --> U[get_items for git_status]
    Q --> V[get_items for buffers]
    R --> W[get_items for files]
    S --> X[Fallback item retrieval]
    
    T --> Y[Try picker:selected]
    T --> Z[Try picker:current]
    T --> AA[Try picker.list.selected]
    
    U --> Y
    V --> Y
    W --> Y
    X --> Y
    
    Y --> BB{Items found?}
    Z --> BB
    AA --> BB
    
    BB -->|No| CC[Show 'No actions available' warning]
    BB -->|Yes| DD[get_actions function]
    
    DD --> EE{Context type?}
    EE -->|explorer/files| FF[File/directory actions]
    EE -->|git_status| GG[Git-specific actions]
    EE -->|buffers| HH[Buffer actions]
    
    FF --> II{Single item?}
    II -->|Yes| JJ{Is directory?}
    II -->|No| KK[Multiple items actions]
    
    JJ -->|Yes| LL[Directory actions]
    JJ -->|No| MM[File actions]
    
    LL --> NN[Add git actions if in repo]
    MM --> NN
    KK --> NN
    GG --> NN
    HH --> NN
    
    NN --> OO[Create vim.ui.select menu]
    OO --> PP[User selects action]
    PP --> QQ[Execute selected action]
    
    QQ --> RR{Action type?}
    RR -->|File operation| SS[Rename/Delete/Copy]
    RR -->|Navigation| TT[Open/Split/Tab]
    RR -->|Git operation| UU[Stage/Unstage/Restore]
    RR -->|Buffer operation| VV[Save/Delete/Wipe]
    RR -->|Utility| WW[Save patterns/Search]
    
    SS --> XX[Refresh picker if needed]
    TT --> YY[Close picker]
    UU --> XX
    VV --> XX
    WW --> XX
```

## Context Detection Strategy

### Primary Detection (Capability-based)
Since `picker.opts.source` is unreliable (often `nil`), we use capability-based detection:

```mermaid
flowchart LR
    A[Picker Object] --> B{Has explorer_* actions?}
    B -->|Yes| C[Explorer Context]
    B -->|No| D{Current item has git status?}
    D -->|Yes| E[Git Status Context]
    D -->|No| F{Current item has bufnr?}
    F -->|Yes| G[Buffers Context]
    F -->|No| H{Current item has file property?}
    H -->|Yes| I[Files Context]
    H -->|No| J[Unknown Context]
```

### Item Retrieval Hierarchy
For each context, items are retrieved using this fallback chain:

```mermaid
flowchart TD
    A[Start item retrieval] --> B[Try picker:selected]
    B --> C{Has items?}
    C -->|Yes| D[Return selected items]
    C -->|No| E[Try picker:current]
    E --> F{Has current?}
    F -->|Yes| G[Return current as array]
    F -->|No| H[Try picker.list.selected]
    H --> I{Has list items?}
    I -->|Yes| J[Return list items]
    I -->|No| K[Return empty array]
```

## Action Categories

### Explorer/Files Context
- **Single File**: Open, split, rename, delete, copy path, save patterns
- **Single Directory**: Open, explore, terminal, rename, delete, new file/dir
- **Multiple Items**: Delete all, copy paths, open all files, save patterns
- **Git Actions**: Add, restore (if in git repo)

### Git Status Context
- **Stage/Unstage**: Toggle staging status based on current state
- **Restore**: Restore files to HEAD state
- **Diff**: Show git diff in split
- **Save Patterns**: Run formatting on changed files

### Buffers Context
- **Delete**: Close buffer (with confirmation)
- **Wipe**: Force close buffer
- **Save**: Write buffer to disk
- **Save Patterns**: Run formatting on buffer content

## Key Technical Solutions

### Problem: Source Field Unreliable
- **Issue**: `picker.opts.source` often returns `nil`
- **Solution**: Detect context by examining available actions and item properties

### Problem: Empty Item Lists
- **Issue**: `picker:selected()` returns `{}` instead of `nil` when no selection
- **Solution**: Check `#selected > 0` and implement fallback chain

### Problem: Different Picker Behaviors
- **Issue**: Different pickers expose items differently
- **Solution**: Unified `get_items` function with multiple fallback strategies

## Files Modified
- `lua/utils/picker-extensions.lua` - Main implementation
- `lua/plugins/snacks.lua` - Key binding configuration (`["b"]` mapping)

## Usage
Press `b` in any Snacks.nvim picker to open the context menu with appropriate actions for the current context and selected/current items.