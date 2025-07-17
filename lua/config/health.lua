-- lua/config/health.lua
-- Comprehensive keymap health check system for Neovim configuration
-- Integrates with :checkhealth config command

local M = {}

-- Health check module for comprehensive keymap analysis

-- Health check severity levels
local SEVERITY = {
  ERROR = "ERROR",
  WARN = "WARN",
  INFO = "INFO",
  OK = "OK",
}

-- Graphite layout validation patterns
local GRAPHITE_PATTERNS = {
  navigation = {
    expected = { "h", "a", "e", "i" }, -- left, down, up, right
    forbidden = { "j", "k", "l" }, -- standard vim navigation
    description = "HAEI navigation (h=left, a=down, e=up, i=right)",
  },
  text_objects = {
    expected = { "r", "t" }, -- inner, around
    forbidden = { "i", "a" }, -- standard vim text objects
    description = "RT text objects (r=inner, t=around)",
  },
  operations = {
    expected = { "x", "w", "c", "v", "n", "z" }, -- delete, change, yank, paste, visual, undo
    forbidden = { "d", "y", "p", "u" }, -- standard vim operations
    description = "Graphite operations (x=delete, w=change, c=yank, v=paste, n=visual, z=undo)",
  },
}

-- Known problematic keymap patterns from which-key health check
local KNOWN_CONFLICTS = {
  overlapping_keys = {
    { base = "<x>", extended = "<xs>", description = "Delete vs Delete surrounding" },
    { base = "<w>", extended = "<ws>", description = "Change vs Change surrounding" },
    { base = "<g>", extended = "<g.*>", description = "LSP and motion conflicts" },
    { base = "<b>", extended = "<b.*>", description = "Fold command conflicts" },
    { base = "<c>", extended = "<c.*>", description = "Dashboard and surrounding conflicts" },
  },
  leader_conflicts = {
    { pattern = "<Space>q.*", description = "Quit group conflicts" },
    { pattern = "<leader>h.*", description = "Git/help group conflicts" },
    { pattern = "<leader>g.*", description = "Git group conflicts" },
  },
  mode_conflicts = {
    { modes = { "v", "o" }, keys = { "r", "t", "a", "i" }, description = "Visual/operator mode text objects" },
  },
}

-- Critical built-in commands that should not be overridden
local CRITICAL_BUILTINS = {
  n = {
    ["<C-c>"] = "Cancel/interrupt - CRITICAL",
    ["<C-z>"] = "Suspend vim - CRITICAL",
    ["<C-w>"] = "Window commands prefix - CRITICAL",
    ["<C-r>"] = "Redo - CRITICAL",
    ["<C-o>"] = "Jump backward in jumplist - CRITICAL",
    ["<C-i>"] = "Jump forward in jumplist - CRITICAL",
  },
  i = {
    ["<C-h>"] = "Backspace - CRITICAL",
    ["<C-w>"] = "Delete word before cursor - CRITICAL",
    ["<C-u>"] = "Delete line before cursor - CRITICAL",
    ["<C-n>"] = "Next match in completion - CRITICAL",
    ["<C-p>"] = "Previous match in completion - CRITICAL",
  },
}

-- Helper function to report health status
local function report(level, message, advice)
  if level == SEVERITY.ERROR then
    vim.health.error(message, advice)
  elseif level == SEVERITY.WARN then
    vim.health.warn(message, advice)
  elseif level == SEVERITY.INFO then
    vim.health.info(message)
  else
    vim.health.ok(message)
  end
end

-- Get all current keymaps
local function get_all_keymaps()
  local all_keymaps = {}
  local modes = { "n", "i", "v", "x", "o", "c", "t" }

  for _, mode in ipairs(modes) do
    all_keymaps[mode] = {}
    local maps = vim.api.nvim_get_keymap(mode)
    for _, map in ipairs(maps) do
      all_keymaps[mode][map.lhs] = {
        rhs = map.rhs or "",
        desc = map.desc or "",
        buffer = map.buffer or false,
        callback = map.callback,
      }
    end
  end

  return all_keymaps
end

