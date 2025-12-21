-- KMUInspect - Display keymaps using Snacks picker with native tree support
-- Supports tree view for keymap-utils keymaps and flat list for all keymaps
-- Disabled keymaps are prefixed with '*'
-- Groups can be expanded/collapsed with h/i or <CR>

local M = {}

-- Track open/closed state of groups (persists across picker refreshes)
-- Keys are group keys like "<leader>g", values are boolean (true = open)
local open_state = {}

--- Reset all groups to expanded (call to reset state)
function M.reset_open_state()
  open_state = {}
end

--- Default options for the keymaps picker
---@class KMUInspectOpts
---@field modes? string[] Modes to include (default: all)
---@field global? boolean Include global keymaps (default: true)
---@field local? boolean Include buffer-local keymaps (default: false)
---@field plugs? boolean Include <Plug> mappings (default: false)
---@field with_desc? boolean Only show keymaps with descriptions (default: false)
---@field kmu_only? boolean Only show keymaps registered through keymap-utils (default: false)
---@field tree? boolean Show as tree view (default: true when kmu_only)
local defaults = {
  modes = { "n", "i", "v", "x", "o", "c", "t" },
  global = true,
  ["local"] = false,
  plugs = false,
  with_desc = false,
  kmu_only = false,
  tree = nil, -- nil means auto (tree for kmu_only, flat otherwise)
}

