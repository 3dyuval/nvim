-- Keymap Utilities - Clean keymap management and introspection
-- Provides both simple vim.keymap.set wrappers and lil.nvim introspection

local M = {}
local collected_keymaps = {}
local group_descriptions = {}

-- ============================================================================
-- CORE KEYMAP ABSTRACTIONS
-- ============================================================================

-- Simple keymap wrapper that aligns with vim.keymap.set
function M.map(modes, lhs, rhs, desc_text, opts)
  opts = opts or {}
  opts.desc = desc_text

  -- Convert single mode to table for consistency
  if type(modes) == "string" then
    modes = { modes }
  end

  -- Safe deletion and setting for each mode
  for _, mode in ipairs(modes) do
    M.safe_del(mode, lhs)
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

-- Safe keymap deletion (core building block)
function M.safe_del(mode, lhs)
  pcall(vim.keymap.del, mode, lhs)
end

-- Command builder utility
function M.cmd(command, exec)
  if exec == false then
    -- Open command line with command pre-filled (no execution)
    return ":" .. command
  end
  exec = exec or "<Cr>"
  return "<Cmd>" .. command .. exec
end

-- Safe remap (delete then set)
function M.remap(mode, lhs, rhs, opts)
  M.safe_del(mode, lhs)
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- Function mapping utility compatible with lil.nvim
function M.func_map(m, l, r, o, _next)
  M.safe_del(m, l)
  vim.keymap.set(m, l, r, o) -- o already contains desc and expr from [opts]
end

-- ============================================================================
-- COMPOSABLE BUILDERS (users can extend these)
-- ============================================================================

-- Prefix builder for creating scoped keymap functions
function M.prefix(prefix_key)
  return function(suffix, action, desc_text, opts)
    M.map("n", prefix_key .. suffix, action, desc_text, opts)
  end
end

-- Table-based keymap registration
function M.register(config, base_modes)
  base_modes = base_modes or "n"
  for prefix, mappings in pairs(config) do
    if type(mappings) == "table" then
      for key, mapping in pairs(mappings) do
        local full_key = prefix == "" and key or prefix .. key
        if type(mapping) == "table" and mapping[1] then
          -- Format: {action, "description", {opts}}
          local action = mapping[1]
          local desc = mapping[2]
          local opts = mapping[3] or {}
          local modes = opts.modes or base_modes
          M.map(modes, full_key, action, desc, opts)
        end
      end
    end
  end
end

-- ============================================================================
-- SMART MAP WITH GROUP DESCRIPTIONS
-- ============================================================================

-- Desc helper for lil.nvim - auto-handles lil flags internally
function M.desc(description, value, expr)
  local ok_utils, lil_utils = pcall(require, "lil.utils")
  if not ok_utils then
    error("lil.utils is required for desc")
  end

  local opts_flag = lil_utils.flags.opts

  return {
    value,
    [opts_flag] = { desc = description, expr = expr },
  }
end

