-- Keymap Utilities - Clean keymap management and introspection
-- Provides both simple vim.keymap.set wrappers and lil-style declarative mapping

local M = {}
local collected_keymaps = {}
local group_descriptions = {}

-- Import local keymap-utils modules
local kmu_core = require("keymap-utils.core")
local kmu_key = require("keymap-utils.key")
local kmu_utils = require("keymap-utils.utils")

-- ============================================================================
-- KEYMAP-UTILS API EXPORTS
-- ============================================================================

-- Export flags for direct access
M.flags = kmu_utils.flags

-- Export key constructor for modifier keys like ctrl, shift, alt
M.key = kmu_key

-- Export _ (expects template) for <C-_> style mappings
M._ = kmu_key({ expects = true })

-- Mode modifier constructor
-- Usage: local n = lil.mod("n") then [n] = { ... }
function M.mod(mode_char)
  return { mode = { mode_char } }
end

-- Modes table for convenience
M.modes = {
  n = { mode = { "n" } },
  v = { mode = { "v" } },
  x = { mode = { "x" } },
  i = { mode = { "i" } },
  c = { mode = { "c" } },
  o = { mode = { "o" } },
  t = { mode = { "t" } },
}

-- Main declarative map function
M.kmu_map = kmu_core.map

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

-- Check if a table is a keymap definition (has action) vs a group (nested keymaps)
-- Keymap definition: { "action", desc = "..." } or { rhs = "action", desc = "..." }
-- Group: { a = {...}, b = {...} } with only nested tables
local function is_keymap_definition(t)
  return t[1] ~= nil or t.rhs ~= nil
end

-- Create smart wrapper around kmu_map that auto-extracts group descriptions
-- and transforms simple table syntax into core-compatible format
--
-- Mental model:
--   h = { "h", desc = "Left" }              -- shorthand: action at [1]
--   h = { rhs = "h", desc = "Left" }        -- explicit: using rhs
--   h = { rhs = fn, desc = "Do something" } -- function as action
--   h = { "h", desc = "Left", del = "j" }   -- also delete key 'j'
--   h = { "h", desc = "Left", expr = true } -- with vim keymap options
--
-- Nesting works infinitely:
--   ["<leader>g"] = {
--     group = "Git",  -- which-key group name
--     n = { ":Neogit", desc = "Open Neogit" },
--     d = {
--       group = "Diff",
--       o = { ":DiffviewOpen", desc = "Open" },
--     },
--   }
function M.create_smart_map()
  local kmu_opts_flag = kmu_utils.flags.opts
  local kmu_func_flag = kmu_utils.flags.func

  -- Define func_map that handles 'del' option
  local function func_map(m, l, r, o, _next)
    -- Delete the target key first
    M.safe_del(m, l)
    -- Also delete 'del' key if specified (stored in _next context)
    if _next and _next.del then
      M.safe_del(m, _next.del)
    end
    vim.keymap.set(m, l, r, o)
  end

  return function(map_def)
    -- Track visited tables to prevent infinite recursion
    local visited = {}

    -- Process tables recursively to transform syntax and extract groups
    local function process_table(prefix, t)
      if visited[t] then
        return
      end
      visited[t] = true

      for key, value in pairs(t) do
        -- Only process string keys (skip kmu flags)
        if type(key) == "string" and type(value) == "table" then
          local full_key = prefix .. key

          if is_keymap_definition(value) then
            -- Transform simple table syntax to core-compatible format
            -- { "action", desc = "...", expr = true } → { "action", [opts] = { desc, expr } }
            local action = value[1] or value.rhs
            local keymap_opts = {
              desc = value.desc,
              expr = value.expr,
              silent = value.silent,
              noremap = value.noremap,
              buffer = value.buffer,
              nowait = value.nowait,
              remap = value.remap,
            }

            -- Store 'del' in the table for func_map to access via _next
            if value.del then
              value.del = value.del -- keep it for _next context
            end

            -- Clear the named keys and set core-compatible format
            value[1] = action
            value.rhs = nil
            value.desc = nil
            value.expr = nil
            value.silent = nil
            value.noremap = nil
            value.buffer = nil
            value.nowait = nil
            value.remap = nil
            value[kmu_opts_flag] = keymap_opts
          else
            -- It's a group - check for group description
            if value.group then
              table.insert(group_descriptions, { full_key, group = value.group })
              value.group = nil -- remove so it doesn't interfere with recursion
            end
            -- Recurse into nested tables
            process_table(full_key, value)
          end
        end
      end
    end

    process_table("", map_def)

    -- Auto-inject [func] = func_map if not already present
    if not map_def[kmu_func_flag] then
      map_def[kmu_func_flag] = func_map
    end

    -- Call kmu_core.map
    kmu_core.map(map_def)
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
-- INTROSPECTION COMPATIBILITY
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

-- Create custom config that uses our collector
function M.create_introspect_config()
  local introspect_config = kmu_utils.copy(kmu_core.config)
  introspect_config[kmu_utils.flags.func] = keymap_collector

  return function(map)
    return kmu_core.builtin(introspect_config, "", map)
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

-- Export interface that uses introspection
function M.create_introspect_interface()
  return {
    map = M.create_introspect_config(),
    flags = kmu_utils.flags,
    mod = M.mod,
    key = M.key,
    modes = M.modes,
  }
end

-- Export utilities for compatibility
function M.get_flags()
  return {
    func = kmu_utils.flags.func,
    opts = kmu_utils.flags.opts,
    mode = kmu_utils.flags.mode,
  }
end

return M
