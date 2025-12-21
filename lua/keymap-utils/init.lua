-- Keymap Utilities - Clean keymap management and inspection
-- Provides both simple vim.keymap.set wrappers and lil-style declarative mapping

local M = {}
local collected_keymaps = {}
local group_descriptions = {}
local disabled_keymaps = {}
local keymap_tree = {} -- Hierarchical tree of keymaps registered via keymap-utils

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
-- Keymap definition: { "action", desc = "..." } or { rhs = "action", desc = "..." } or { cmd = "...", desc = "..." }
-- Group: { a = {...}, b = {...} } with only nested tables
local function is_keymap_definition(t)
  return t[1] ~= nil or t.rhs ~= nil or t.cmd ~= nil
end

-- Create smart wrapper around kmu_map that auto-extracts group descriptions
-- and transforms simple table syntax into core-compatible format
--
-- Mental model:
--   h = { "h", desc = "Left" }              -- shorthand: action at [1]
--   h = { rhs = "h", desc = "Left" }        -- explicit: using rhs
--   h = { rhs = fn, desc = "Do something" } -- function as action
--   h = { cmd = "Neogit", desc = "Open" }   -- command: becomes <Cmd>Neogit<CR>
--   h = { cmd = "Octo ", exec = false }     -- prefill only: becomes :Octo
--   h = { "h", desc = "Left", del = "j" }   -- also delete key 'j'
--   h = { "h", desc = "Left", expr = true } -- with vim keymap options
--
-- Nesting works infinitely:
--   ["<leader>g"] = {
--     group = "Git",  -- which-key group name
--     n = { cmd = "Neogit", desc = "Open Neogit" },
--     d = {
--       group = "Diff",
--       o = { cmd = "DiffviewOpen", desc = "Open" },
--     },
--   }
function M.create_smart_map()
  local kmu_opts_flag = kmu_utils.flags.opts
  local kmu_func_flag = kmu_utils.flags.func
  local kmu_disabled_flag = kmu_utils.flags.disabled

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
    -- Capture source location of the map() call for jump-to-definition
    local source_info = debug.getinfo(2, "Sl")
    local source_file = source_info and source_info.source and source_info.source:sub(2) or nil
    local source_line = source_info and source_info.currentline or nil

    -- Track visited tables to prevent infinite recursion
    local visited = {}
    -- Track current mode context (cascades to children)
    local current_modes = { "n" }
    -- Track current disabled state (cascades to children)
    local current_disabled = false

    -- Helper to insert a node into the keymap tree
    -- path_parts: array of key segments leading to this node
    -- node_data: the metadata for this node
    local function insert_into_tree(path_parts, node_data)
      local current = keymap_tree
      for i, part in ipairs(path_parts) do
        if not current[part] then
          current[part] = { _meta = nil }
        end
        if i == #path_parts then
          -- Final node - set metadata
          current[part]._meta = node_data
        else
          -- Intermediate node - traverse
          current = current[part]
        end
      end
    end

    -- Process tables recursively to transform syntax and extract groups
    -- groups_path: array of {key_part, group_name} for parent groups
    local function process_table(prefix, t, path_parts, groups_path)
      if visited[t] then
        return
      end
      visited[t] = true

      path_parts = path_parts or {}
      groups_path = groups_path or {}

      -- Check for mode specification at this level (cascades)
      local mode_flag = kmu_utils.flags.mode
      if t[mode_flag] then
        current_modes = t[mode_flag]
      end

      -- Check for disabled flag at this level (cascades)
      if t[kmu_disabled_flag] ~= nil then
        current_disabled = t[kmu_disabled_flag]
      end

      for key, value in pairs(t) do
        -- Only process string keys (skip kmu flags)
        if type(key) == "string" and type(value) == "table" then
          local full_key = prefix .. key
          local new_path = vim.list_extend({}, path_parts)
          table.insert(new_path, key)

          if is_keymap_definition(value) then
            -- Transform simple table syntax to core-compatible format
            -- { "action", desc = "...", expr = true } → { "action", [opts] = { desc, expr } }
            local action = value[1] or value.rhs
            -- Handle cmd = "..." syntax
            if value.cmd then
              if value.exec == false then
                -- Prefill only, no execution
                action = ":" .. value.cmd
              else
                -- Execute command
                action = "<Cmd>" .. value.cmd .. "<CR>"
              end
            end
            -- Combine cascaded disabled with individual disabled = true
            local is_disabled = current_disabled or value.disabled == true
            local keymap_opts = {
              desc = value.desc,
              expr = value.expr,
              silent = value.silent,
              noremap = value.noremap,
              buffer = value.buffer,
              nowait = value.nowait,
              remap = value.remap,
            }

            -- Build groups array from groups_path
            local groups = {}
            for _, gp in ipairs(groups_path) do
              if gp.group then
                table.insert(groups, gp.group)
              end
            end

            -- Insert into tree for each mode
            for _, mode in ipairs(current_modes) do
              insert_into_tree(new_path, {
                type = "keymap",
                mode = mode,
                key = full_key,
                key_part = key,
                desc = value.desc,
                action = action,
                icon = value.icon,
                groups = groups,
                disabled = is_disabled,
                opts = keymap_opts,
                source_file = source_file,
                source_line = source_line,
              })

              -- Also store disabled keymaps in flat collection
              if is_disabled then
                table.insert(disabled_keymaps, {
                  mode = mode,
                  key = full_key,
                  action = action,
                  desc = value.desc,
                  icon = value.icon,
                  disabled = true,
                  groups = groups,
                  source_file = source_file,
                  source_line = source_line,
                })
              end
            end

            if is_disabled then
              value[kmu_disabled_flag] = true
            end

            -- Store 'del' in the table for func_map to access via _next
            if value.del then
              value.del = value.del -- keep it for _next context
            end

            -- Clear the named keys and set core-compatible format
            value[1] = action
            value.rhs = nil
            value.cmd = nil
            value.exec = nil
            value.desc = nil
            value.expr = nil
            value.silent = nil
            value.noremap = nil
            value.buffer = nil
            value.nowait = nil
            value.remap = nil
            value.disabled = nil
            value.icon = nil
            value[kmu_opts_flag] = keymap_opts
          else
            -- It's a group - check for group description
            local group_name = value.group
            local new_groups_path = vim.list_extend({}, groups_path)

            if group_name then
              local group_icon = value.icon
              table.insert(group_descriptions, { full_key, group = group_name, icon = group_icon })
              table.insert(new_groups_path, { key = full_key, key_part = key, group = group_name, icon = group_icon })

              -- Insert group node into tree
              insert_into_tree(new_path, {
                type = "group",
                key = full_key,
                key_part = key,
                group = group_name,
                icon = group_icon,
                modes = current_modes,
              })

              value.group = nil -- remove so it doesn't interfere with recursion
              value.icon = nil -- remove so it doesn't interfere with recursion
            end

            -- Recurse into nested tables
            process_table(full_key, value, new_path, new_groups_path)
          end
        end
      end
    end

    process_table("", map_def, {}, {})

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

