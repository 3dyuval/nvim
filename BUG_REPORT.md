# Bug Report: Formatter Global Config Detection Issue

## Summary
The formatter utility in `lua/utils/formatter.lua` was incorrectly registering global formatters instead of respecting project-local configuration, causing formatting inconsistencies across different projects.

## Environment
- **Repository**: 3dyuval/nvim
- **Neovim Version**: Latest stable
- **Formatter**: conform.nvim with biome
- **Affected Files**: 
  - `lua/utils/formatter.lua`
  - `lua/utils/picker-extensions.lua`

## Problem Description
1. **Global Config Override**: The formatter was using global configuration instead of project-specific settings
2. **Quote Style Issues**: Projects expecting single quotes were getting double quotes due to global config precedence
3. **Multiple Formatter Implementations**: `picker-extensions.lua` had its own formatter calls bypassing the centralized formatter module

## Symptoms
- ✅ Formatters showed as "ready" in `:ConformInfo`
- ❌ Wrong quote style applied (double instead of single)
- ❌ Inconsistent formatting behavior between projects
- ❌ Global biome config interfering with project-specific configs

## Root Cause
The formatter was not properly detecting and respecting local project configuration, defaulting to global settings that conflicted with project requirements.

## Solution Implemented
1. **Added Feature Flag**: `ENABLE_GLOBAL_CONFIG_DETECTION = false` to disable problematic global formatter registration
2. **Centralized Formatting**: Updated all `picker-extensions.lua` format actions to use `utils.formatter` module
3. **Local Config Priority**: Copied project-specific biome.json to project root to ensure local config takes precedence

## Files Modified
- `lua/utils/formatter.lua`: Added feature flag and conditional logic
- `lua/utils/picker-extensions.lua`: Replaced direct conform calls with centralized formatter calls
- Project-specific: Added local `biome.json` configuration

## Verification
- [x] Quote styles now respect project configuration
- [x] All formatting operations go through centralized module
- [x] Feature flag successfully disables global config detection
- [x] Project-local biome.json takes precedence

## Status
✅ **RESOLVED** - Formatter now correctly uses project-local configuration with feature flag controlling global config detection behavior.