--- Collect all keymaps (active + disabled) for flat display
---@param opts KMUInspectOpts
---@return snacks.picker.finder.Item[]
local function collect_flat_keymaps(opts)
  local items = {}
  local maps = {}
  local done = {}

  -- Collect active keymaps from vim.api
  for _, mode in ipairs(opts.modes) do
    if opts.global then
      vim.list_extend(maps, vim.api.nvim_get_keymap(mode))
    end
    if opts["local"] then
      vim.list_extend(maps, vim.api.nvim_buf_get_keymap(0, mode))
    end
  end

  -- Process active keymaps
  for _, km in ipairs(maps) do
    local key = string.format("%s:%s:%s", km.mode, km.lhs, km.buffer or 0)
    local keep = true

    -- Filter <Plug> mappings
    if opts.plugs == false and km.lhs:match("^<Plug>") then
      keep = false
    end

    -- Filter keymaps without descriptions
    if opts.with_desc and (not km.desc or km.desc == "") then
      keep = false
    end

    if keep and not done[key] then
      done[key] = true

      local item = {
        mode = km.mode,
        item = km,
        key = km.lhs,
        desc = km.desc or "",
        disabled = false,
        type = "keymap",
        source = "vim",
        preview = {
          text = vim.inspect(km),
          ft = "lua",
        },
      }

      -- Try to get source file/line for function callbacks
      if km.callback then
        local ok, info = pcall(debug.getinfo, km.callback, "S")
        if ok and info then
          item.info = info
          if info.what == "Lua" then
            local source = info.source:sub(2)
            item.file = source:gsub("^vim/", vim.env.VIMRUNTIME .. "/lua/vim/")
            if not (source:find("^vim/") and info.linedefined == 0) then
              item.pos = { info.linedefined, 0 }
            end
            item.preview = "file"
          end
        end
      end

      -- Build searchable text (include both desc AND rhs for search)
      local normkey = km.lhs:gsub("<", ""):gsub(">", "")
      item.text = string.format("%s [%s] %s %s", normkey, km.mode, km.desc or "", km.rhs or "")

      items[#items + 1] = item
    end
  end

  -- Add disabled keymaps from keymap-utils
  local kmu = require("keymap-utils")
  local disabled_keymaps = kmu.get_disabled_keymaps()

  for _, dk in ipairs(disabled_keymaps) do
    -- Check if mode is in requested modes
    local mode_match = false
    for _, m in ipairs(opts.modes) do
      if dk.mode == m then
        mode_match = true
        break
      end
    end

    if mode_match then
      local key = string.format("%s:%s:0", dk.mode, dk.key)
      if not done[key] then
        done[key] = true

        local action_str = ""
        if type(dk.action) == "function" then
          action_str = "<function>"
        elseif type(dk.action) == "string" then
          action_str = dk.action
        end

        local item = {
          mode = dk.mode,
          key = dk.key,
          desc = dk.desc or "",
          action = dk.action, -- Include action for formatting
          disabled = true,
          type = "keymap",
          source = "keymap-utils",
          groups = dk.groups or {},
          item = dk,
          preview = {
            text = vim.inspect(dk),
            ft = "lua",
          },
        }

        -- Add source file/line for jump-to-definition
        if dk.source_file then
          item.file = dk.source_file
          if dk.source_line then
            item.pos = { dk.source_line, 0 }
          end
          item.preview = "file"
        end

        -- Build searchable text with action AND description for search
        local normkey = dk.key:gsub("<", ""):gsub(">", "")
        item.text = string.format("%s [%s] %s %s", normkey, dk.mode, dk.desc or "", action_str)

        items[#items + 1] = item
      end
    end
  end

  -- Sort by key
  table.sort(items, function(a, b)
    if a.disabled ~= b.disabled then
      return not a.disabled -- active first
    end
    if a.mode ~= b.mode then
      return a.mode < b.mode
    end
    return a.key < b.key
  end)

  return items
end

--- Check if a node has children (other than _meta)
---@param node table
---@return boolean
local function has_children(node)
  for k in pairs(node) do
    if k ~= "_meta" then
      return true
    end
  end
  return false
end

--- Collect keymaps from keymap-utils tree with proper parent references for Snacks tree
---@param opts KMUInspectOpts
---@return snacks.picker.finder.Item[]
local function collect_tree_keymaps(opts)
  local kmu = require("keymap-utils")
  local tree = kmu.get_keymap_tree()

  local items = {}
  local item_map = {} -- Map from node path to item for parent lookups

  --- Recursively process tree nodes
  ---@param node table The tree node
  ---@param parent_item? snacks.picker.finder.Item Parent item object
  ---@param parent_key string Parent key prefix
  local function process_node(node, parent_item, parent_key)
    -- Sort keys for consistent ordering
    local keys = {}
    for k in pairs(node) do
      if k ~= "_meta" then
        table.insert(keys, k)
      end
    end
    table.sort(keys)

    -- Process each child
    for idx, key in ipairs(keys) do
      local child = node[key]
      local meta = child._meta
      local is_last = idx == #keys
      local full_key = parent_key .. key
      local node_has_children = has_children(child)

      if meta then
        -- Node has metadata - process it
        local mode = meta.mode or (meta.modes and meta.modes[1]) or "n"
        local mode_match = false
        for _, m in ipairs(opts.modes) do
          if mode == m then
            mode_match = true
            break
          end
        end

        if mode_match then
          full_key = meta.key or full_key
          local is_group = meta.type == "group"

          -- For groups, check open state (default to open/true)
          local is_open = true
          if is_group and node_has_children then
            is_open = open_state[full_key] ~= false -- default open
          end

          local item = {
            mode = mode,
            key = full_key,
            key_part = meta.key_part or key,
            desc = meta.desc or meta.group or "",
            disabled = meta.disabled or false,
            type = meta.type,
            group = meta.group,
            groups = meta.groups or {},
            action = meta.action,
            source = "keymap-utils",
            parent = parent_item, -- Reference to parent item object
            last = is_last, -- For tree line drawing
            open = is_open, -- For expand/collapse
            has_children = node_has_children,
            preview = {
              text = vim.inspect(meta),
              ft = "lua",
            },
          }

          -- Get source file/line for file preview
          -- First try: callback debug info (most accurate for function actions)
          -- Second try: stored source_file/source_line from keymap definition
          if meta.type == "keymap" then
            local got_source = false
            if not meta.disabled then
              local km = vim.fn.maparg(item.key, mode, false, true)
              if km and km.callback then
                local ok, info = pcall(debug.getinfo, km.callback, "S")
                if ok and info and info.what == "Lua" then
                  local source = info.source:sub(2)
                  item.file = source:gsub("^vim/", vim.env.VIMRUNTIME .. "/lua/vim/")
                  if not (source:find("^vim/") and info.linedefined == 0) then
                    item.pos = { info.linedefined, 0 }
                  end
                  item.preview = "file"
                  got_source = true
                end
              end
            end
            -- Fallback to stored source info from keymap-utils
            if not got_source and meta.source_file then
              item.file = meta.source_file
              if meta.source_line then
                item.pos = { meta.source_line, 0 }
              end
              item.preview = "file"
            end
          end

          -- Build searchable text (include action for command search)
          local prefix = item.disabled and "*" or ""
          local display = item.type == "group" and item.group or item.desc
          local action_str = meta.action or ""
          item.text = string.format("%s%s [%s] %s %s", prefix, item.key, mode, display or "", action_str)

          items[#items + 1] = item
          item_map[item.key] = item

          -- Only recurse into children if group is open
          if is_open then
            process_node(child, item, full_key)
          end
        end
      elseif node_has_children then
        -- No metadata but has children - traverse into them (implicit group)
        process_node(child, parent_item, full_key)
      end
    end
  end

  process_node(tree, nil, "")

  return items
end

--- Format RHS/action like Snacks does (with syntax highlighting)
---@param item snacks.picker.finder.Item
---@param ret snacks.picker.Highlight[]
local function format_rhs(item, ret)
  local action = item.action
  -- Handle function callbacks
  if type(action) == "function" or not action or action == "" then
    ret[#ret + 1] = { "callback", "Function" }
    return 8
  end

  local rhs_len = #action
  local rhs = tostring(action)
  local cmd = rhs:lower():find("<cmd>")

  if cmd then
    ret[#ret + 1] = { rhs:sub(1, cmd + 4), "NonText" }
    rhs = rhs:sub(cmd + 5)
    local cr = rhs:lower():find("<cr>$")
    if cr then
      rhs = rhs:sub(1, cr - 1)
    end
    ret[#ret + 1] = { rhs, "SnacksPickerKeymapRhs" }
    if cr then
      ret[#ret + 1] = { "<CR>", "NonText" }
    end
  elseif rhs:lower():find("^<plug>") then
    ret[#ret + 1] = { "<Plug>", "NonText" }
    local plug = rhs:sub(7):gsub("^%(", ""):gsub("%)$", "")
    ret[#ret + 1] = { "(", "SnacksPickerDelim" }
    ret[#ret + 1] = { plug, "SnacksPickerKeymapRhs" }
    ret[#ret + 1] = { ")", "SnacksPickerDelim" }
  else
    ret[#ret + 1] = { rhs, "SnacksPickerKeymapRhs" }
  end

  return rhs_len
end

--- Custom formatter for keymap items (tree view) using Snacks native tree
---@param item snacks.picker.finder.Item
---@param picker snacks.Picker
---@return snacks.picker.Highlight[]
local function format_tree_keymap(item, picker)
  local ret = {} ---@type snacks.picker.Highlight[]
  local a = Snacks.picker.util.align

  -- Disabled items use dimmed highlight throughout
  local disabled_hl = "Comment"

  -- Use Snacks native tree formatting for indent/tree lines
  if item.parent then
    vim.list_extend(ret, require("snacks.picker.format").tree(item, picker))
  end

  -- Icon/prefix for groups vs keymaps
  if item.disabled then
    ret[#ret + 1] = { "○ ", disabled_hl }
  elseif item.type == "group" and item.has_children then
    local icon = item.open and "▼ " or "▶ "
    ret[#ret + 1] = { icon, "Special" }
  elseif item.type == "group" then
    ret[#ret + 1] = { "○ ", "Special" }
  else
    ret[#ret + 1] = { "  ", "Normal" }
  end

  -- Mode
  local mode_hl = item.disabled and disabled_hl or "SnacksPickerKeymapMode"
  ret[#ret + 1] = { item.mode or "n", mode_hl }
  ret[#ret + 1] = { " " }

  -- Key (show key_part for tree, aligned)
  local key_display = item.key_part or item.key or ""
  local key_hl = item.disabled and disabled_hl or (item.type == "group" and "Directory" or "SnacksPickerKeymapLhs")
  ret[#ret + 1] = { a(key_display, 12), key_hl }
  ret[#ret + 1] = { " " }

  -- For groups, show group name
  if item.type == "group" then
    local group_hl = item.disabled and disabled_hl or "Title"
    ret[#ret + 1] = { item.group or "", group_hl }
    return ret
  end

  -- RHS/Command (use dimmed for disabled)
  if item.disabled then
    local action = item.action
    local rhs_str = type(action) == "function" and "callback" or (action or "")
    ret[#ret + 1] = { a(rhs_str, 20), disabled_hl }
  else
    local rhs_len = format_rhs(item, ret)
    if rhs_len < 20 then
      ret[#ret + 1] = { (" "):rep(20 - rhs_len) }
    end
  end
  ret[#ret + 1] = { " " }

  -- Description
  if item.desc and item.desc ~= "" then
    ret[#ret + 1] = { item.desc, item.disabled and disabled_hl or "SnacksPickerKeymapDesc" }
  end

  return ret
end

--- Custom formatter for keymap items (flat view) - matches Snacks keymaps style
---@param item snacks.picker.finder.Item
---@param picker snacks.Picker
---@return snacks.picker.Highlight[]
local function format_flat_keymap(item, picker)
  local ret = {} ---@type snacks.picker.Highlight[]
  local a = Snacks.picker.util.align

  -- Disabled items use dimmed highlight throughout
  local disabled_hl = "Comment"

  -- Which-key icon (if available)
  if package.loaded["which-key"] then
    local icons_ok, Icons = pcall(require, "which-key.icons")
    if icons_ok then
      local km = item.item or {}
      -- Ensure lhs is set for which-key parsing
      if not km.lhs then
        km = { lhs = item.key or "", desc = item.desc or "" }
      end
      local get_ok, icon, hl = pcall(Icons.get, { keymap = km, desc = km.desc })
      if get_ok and icon then
        local icon_hl = item.disabled and disabled_hl or hl
        ret[#ret + 1] = { a(icon, 3), icon_hl }
      else
        ret[#ret + 1] = { "   " }
      end
    else
      ret[#ret + 1] = { "   " }
    end
  else
    ret[#ret + 1] = { "   " }
  end

  -- Disabled indicator (hollow circle instead of *)
  if item.disabled then
    ret[#ret + 1] = { "○", disabled_hl }
  else
    ret[#ret + 1] = { " " }
  end

  -- Mode
  local mode_hl = item.disabled and disabled_hl or "SnacksPickerKeymapMode"
  ret[#ret + 1] = { item.mode or "n", mode_hl }
  ret[#ret + 1] = { " " }

  -- Key (aligned)
  local key_hl = item.disabled and disabled_hl or "SnacksPickerKeymapLhs"
  ret[#ret + 1] = { a(item.key or "", 15), key_hl }
  ret[#ret + 1] = { " " }

  -- Nowait icon
  local icon_nowait = picker.opts.icons and picker.opts.icons.keymaps and picker.opts.icons.keymaps.nowait or "󰓅 "
  local km = item.item or {}
  if km.nowait == 1 then
    local nowait_hl = item.disabled and disabled_hl or "SnacksPickerKeymapNowait"
    ret[#ret + 1] = { icon_nowait, nowait_hl }
  else
    ret[#ret + 1] = { (" "):rep(vim.api.nvim_strwidth(icon_nowait)) }
  end
  ret[#ret + 1] = { " " }

  -- Buffer indicator
  if km.buffer and km.buffer > 0 then
    local buf_hl = item.disabled and disabled_hl or "SnacksPickerBufNr"
    ret[#ret + 1] = { a("buf:" .. km.buffer, 6), buf_hl }
  else
    ret[#ret + 1] = { a("", 6) }
  end
  ret[#ret + 1] = { " " }

  -- RHS/Command (use dimmed for disabled)
  if item.disabled then
    local action = item.action or (km.rhs and km.rhs or "")
    local rhs_str = type(action) == "function" and "callback" or (action or "")
    ret[#ret + 1] = { a(rhs_str, 20), disabled_hl }
  else
    local action = item.action or (km.rhs and km.rhs or "")
    local temp_item = { action = action }
    local rhs_len = format_rhs(temp_item, ret)
    if rhs_len < 20 then
      ret[#ret + 1] = { (" "):rep(20 - rhs_len) }
    end
  end
  ret[#ret + 1] = { " " }

  -- Description
  if item.desc and item.desc ~= "" then
    ret[#ret + 1] = { item.desc, item.disabled and disabled_hl or "SnacksPickerKeymapDesc" }
  end

  return ret
end

--- Build preview text for a keymap item
---@param item snacks.picker.finder.Item
---@return string
local function build_preview_text(item)
  local lines = {}

  table.insert(
    lines,
    "╭─ Keymap Details ─────────────────────────────────────╮"
  )
  table.insert(lines, string.format("│ Key:         %-40s │", item.key or ""))
  table.insert(lines, string.format("│ Mode:        %-40s │", item.mode or "n"))

  if item.desc and item.desc ~= "" then
    local desc = item.desc
    if #desc > 40 then
      desc = desc:sub(1, 37) .. "..."
    end
    table.insert(lines, string.format("│ Description: %-40s │", desc))
  end

  if item.type == "group" then
    table.insert(lines, string.format("│ Type:        %-40s │", "Group"))
    table.insert(lines, string.format("│ Group:       %-40s │", item.group or ""))
  else
    table.insert(lines, string.format("│ Type:        %-40s │", "Keymap"))
  end

  if item.action then
    local action_str = type(item.action) == "string" and item.action or "<function>"
    if #action_str > 40 then
      action_str = action_str:sub(1, 37) .. "..."
    end
    table.insert(lines, string.format("│ Action:      %-40s │", action_str))
  end

  table.insert(lines, string.format("│ Source:      %-40s │", item.source or "vim"))
  table.insert(lines, string.format("│ Disabled:    %-40s │", item.disabled and "Yes" or "No"))

  if item.groups and #item.groups > 0 then
    table.insert(lines, string.format("│ Groups:      %-40s │", table.concat(item.groups, " > ")))
  end

  if item.file then
    local file = vim.fn.fnamemodify(item.file, ":~:.")
    if #file > 40 then
      file = "..." .. file:sub(-37)
    end
    table.insert(lines, string.format("│ File:        %-40s │", file))
    if item.pos then
      table.insert(lines, string.format("│ Line:        %-40s │", item.pos[1]))
    end
  end

  table.insert(
    lines,
    "╰──────────────────────────────────────────────────────╯"
  )

  -- Add raw data section
  table.insert(lines, "")
  table.insert(lines, "-- Raw data:")
  table.insert(lines, vim.inspect(item.item or item))

  return table.concat(lines, "\n")
end

--- Open the keymaps picker
---@param opts? KMUInspectOpts
function M.open(opts)
  local ok, Snacks = pcall(require, "snacks")
  if not ok then
    vim.notify("KMUInspect requires snacks.nvim", vim.log.levels.ERROR)
    return
  end

  opts = vim.tbl_extend("force", defaults, opts or {})

  -- Determine view mode
  local use_tree = opts.tree
  if use_tree == nil then
    use_tree = opts.kmu_only -- Auto tree view for kmu_only
  end

  local items
  local formatter
  local title_suffix

  if opts.kmu_only or use_tree then
    items = collect_tree_keymaps(opts)
    formatter = format_tree_keymap
    title_suffix = "keymap-utils"
  else
    items = collect_flat_keymaps(opts)
    formatter = format_flat_keymap
    title_suffix = "all"
  end

  local disabled_count = 0
  local group_count = 0
  local keymap_count = 0

  for _, item in ipairs(items) do
    if item.disabled then
      disabled_count = disabled_count + 1
    end
    if item.type == "group" then
      group_count = group_count + 1
    else
      keymap_count = keymap_count + 1
    end
  end

  local title
  if use_tree then
    title = string.format(
      "Keymaps [%s] (%d groups, %d keymaps, %d disabled)",
      title_suffix,
      group_count,
      keymap_count,
      disabled_count
    )
  else
    title =
      string.format("Keymaps [%s] (%d active, %d disabled)", title_suffix, #items - disabled_count, disabled_count)
  end

  Snacks.picker({
    name = "keymaps",
    title = title,
    items = items,
    format = formatter,
    preview = function(ctx)
      local item = ctx.item
      -- Use Snacks' built-in previewers
      local previewers = require("snacks.picker.preview")
      if item.preview == "file" and item.file then
        -- File preview - show the source file
        previewers.file(ctx)
      else
        -- Fallback to custom text preview
        previewers.preview(ctx)
      end
    end,
    actions = {
      -- Expand group (right/i)
      expand = function(picker, item)
        if item.type == "group" and item.has_children and not item.open then
          open_state[item.key] = true
          picker:find()
        end
      end,
      -- Collapse group (left/h)
      collapse = function(picker, item)
        if item.type == "group" and item.has_children and item.open then
          open_state[item.key] = false
          picker:find()
        end
      end,
      confirm = function(picker, item)
        -- For groups with children, toggle instead of closing
        if item.type == "group" and item.has_children then
          open_state[item.key] = not item.open
          picker:find()
          return
        end
        -- For keymaps, go to source file if available
        picker:close()
        if item.file and item.pos then
          vim.cmd("edit " .. vim.fn.fnameescape(item.file))
          vim.api.nvim_win_set_cursor(0, { item.pos[1], item.pos[2] })
        elseif item.disabled then
          vim.notify("This keymap is disabled", vim.log.levels.INFO)
        else
          vim.notify(string.format("Keymap: %s -> %s", item.key, item.desc or ""), vim.log.levels.INFO)
        end
      end,
    },
    win = {
      input = {
        keys = {
          ["i"] = { "expand", desc = "Expand group" },
          ["h"] = { "collapse", desc = "Collapse group" },
        },
      },
    },
    -- Use default layout (same as Snacks.picker.keymaps)
  })
end

--- Setup the KMUInspect command
function M.setup()
  vim.api.nvim_create_user_command("KMUInspect", function(cmd_opts)
    local opts = {}

    -- Parse command arguments
    for _, arg in ipairs(vim.split(cmd_opts.args or "", " ", { trimempty = true })) do
      if arg == "--with-desc" then
        opts.with_desc = true
      elseif arg == "--local" then
        opts["local"] = true
      elseif arg == "--plugs" then
        opts.plugs = true
      elseif arg == "--kmu-only" then
        opts.kmu_only = true
      elseif arg == "--tree" then
        opts.tree = true
      elseif arg == "--flat" then
        opts.tree = false
      elseif arg:match("^--mode=") then
        local mode = arg:match("^--mode=(.+)$")
        if mode then
          opts.modes = { mode }
        end
      end
    end

    M.open(opts)
  end, {
    desc = "Keymap introspection with Snacks picker (--kmu-only for tree view)",
    nargs = "*",
    complete = function()
      return {
        "--kmu-only",
        "--tree",
        "--flat",
        "--with-desc",
        "--local",
        "--plugs",
        "--mode=n",
        "--mode=i",
        "--mode=v",
        "--mode=x",
      }
    end,
  })
end

return M