-- Get collected group descriptions (for export/inspection)
function M.get_group_descriptions()
  return group_descriptions
end

-- Get disabled keymaps (for inspection/printing)
function M.get_disabled_keymaps()
  return disabled_keymaps
end

-- Clear disabled keymaps (for testing)
function M.clear_disabled_keymaps()
  disabled_keymaps = {}
end

-- Get keymap tree (hierarchical structure of keymap-utils keymaps)
function M.get_keymap_tree()
  return keymap_tree
end

-- Clear keymap tree (for testing)
function M.clear_keymap_tree()
  keymap_tree = {}
end

-- Flatten the keymap tree into a list of items for display
-- Returns items with depth info for tree-like rendering
function M.flatten_keymap_tree(tree, depth, parent_key)
  tree = tree or keymap_tree
  depth = depth or 0
  parent_key = parent_key or ""

  local items = {}

  -- Sort keys for consistent ordering
  local keys = {}
  for k in pairs(tree) do
    if k ~= "_meta" then
      table.insert(keys, k)
    end
  end
  table.sort(keys)

  for _, key in ipairs(keys) do
    local node = tree[key]
    local meta = node._meta

    if meta then
      local item = {
        depth = depth,
        key_part = key,
        key = meta.key or (parent_key .. key),
        type = meta.type,
        mode = meta.mode or (meta.modes and meta.modes[1]) or "n",
        desc = meta.desc,
        group = meta.group,
        action = meta.action,
        disabled = meta.disabled,
        groups = meta.groups or {},
        has_children = false,
      }

      -- Check if this node has children (other than _meta)
      for k in pairs(node) do
        if k ~= "_meta" then
          item.has_children = true
          break
        end
      end

      table.insert(items, item)

      -- Recursively add children
      local children = M.flatten_keymap_tree(node, depth + 1, meta.key or (parent_key .. key))
      for _, child in ipairs(children) do
        table.insert(items, child)
      end
    end
  end

  return items
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
function M.create_inspect_config()
  local inspect_config = kmu_utils.copy(kmu_core.config)
  inspect_config[kmu_utils.flags.func] = keymap_collector

  return function(map)
    return kmu_core.builtin(inspect_config, "", map)
  end
end

-- Public API for inspection
function M.get_flat_keymaps_table()
  return collected_keymaps
end

function M.clear_collected_keymaps()
  collected_keymaps = {}
end

function M.get_keymap_count()
  return #collected_keymaps
end

-- Export interface that uses inspection
function M.create_inspect_interface()
  return {
    map = M.create_inspect_config(),
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
    log = kmu_utils.flags.log,
    disabled = kmu_utils.flags.disabled,
    raw = kmu_utils.flags.raw,
  }
end

-- ============================================================================
-- KEYMAP INSPECTION (Snacks Picker Integration)
-- ============================================================================

-- Lazy-load inspect module
local inspect_module = nil
local function get_inspect_module()
  if not inspect_module then
    inspect_module = require("keymap-utils.inspect")
  end
  return inspect_module
end

-- Setup KMUInspect command
function M.setup_inspect()
  get_inspect_module().setup()
end

-- Open keymaps picker directly
function M.inspect(opts)
  get_inspect_module().open(opts)
end

-- Direct flag exports for convenience
-- Usage: local disabled = kmu.disabled
M.disabled = kmu_utils.flags.disabled
M.mode = kmu_utils.flags.mode

return M
