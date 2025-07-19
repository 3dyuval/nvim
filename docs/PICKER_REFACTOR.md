# Picker Extensions Refactoring Summary

## Overview
Consolidated all Snacks.nvim picker extensions into a single, well-organized module with proper dependency injection patterns.

## Changes Made

### 1. Created Centralized Module
- **File**: `lua/utils/picker-extensions.lua`
- **Purpose**: Single source of truth for all picker utilities and extensions
- **Architecture**: Proper separation of concerns with clear public API

### 2. Dependency Injection Pattern
All picker functions now follow the pattern:
```lua
["key"] = function(picker)
  require("utils.picker-extensions").action_name(picker, ...)
end
```

This ensures:
- Picker instance is properly passed as dependency
- No global state dependencies
- Clear contract between keymap and utility functions
- Easy testing with mock picker objects

### 3. Consolidated Features

#### Core Utilities
- `validate_picker(picker)` - Validates picker instance
- `safe_picker_call(picker, method, ...)` - Safe method calls with error handling

#### Picker Actions
- `open_multiple_buffers(picker)` - Opens selected files in buffers
- `copy_file_path(picker, item)` - Copy file paths with options
- `search_in_directory(picker, item)` - Search within directory
- `diff_selected(picker)` - Diff two selected files
- `handle_directory_expansion(picker)` - Handle directory navigation

#### Context Menu System
- Robust context detection for different picker types
- Context-specific action sets
- Fallback support for unknown contexts
- Proper error handling and validation

### 4. Updated snacks.lua
- Replaced inline functions with calls to centralized module
- Consistent dependency injection pattern throughout
- Cleaner, more maintainable configuration

### 5. Removed Redundancy
- Deleted old `lua/utils/explorer-menu.lua`
- Consolidated duplicate functionality
- Single source of truth for all picker extensions

## Benefits

### Maintainability
- All picker extensions in one place
- Consistent patterns and error handling
- Easy to add new picker types or actions

### Testability
- Clear dependency injection makes testing easier
- Mock picker objects can be used for unit tests
- No hidden dependencies on global state

### Reliability
- Proper error handling throughout
- Validation of picker instances
- Safe method calls with fallbacks

### Extensibility
- Easy to add new picker types
- Modular action system
- Clear separation between context detection and actions

## Usage Examples

### Adding a New Picker Action
```lua
-- In picker-extensions.lua
M.new_action = function(picker, item)
  if not validate_picker(picker) then return end
  -- Action implementation
end

-- In snacks.lua
["key"] = function(picker)
  require("utils.picker-extensions").new_action(picker)
end
```

### Adding a New Context
```lua
-- In picker-extensions.lua contexts table
new_context = {
  detect = function(picker)
    -- Detection logic
  end,
  get_items = function(picker)
    -- Item retrieval logic
  end,
}
```

## Architecture Principles

1. **Dependency Injection**: All functions receive picker as parameter
2. **Error Handling**: Comprehensive validation and safe method calls
3. **Separation of Concerns**: Clear boundaries between detection, actions, and UI
4. **Single Responsibility**: Each function has one clear purpose
5. **Extensibility**: Easy to add new functionality without breaking existing code

This refactoring provides a solid foundation for picker extensions that is maintainable, testable, and follows best practices for dependency management.