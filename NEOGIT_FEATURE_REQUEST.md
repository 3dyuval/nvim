# Feature Request: Direct Popup Action Execution

## Summary
Enable direct execution of popup actions via command parameters, allowing commands like `:Neogit log l` to execute the log_current action immediately instead of showing the popup first.

## Current Behavior
- `:Neogit log` shows log popup, waits for user keypress
- `:Neogit log l` shows log popup, then requires additional keypress 'l' to execute log_current
- All popup parameters currently show the popup UI first

## Proposed Enhancement
- `:Neogit log l` executes log_current action directly
- `:Neogit commit a` executes commit_all action directly  
- `:Neogit push u` executes push_upstream action directly
- Maintains backward compatibility - `:Neogit log` still shows popup

## Implementation Analysis

### Current Flow
```
:Neogit log l → parse_command_args() → neogit.open({[1] = "log"}) → open_popup("log")
```

### Proposed Flow
```
:Neogit log l → parse_command_args() → neogit.open({[1] = "log", action = "l"}) → execute_action_directly()
```

### Required Changes (~20 lines)

**File**: `lua/neogit.lua`
**Function**: `open_popup(name)` (lines 97-104)

```lua
local function open_popup(name, action)
  local has_pop, popup = pcall(require, "neogit.popups." .. name)
  if not has_pop then
    M.notification.error(("Invalid popup %q"):format(name))
  else
    local popup_instance = popup.create {}
    
    -- NEW: Direct action execution
    if action then
      local actions = require("neogit.popups." .. name .. ".actions")
      for _, group in pairs(popup_instance.state.actions) do
        for _, act in pairs(group) do
          if vim.tbl_contains(act.keys or {}, action) and act.callback then
            act.callback(popup_instance)
            return
          end
        end
      end
      M.notification.error(("Invalid action %q for popup %q"):format(action, name))
    else
      popup_instance:show()
    end
  end
end
```

**File**: `lua/neogit.lua` 
**Function**: `M.open(opts)` (lines 147-177)

```lua
-- Update line 165-174
if opts[1] ~= nil then
  local a = require("plenary.async")
  local cb = function()
    open_popup(opts[1], opts[2]) -- Pass second parameter as action
  end

  a.void(function()
    git.repo:dispatch_refresh { source = "popup", callback = cb }
  end)()
else
  open_status_buffer(opts)
end
```

## Benefits

### Developer Experience
- **Faster workflow**: Direct command execution eliminates UI popup step
- **Scriptability**: Commands can be used in automation/scripts  
- **Consistency**: Matches vim's `:command subcommand` pattern
- **Muscle memory**: Reduces context switching between popup UI and command execution

### Backward Compatibility  
- All existing `:Neogit popup` commands continue working unchanged
- New parameter is optional - no breaking changes
- Progressive enhancement for power users

## Use Cases

### Common Workflows
```vim
" Quick git operations
:Neogit log l          " Show current file log
:Neogit commit a       " Commit all changes  
:Neogit push u         " Push to upstream
:Neogit pull p         " Pull from remote
:Neogit stash s        " Stash changes
:Neogit branch c       " Create new branch
```

### Keybinding Integration
```lua
-- Direct action keybindings
vim.keymap.set('n', '<leader>gll', '<cmd>Neogit log l<cr>', { desc = 'Git log current' })
vim.keymap.set('n', '<leader>gca', '<cmd>Neogit commit a<cr>', { desc = 'Git commit all' })
vim.keymap.set('n', '<leader>gpu', '<cmd>Neogit push u<cr>', { desc = 'Git push upstream' })
```

### Script Integration
```bash
# CI/CD scripts, automation tools
nvim --headless -c "Neogit stash s" -c "qa"
nvim --headless -c "Neogit commit a" -c "qa"  
```

## Implementation Complexity: **Very Low**
- **Lines changed**: ~20 lines across 2 functions
- **Risk level**: Minimal - purely additive feature
- **Testing scope**: Action parameter parsing + execution validation
- **Documentation**: Command reference update for new parameter syntax

## Alternative Approach
Could also implement via `M.action()` API enhancement:
```lua
-- Current: requires function call
require("neogit").action("log", "log_current", {})()

-- Proposed: direct command syntax  
:Neogit action log log_current
```

But the popup parameter approach is more intuitive and matches existing command patterns.