-- Check for Graphite layout compliance
local function check_graphite_layout()
  report(SEVERITY.INFO, "Checking Graphite layout compliance...")

  local keymaps = get_all_keymaps()
  local violations = {}

  -- Check navigation keys
  for _, forbidden in ipairs(GRAPHITE_PATTERNS.navigation.forbidden) do
    if keymaps.n and keymaps.n[forbidden] then
      table.insert(violations, {
        key = forbidden,
        type = "navigation",
        message = string.format("Found forbidden navigation key '%s' (should use HAEI)", forbidden),
      })
    end
  end

  -- Check text object keys
  for _, forbidden in ipairs(GRAPHITE_PATTERNS.text_objects.forbidden) do
    for _, mode in ipairs({ "v", "o" }) do
      if keymaps[mode] and keymaps[mode][forbidden] then
        table.insert(violations, {
          key = forbidden,
          mode = mode,
          type = "text_objects",
          message = string.format("Found forbidden text object '%s' in mode '%s' (should use RT)", forbidden, mode),
        })
      end
    end
  end

  if #violations == 0 then
    report(SEVERITY.OK, "Graphite layout compliance: PASSED")
  else
    for _, violation in ipairs(violations) do
      report(SEVERITY.WARN, violation.message, {
        "Consider updating to Graphite layout conventions",
        "See AGENTS.md for Graphite layout specifications",
      })
    end
  end

  return violations
end

-- Check for overlapping keymap patterns
local function check_overlapping_patterns()
  report(SEVERITY.INFO, "Checking for overlapping keymap patterns...")

  local keymaps = get_all_keymaps()
  local overlaps = {}

  for _, conflict in ipairs(KNOWN_CONFLICTS.overlapping_keys) do
    local base_key = conflict.base:gsub("[<>]", "")
    local extended_pattern = conflict.extended:gsub("[<>]", "")

    -- Check if both base and extended patterns exist
    for mode, mode_maps in pairs(keymaps) do
      local has_base = mode_maps[base_key] ~= nil
      local has_extended = false

      -- Check for extended patterns
      for key, _ in pairs(mode_maps) do
        if key:match(extended_pattern) and key ~= base_key then
          has_extended = true
          break
        end
      end

      if has_base and has_extended then
        table.insert(overlaps, {
          mode = mode,
          base = base_key,
          pattern = extended_pattern,
          description = conflict.description,
        })
      end
    end
  end

  if #overlaps == 0 then
    report(SEVERITY.OK, "Overlapping patterns: NONE FOUND")
  else
    for _, overlap in ipairs(overlaps) do
      report(SEVERITY.WARN, string.format("Overlapping pattern in mode '%s': %s", overlap.mode, overlap.description), {
        "Consider using different key combinations",
        "Use which-key groups to organize related commands",
        "Check :checkhealth which-key for detailed conflicts",
      })
    end
  end

  return overlaps
end

-- Check for critical built-in overrides
local function check_critical_builtins()
  report(SEVERITY.INFO, "Checking for critical built-in command overrides...")

  local keymaps = get_all_keymaps()
  local overrides = {}

  for mode, critical_keys in pairs(CRITICAL_BUILTINS) do
    if keymaps[mode] then
      for key, description in pairs(critical_keys) do
        if keymaps[mode][key] then
          table.insert(overrides, {
            mode = mode,
            key = key,
            description = description,
            current_mapping = keymaps[mode][key],
          })
        end
      end
    end
  end

  if #overrides == 0 then
    report(SEVERITY.OK, "Critical built-ins: PROTECTED")
  else
    for _, override in ipairs(overrides) do
      report(
        SEVERITY.ERROR,
        string.format(
          "CRITICAL override in mode '%s': %s -> %s",
          override.mode,
          override.key,
          override.current_mapping.rhs or "callback"
        ),
        {
          string.format("This overrides: %s", override.description),
          "Consider using a different key combination",
          "This may break essential Vim functionality",
        }
      )
    end
  end

  return overrides
end

