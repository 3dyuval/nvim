# Neovim Runner for Kitty - Documentation

## Overview

A comprehensive testing framework for Neovim keymaps and configurations using Kitty's remote control protocol. This system allows automated testing of Neovim functionality via external control.

## Architecture

### Core Components

1. **kitty-mcp.lua** - Main communication module
2. **neovim_runner_kitty.lua** - Test runner and orchestration
3. **test_keymaps_conflicts.lua** - Conflict detection logic

### Communication Flow

```
Runner → kitty-mcp.lua → Kitty Remote Control → Neovim Instance
```

## Key Features

### ✅ Completed Features

- **Window Management**: Launch Neovim in new windows with explicit window ID tracking
- **Command Execution**: Send Neovim commands with proper escape sequence handling
- **Text Input**: Send arbitrary text with Python-style escape sequences (`\e`, `\r`)
- **Module Loading**: Load Lua modules in Neovim instances
- **File Operations**: Create test files and open results in new buffers
- **Conflict Testing**: Test keymap conflicts with VM (Visual Multi) plugin
- **Timing Control**: Proper delays for command execution and mode transitions

### 🚧 In Progress

- **String Transformation**: Complete escape character handling
- **Error Recovery**: Robust error handling for failed commands
- **Auto-Save**: Automatic saving of completed reports

## Usage

### Basic Commands

```bash
# Test VM keymaps for conflicts
lua neovim_runner_kitty.lua test-conflicts vm --keep-open

# Test single keymap
lua neovim_runner_kitty.lua test-single n "<leader>ff" ":Telescope find_files<CR>"

# Run arbitrary Neovim command
lua neovim_runner_kitty.lua run-command ":checkhealth"
```

### VM Conflicts Testing

The runner tests these VM keymaps for conflicts:
- `<leader>k` - VM leader key
- `<leader>kh` - VM move left (h mapped)
- `<leader>ka` - VM move down (a→j mapped)  
- `<leader>ke` - VM move up (e→k mapped)
- `<leader>ki` - VM move right (i→l mapped)
- `<leader>kr` - VM insert (r→i mapped)
- `<leader>kt` - VM append (t→a mapped)

## Technical Details

### Kitty Protocol Integration

#### Window ID Management
- **Problem**: Title matching fails with duplicate window titles
- **Solution**: Use explicit window IDs (`id:123`) instead of title matching
- **Implementation**: Store window ID from `launch` command and use throughout session

#### Escape Sequence Handling
- **Problem**: Shell vs Python vs Lua escape sequence differences
- **Solution**: Use Python-style escapes (`\e` for ESC, `\r` for CR)
- **Key Discovery**: Kitty `send-text` expects Python escaping rules, not shell

#### String Transformation Challenges

```lua
-- Original (broken): Shell-style escaping
kitty_command(string.format("send-text --match '%s' \"\\x1b\"", match))

-- Fixed: Python-style escaping  
kitty_command(string.format("send-text --match '%s' '\\e'", match))
```

### Command Execution Flow

1. **Launch**: Create new Neovim window, capture window ID
2. **Setup**: Load required modules, wait for plugin initialization
3. **Execute**: Send commands with proper timing and escape handling
4. **Results**: Write output to files, open in new buffer
5. **Cleanup**: Optional window cleanup or keep-open

### Timing Requirements

```lua
-- Mode transitions need time
os.execute("sleep 0.1")  -- ESC to normal mode

-- Command execution needs time  
os.execute("sleep 0.05") -- Between command parts

-- File operations need time
os.execute("sleep 2")    -- Wait for file write
```

## Current Issues & Solutions

### String Escaping Problems

**Issue**: Complex Lua strings with newlines and quotes fail in `send-text`

**Current Workaround**: 
```lua
-- Use single quotes and basic escaping
local cmd = string.format("send-text --match '%s' '%s'", match, text:gsub("'", "'\"'\"'"))
```

**Needed Solution**: Comprehensive escape handling in kitty-mcp.lua

### Runner Format Errors

**Issue**: `string.format` errors with nested format strings in Lua commands

**Root Cause**: 
```lua
-- This fails due to nested % symbols
test_cmd = string.format(':lua file:write(string.format("...%s...", var))', args)
```

**Solution**: Pre-build Lua strings without nested format calls

## Testing Process

### VM Conflicts Test Result

```
VM Keymaps Conflicts Analysis
============================

Test Date: [timestamp]

Tested Keymaps:
  1. <leader>k (n) -> VM leader key
  2. <leader>kh (n) -> VM left
  3. <leader>ka (n) -> VM down
  4. <leader>ke (n) -> VM up
  5. <leader>ki (n) -> VM right
  6. <leader>kr (n) -> VM insert
  7. <leader>kt (n) -> VM append

Conflicts Found: 0

SUCCESS: No conflicts detected! Your VM keymaps are safe to use.
```

## Remaining Work

### High Priority

1. **Fix string transformation pipeline**
   - Handle newlines, quotes, backslashes seamlessly
   - Abstract escape complexity from runner logic
   - Test all edge cases

2. **Complete runner format error fixes**
   - Remove nested `string.format` calls
   - Simplify Lua command generation
   - Add error handling for malformed commands

3. **End-to-end testing**
   - Verify complete VM conflicts workflow
   - Test file output and buffer opening
   - Validate report formatting

### Medium Priority

1. **Auto-save functionality**
   - Save completed reports automatically
   - Timestamp and organize output files
   - Archive old test results

2. **Enhanced error recovery**
   - Detect and retry failed commands
   - Handle Neovim crashes gracefully
   - Provide meaningful error messages

## Best Practices

### Command Construction
- Use explicit window IDs, never title matching
- Pre-escape strings before sending to kitty-mcp
- Keep Lua commands simple, avoid nested formats
- Always include appropriate timing delays

### Testing Strategy  
- Test string transformations in isolation
- Verify each communication layer independently
- Use manual testing to validate automated results
- Keep test commands minimal and focused

### Debugging
- Check window IDs with `kitten @ ls`
- Test basic Lua execution before complex commands
- Verify file permissions and paths
- Monitor timing-sensitive operations

## Files Structure

```
scripts/
├── kitty-mcp.lua              # Core communication module
├── neovim_runner_kitty.lua     # Main test runner
├── test_*.lua                  # Individual test scripts
├── tmp/                        # Output files and reports
│   ├── vm_conflicts_report.txt
│   ├── nvim_test_*.txt
│   └── test_results.json
└── RUNNER.md                   # This documentation
```