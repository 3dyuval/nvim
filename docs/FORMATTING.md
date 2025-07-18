# Neovim Formatting Architecture

This document explains the complete formatting system architecture in this Neovim configuration, including all tools, plugins, and their interactions.

## 🏗️ Architecture Overview

Our formatting system consists of **4 distinct layers** that work together:

```
┌─────────────────────────────────────────────────────────────────┐
│                    USER INTERFACE LAYER                        │
├─────────────────────────────────────────────────────────────────┤
│ • Picker Actions ('b' key → context menu)                     │
│ • User Commands (:Format, :FormatCheck)                       │
│ • Keymaps (<leader>ff, <leader>fF)                           │
│ • CLI Script (./format)                                       │
└─────────────────────────────────────────────────────────────────┘
                                  ↓
┌─────────────────────────────────────────────────────────────────┐
│                   COORDINATION LAYER                           │
├─────────────────────────────────────────────────────────────────┤
│ • LazyVim.format() - Respects auto-format settings            │
│ • Async Formatter API - Progress tracking & job management     │
│ • Save Patterns - Import organization & custom logic          │
└─────────────────────────────────────────────────────────────────┘
                                  ↓
┌─────────────────────────────────────────────────────────────────┐
│                    EXECUTION LAYER                             │
├─────────────────────────────────────────────────────────────────┤
│ • conform.nvim - Formatter orchestration                      │
│ • typescript-tools - Import organization                      │
│ • CLI Script - Batch processing                               │
└─────────────────────────────────────────────────────────────────┘
                                  ↓
┌─────────────────────────────────────────────────────────────────┐
│                      TOOL LAYER                               │
├─────────────────────────────────────────────────────────────────┤
│ • Biome - JS/TS/JSON formatting + import organization         │
│ • Prettier - Fallback JS/TS/JSON formatting                  │
│ • Stylua - Lua formatting                                     │
└─────────────────────────────────────────────────────────────────┘
```

## 🔧 System Components

### 1. **LazyVim Auto-Format System** (Primary Controller)
- **Purpose**: Central auto-format control system
- **Controls**: `vim.g.autoformat` (global), `vim.b.autoformat` (per-buffer)
- **Integration**: All our systems now respect these settings
- **Commands**: `:LazyFormatToggle` (global), `:LazyFormatToggle!` (buffer)

### 2. **conform.nvim** (Formatter Orchestrator)
- **Purpose**: Manages which formatter to use for each file type
- **Configuration**: `/lua/plugins/conform.lua`
- **Supported Types**: JS/TS/JSON → Biome, HTML/Vue → Prettier
- **Integration**: Called by LazyVim's format system

### 3. **Save Patterns System** (Custom Logic)
- **Purpose**: Import organization and custom formatting logic
- **Configuration**: `/lua/utils/save-patterns.lua`
- **Features**: 
  - TypeScript: Import organization via typescript-tools
  - Lua: Formatting via LazyVim.format() → conform → stylua
  - JSON: Formatting via LazyVim.format() → conform → biome
- **Integration**: Respects `vim.g.autoformat` and `vim.b.autoformat`

### 4. **Async Formatter API** (Manual Operations)
- **Purpose**: Manual formatting with progress tracking
- **Configuration**: `/lua/utils/formatter.lua`
- **Features**: 
  - Async execution with progress icons
  - Job management and cancellation
  - Batch directory formatting
- **Integration**: Uses CLI script for actual formatting

### 5. **CLI Script** (Batch Processing)
- **Purpose**: Batch formatting from command line or async API
- **Location**: `/format` (executable bash script)
- **Features**: 
  - Biome-first approach with Prettier fallback
  - Verbose output with progress indicators
  - Supports --check, --dry-run modes
- **Integration**: Uses same configs as Neovim (biome.json, .prettierrc, stylua.toml)

## 🎯 Usage Scenarios

### Auto-Format (On Save)
```
File Save → save-patterns.lua → LazyVim.format() → conform.nvim → Tool (biome/stylua)
```

**Controls**:
- Global: `vim.g.autoformat = false` disables all auto-formatting
- Buffer: `vim.b.autoformat = false` disables for current buffer
- Commands: `:LazyFormatToggle` and `:LazyFormatToggle!`

### Manual Format via Picker
```
User → 'b' key → Context Menu → Async Formatter API → CLI Script → Tools
```

**Features**:
- Progress tracking with icons (⏳ processing, ✅ done, ❌ error)
- Works on single files, multiple files, or entire directories
- Automatic picker refresh after formatting

### Manual Format via Commands
```
User → :Format → Async Formatter API → CLI Script → Tools
```