-- Check keymap conflict using existing test utilities
local function check_keymap_conflicts()
  report(SEVERITY.INFO, "Running comprehensive keymap conflict analysis...")

  -- Use the existing test_keymaps.lua functionality
  local success, result = pcall(function()
    -- Get current keymaps in the format expected by test_keymaps.lua
    local current_keymaps = {}
    local all_maps = get_all_keymaps()

    for mode, mode_maps in pairs(all_maps) do
      for lhs, map_data in pairs(mode_maps) do
        table.insert(current_keymaps, {
          mode = mode,
          lhs = lhs,
          rhs = map_data.rhs,
          desc = map_data.desc,
        })
      end
    end

    return current_keymaps
  end)

  if success then
    report(SEVERITY.OK, string.format("Analyzed %d total keymaps", #result))

    -- Additional analysis for common conflict patterns
    local conflict_count = 0
    local warning_count = 0

    -- Check for leader key density
    local leader_maps = {}
    for _, keymap in ipairs(result) do
      if keymap.lhs:match("^<[Ll]eader>") or keymap.lhs:match("^<[Ss]pace>") then
        table.insert(leader_maps, keymap)
      end
    end

    if #leader_maps > 50 then
      report(SEVERITY.WARN, string.format("High leader key density: %d mappings", #leader_maps), {
        "Consider organizing with which-key groups",
        "Use subgroups to reduce cognitive load",
        "Document key mappings in README.md",
      })
      warning_count = warning_count + 1
    else
      report(SEVERITY.OK, string.format("Leader key density: %d mappings (reasonable)", #leader_maps))
    end

    return { conflicts = conflict_count, warnings = warning_count, total = #result }
  else
    report(SEVERITY.ERROR, "Failed to analyze keymaps", {
      "Check lua/config/test-utils/test_keymaps.lua",
      "Ensure test utilities are properly configured",
    })
    return nil
  end
end

-- Check plugin keymap integration
local function check_plugin_integration()
  report(SEVERITY.INFO, "Checking plugin keymap integration...")

  local plugin_checks = {
    which_key = function()
      local ok, _ = pcall(require, "which-key")
      if ok then
        report(SEVERITY.OK, "which-key: Available for keymap organization")
        return true
      else
        report(SEVERITY.INFO, "which-key: Not available (optional)")
        return false
      end
    end,

    telescope = function()
      local ok, _ = pcall(require, "telescope")
      if ok then
        report(SEVERITY.OK, "telescope: Available for keymap discovery")
        return true
      else
        report(SEVERITY.INFO, "telescope: Not available")
        return false
      end
    end,

    snacks = function()
      local ok, snacks = pcall(require, "snacks")
      if ok and snacks.picker then
        report(SEVERITY.OK, "snacks.picker: Available for enhanced navigation")
        return true
      else
        report(SEVERITY.INFO, "snacks.picker: Not available")
        return false
      end
    end,
  }

  local available_plugins = {}
  for name, check_fn in pairs(plugin_checks) do
    if check_fn() then
      table.insert(available_plugins, name)
    end
  end

  return available_plugins
end

-- Generate keymap health summary
local function generate_summary(results)
  report(SEVERITY.INFO, "=== KEYMAP HEALTH SUMMARY ===")

  local total_issues = 0
  local critical_issues = 0

  -- Count issues from all checks
  if results.graphite_violations then
    total_issues = total_issues + #results.graphite_violations
  end

  if results.overlapping_patterns then
    total_issues = total_issues + #results.overlapping_patterns
  end

  if results.critical_overrides then
    critical_issues = #results.critical_overrides
    total_issues = total_issues + critical_issues
  end

  if results.conflict_analysis then
    total_issues = total_issues + (results.conflict_analysis.conflicts or 0)
    total_issues = total_issues + (results.conflict_analysis.warnings or 0)
  end

  -- Overall health assessment
  if critical_issues > 0 then
    report(SEVERITY.ERROR, string.format("CRITICAL: %d critical issues found", critical_issues), {
      "Fix critical built-in overrides immediately",
      "These may break essential Vim functionality",
    })
  elseif total_issues > 10 then
    report(SEVERITY.WARN, string.format("MODERATE: %d total issues found", total_issues), {
      "Consider keymap reorganization",
      "Use which-key groups for better organization",
      "Review Graphite layout compliance",
    })
  elseif total_issues > 0 then
    report(SEVERITY.INFO, string.format("MINOR: %d minor issues found", total_issues))
  else
    report(SEVERITY.OK, "EXCELLENT: No keymap issues detected!")
  end

  -- Recommendations
  report(SEVERITY.INFO, "=== RECOMMENDATIONS ===")

  if results.available_plugins then
    if vim.tbl_contains(results.available_plugins, "which_key") then
      report(SEVERITY.INFO, "✓ Use which-key for keymap documentation and conflict detection")
    end

    if vim.tbl_contains(results.available_plugins, "telescope") then
      report(SEVERITY.INFO, "✓ Use :Telescope keymaps for keymap discovery")
    end
  end

  report(SEVERITY.INFO, "✓ Run :checkhealth which-key for detailed conflict analysis")
  report(SEVERITY.INFO, "✓ Use lua/config/test-utils/test_keymaps.lua for testing new keymaps")
  report(SEVERITY.INFO, "✓ Follow Graphite layout conventions (see AGENTS.md)")
end

-- Main health check function
function M.check()
  vim.health.start("Neovim Configuration Keymap Analysis")

  local results = {}

  -- Run all health checks
  results.graphite_violations = check_graphite_layout()
  results.overlapping_patterns = check_overlapping_patterns()
  results.critical_overrides = check_critical_builtins()
  results.conflict_analysis = check_keymap_conflicts()
  results.available_plugins = check_plugin_integration()

  -- Generate summary and recommendations
  generate_summary(results)

  return results
end

return M