-- Create smart wrapper around lil.map that auto-extracts group descriptions
-- and auto-injects [func] = func_map
function M.create_smart_map()
  -- Get lil.nvim and its flags internally
  local ok, lil = pcall(require, "lil")
  if not ok then
    error("lil.nvim is required for create_smart_map")
  end

  local ok_utils, lil_utils = pcall(require, "lil.utils")
  if not ok_utils then
    error("lil.utils is required for create_smart_map")
  end

  local lil_opts_flag = lil_utils.flags.opts
  local lil_func_flag = lil_utils.flags.func
  local original_map = lil.map

  -- Define func_map inside the wrapper
  local function func_map(m, l, r, o, _next)
    M.safe_del(m, l)
    vim.keymap.set(m, l, r, o)
  end

  return function(map_def)
    -- Track visited tables to prevent infinite recursion
    local visited = {}

    -- Process tables recursively to extract desc and groups
    local function process_table(prefix, t)
      if visited[t] then
        return
      end
      visited[t] = true

      for key, value in pairs(t) do
        -- Only process string keys (skip lil flags)
        if type(key) == "string" and type(value) == "table" then
          local full_key = prefix .. key

          -- Extract desc key and move to [opts]
          if value.desc then
            -- Initialize [opts] if it doesn't exist
            if not value[lil_opts_flag] then
              value[lil_opts_flag] = {}
            end
            -- Move desc to [opts]
            value[lil_opts_flag].desc = value.desc
            value.desc = nil -- Remove from top level
          end

          -- Check if this table has a group option
          if
            value[lil_opts_flag]
            and type(value[lil_opts_flag]) == "table"
            and value[lil_opts_flag].group
          then
            table.insert(group_descriptions, { full_key, group = value[lil_opts_flag].group })
          end

          -- Recurse into nested tables (skip if it's a keymap definition)
          if not value[1] then
            process_table(full_key, value)
          end
        end
      end
    end

    process_table("", map_def)

    -- Auto-inject [func] = func_map if not already present
    if not map_def[lil_func_flag] then
      map_def[lil_func_flag] = func_map
    end

    -- Call original lil.map
    original_map(map_def)
  end
end

-- Register all collected group descriptions with which-key
function M.register_groups()
  if #group_descriptions == 0 then
    return
  end

  local ok, wk = pcall(require, "which-key")
  if ok then
    wk.add(group_descriptions)
  end
end

-- Get collected group descriptions (for export/introspection)
function M.get_group_descriptions()
  return group_descriptions
end

-- ============================================================================
-- KEYMAP INTROSPECTION & TESTING TOOLKIT
-- ============================================================================

-- Get lil.nvim utilities and flags (for introspection compatibility)
local function get_lil_utils()
  local ok, lil_utils = pcall(require, "lil.utils")
  if ok then
    return lil_utils
  end
  return nil
end

-- Built-in Vim keymaps that don't show up in vim.keymap but exist
local builtin_keymaps = {
  -- Normal mode built-ins
  n = {
    -- Movement
    ["h"] = { desc = "Left", action = "cursor left" },
    ["j"] = { desc = "Down", action = "cursor down" },
    ["k"] = { desc = "Up", action = "cursor up" },
    ["l"] = { desc = "Right", action = "cursor right" },
    ["w"] = { desc = "Word forward", action = "next word" },
    ["b"] = { desc = "Word backward", action = "previous word" },
    ["e"] = { desc = "End of word", action = "end of word" },
    ["0"] = { desc = "Beginning of line", action = "start of line" },
    ["^"] = { desc = "First non-blank character", action = "first non-blank" },
    ["$"] = { desc = "End of line", action = "end of line" },
    ["gg"] = { desc = "Go to top", action = "first line" },
    ["G"] = { desc = "Go to bottom", action = "last line" },

    -- Text objects and operations
    ["d"] = { desc = "Delete", action = "delete operator" },
    ["c"] = { desc = "Change", action = "change operator" },
    ["y"] = { desc = "Yank", action = "yank operator" },
    ["p"] = { desc = "Paste after", action = "paste after cursor" },
    ["P"] = { desc = "Paste before", action = "paste before cursor" },
    ["u"] = { desc = "Undo", action = "undo last change" },
    ["r"] = { desc = "Replace character", action = "replace single char" },
    ["x"] = { desc = "Delete character", action = "delete char under cursor" },
    ["X"] = { desc = "Delete character before", action = "delete char before cursor" },
    ["s"] = { desc = "Substitute character", action = "substitute char" },
    ["S"] = { desc = "Substitute line", action = "substitute line" },

    -- Modes
    ["i"] = { desc = "Insert mode", action = "enter insert mode" },
    ["I"] = { desc = "Insert at beginning", action = "insert at line start" },
    ["a"] = { desc = "Append", action = "enter insert after cursor" },
    ["A"] = { desc = "Append at end", action = "insert at line end" },
    ["o"] = { desc = "Open line below", action = "new line below" },
    ["O"] = { desc = "Open line above", action = "new line above" },
    ["v"] = { desc = "Visual mode", action = "enter visual mode" },
    ["V"] = { desc = "Visual line mode", action = "enter visual line mode" },

    -- Search and navigation
    ["/"] = { desc = "Search forward", action = "forward search" },
    ["?"] = { desc = "Search backward", action = "backward search" },
    ["n"] = { desc = "Next search", action = "repeat search forward" },
    ["N"] = { desc = "Previous search", action = "repeat search backward" },
    ["*"] = { desc = "Search word forward", action = "search current word forward" },
    ["#"] = { desc = "Search word backward", action = "search current word backward" },

    -- Other common built-ins
    ["."] = { desc = "Repeat last command", action = "repeat last change" },
    ["%"] = { desc = "Jump to matching bracket", action = "jump to matching paren/bracket" },
    ["f"] = { desc = "Find character", action = "find char forward" },
    ["F"] = { desc = "Find character backward", action = "find char backward" },
    ["t"] = { desc = "Till character", action = "till char forward" },
    ["T"] = { desc = "Till character backward", action = "till char backward" },
    [";"] = { desc = "Repeat find", action = "repeat last f/F/t/T" },
    [","] = { desc = "Repeat find reverse", action = "repeat last f/F/t/T reverse" },
  },

  -- Visual mode built-ins
  v = {
    ["d"] = { desc = "Delete selection", action = "delete visual selection" },
    ["c"] = { desc = "Change selection", action = "change visual selection" },
    ["y"] = { desc = "Yank selection", action = "yank visual selection" },
    ["x"] = { desc = "Delete selection", action = "delete visual selection" },
    ["s"] = { desc = "Substitute selection", action = "substitute visual selection" },
    ["o"] = { desc = "Switch cursor to other end", action = "toggle visual selection end" },
  },

  -- Insert mode built-ins
  i = {
    ["<C-h>"] = { desc = "Backspace", action = "delete char before cursor" },
    ["<C-w>"] = { desc = "Delete word", action = "delete word before cursor" },
    ["<C-u>"] = { desc = "Delete line", action = "delete line before cursor" },
  },
}

-- Get built-in keymaps for normalization
function M.get_builtin_keymaps()
  return builtin_keymaps
end

-- Normalize keymaps by including built-ins that don't show up in vim.keymap
function M.normalize_keymaps(user_keymaps)
  local normalized = vim.deepcopy(user_keymaps or {})

  -- Add built-in keymaps to the normalized set
  for mode, mode_builtins in pairs(builtin_keymaps) do
    if not normalized[mode] then
      normalized[mode] = {}
    end
    for key, builtin_info in pairs(mode_builtins) do
      if not normalized[mode][key] then
        normalized[mode][key] = {
          mode = mode,
          key = key,
          action = builtin_info.action,
          opts = { desc = builtin_info.desc },
          builtin = true,
        }
      end
    end
  end

  return normalized
end

-- Conflict detection engine
function M.detect_conflicts(keymaps, include_builtins)
  include_builtins = include_builtins ~= false -- default true

  local conflicts = {}
  local key_usage = {}

  -- Optionally include built-in keymaps
  if include_builtins then
    local builtins = M.get_builtin_keymaps()
    for mode, mode_builtins in pairs(builtins) do
      if not key_usage[mode] then
        key_usage[mode] = {}
      end
      for key, builtin_info in pairs(mode_builtins) do
        key_usage[mode][key] = {
          mode = mode,
          key = key,
          action = builtin_info.action,
          opts = { desc = builtin_info.desc },
          source = { file = "vim-builtin", line = 0 },
          builtin = true,
        }
      end
    end
  end

  -- Check user keymaps for conflicts
  for _, keymap in ipairs(keymaps) do
    if not key_usage[keymap.mode] then
      key_usage[keymap.mode] = {}
    end

    if key_usage[keymap.mode][keymap.key] then
      local existing = key_usage[keymap.mode][keymap.key]
      local conflict_type = existing.builtin and "builtin-override" or "duplicate"

      table.insert(conflicts, {
        mode = keymap.mode,
        key = keymap.key,
        first = existing,
        duplicate = keymap,
        type = conflict_type,
        builtin_override = existing.builtin or false,
      })
    else
      key_usage[keymap.mode][keymap.key] = keymap
    end
  end

  return conflicts
end

-- ============================================================================
-- LIL.NVIM INTROSPECTION COMPATIBILITY
-- ============================================================================

-- Collector function that captures keymap data instead of setting keymaps
local function keymap_collector(mode, key, action, opts, context)
  table.insert(collected_keymaps, {
    mode = mode,
    key = key,
    action = action,
    opts = opts or {},
    context = context or {},
  })
end

-- Create custom config that uses our collector (when lil is available)
function M.create_introspect_config()
  local lil_utils = get_lil_utils()
  if not lil_utils then
    return nil
  end

  local lil_core = require("lil.core")
  local lil_defaults = require("lil.config")

  local introspect_config = vim.tbl_deep_extend("force", lil_defaults, {
    [lil_utils.flags.func] = keymap_collector,
  })

  return function(map)
    return lil_core(introspect_config, "", map)
  end
end

-- Public API for introspection
function M.get_flat_keymaps_table()
  return collected_keymaps
end

function M.clear_collected_keymaps()
  collected_keymaps = {}
end

function M.get_keymap_count()
  return #collected_keymaps
end

-- Export lil interface that uses introspection (when available)
function M.create_lil_interface()
  local lil_utils = get_lil_utils()
  if not lil_utils then
    return {}
  end

  local lil = require("lil")
  return {
    map = M.create_introspect_config(),
    flags = lil_utils.flags,
    mod = lil.mod,
    key = lil.key,
    keys = lil.keys,
    modes = lil.modes,
  }
end

-- Export utilities for compatibility
function M.get_lil_flags()
  local lil_utils = get_lil_utils()
  if not lil_utils then
    return {}
  end
  return {
    func = lil_utils.flags.func,
    opts = lil_utils.flags.opts,
    mode = lil_utils.flags.mode,
  }
end

return M