**Available Commands**:
- `:Format [files...]` - Format specified files or current file
- `:FormatCheck [files...]` - Check formatting without changes
- `:FormatJobs` - Show active formatting jobs

### Manual Format via CLI
```
User → ./format [options] [paths] → Tools directly
```

**Examples**:
- `./format src/` - Format all supported files in src directory
- `./format --check .` - Check formatting without changes
- `./format --verbose file.ts` - Format with verbose output

## 📁 File Type Support

### JavaScript/TypeScript/JSON
- **Primary**: Biome (`biome.json` config)
- **Fallback**: Prettier (`.prettierrc` config)
- **Features**: 
  - Formatting with consistent style
  - Import organization (React → @angular → packages → @/ → relative)
  - Lint fixes (safe fixes only)

### Lua
- **Primary**: Stylua (`stylua.toml` config)
- **Features**:
  - 2-space indentation
  - Consistent formatting
  - Integrated with LazyVim's system

### HTML/Vue
- **Primary**: Prettier (`.prettierrc` config)
- **Features**: 
  - Consistent attribute formatting
  - Proper indentation

## 🔄 Configuration Files

### Core Config Files
- `/lua/plugins/conform.lua` - conform.nvim configuration
- `/lua/utils/save-patterns.lua` - Custom save patterns
- `/lua/utils/formatter.lua` - Async formatter API
- `/lua/config/formatter.lua` - Setup and keymaps

### Tool Config Files
- `/biome.json` - Biome configuration (JS/TS/JSON)
- `/.prettierrc` - Prettier configuration (HTML/Vue/fallback)
- `/stylua.toml` - Stylua configuration (Lua)

### Integration Files
- `/lua/config/autocmds.lua` - Auto-format setup
- `/lua/utils/picker-extensions.lua` - Picker integration
- `/format` - CLI script for batch operations

## 🧪 Testing

### Test Files
- `/lua/utils/tests/test_formatter.lua` - Plenary test suite
- `/test-integration.lua` - Integration test script

### Test Commands
- `nvim --headless -c "source test-integration.lua" -c "qa"` - Run integration tests
- `./test-format-simple.sh` - CLI formatter tests

## 🐛 Troubleshooting

### Auto-Format Not Working
1. **Check LazyVim Settings**:
   ```lua
   :lua print(vim.g.autoformat)  -- Should be true
   :lua print(vim.b.autoformat)  -- Should be nil or true
   ```

2. **Check Save Patterns**:
   ```lua
   :lua print(vim.inspect(require("utils.save-patterns").patterns))
   ```

3. **Check Conform Status**:
   ```lua
   :lua print(vim.inspect(require("conform").list_formatters()))
   ```

### Manual Format Not Working
1. **Check Async Jobs**:
   ```vim
   :FormatJobs
   ```

2. **Test CLI Script**:
   ```bash
   ./format --verbose --check yourfile.js
   ```

3. **Check Tool Installation**:
   ```bash
   which biome prettier stylua
   ```

### Import Organization Issues
1. **Check Save Patterns**:
   ```lua
   -- In save-patterns.lua, import organization uses LSP actions
   :lua require("utils.save-patterns").run_patterns(0, require("utils.save-patterns").patterns.typescript)
   ```

2. **Check Biome Config**:
   ```bash
   biome check --config-path . yourfile.ts
   ```

## 📝 Recent Changes

### v2.0 - Unified Formatting System
- **Fixed**: Save patterns now respect LazyVim's auto-format settings
- **Added**: Async formatter API with progress tracking
- **Added**: Picker integration with 'b' key context menu workflow
- **Added**: CLI script with biome-first approach
- **Updated**: All systems now work together instead of competing

### Key Improvements
1. **Unified Control**: All formatting now respects `vim.g.autoformat`
2. **Better UX**: Progress tracking and async operations
3. **Consistent Config**: All systems use the same tool configurations
4. **Fallback System**: Biome → Prettier → Stylua as appropriate

## 🎛️ Settings Reference

### Global Settings
```lua
vim.g.autoformat = true/false  -- Enable/disable auto-format globally
```

### Buffer Settings
```lua
vim.b.autoformat = true/false  -- Enable/disable auto-format for current buffer
```

### Formatter Settings
```lua
-- In lua/utils/formatter.lua
local formatter = require("utils.formatter")
formatter.setup({
  verbose = false,
  auto_notification = true,
  progress_interval = 1000,
})
```

This unified system ensures that all formatting operations work consistently and respect user preferences while providing both automatic and manual formatting capabilities.