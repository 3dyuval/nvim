-- Export keymaps to documentation
-- Uses vim.api to get all set keymaps since they're already loaded

-- Parse arguments
local by_group = false
local format = "md"
local output_file = "README.md"

-- Parse flags from arg
local arg_idx = 1
for i, a in ipairs(arg or {}) do
  if a == "--by-group" then
    by_group = true
  elseif arg_idx == 1 then
    format = a
    arg_idx = arg_idx + 1
  elseif arg_idx == 2 then
    output_file = a
    arg_idx = arg_idx + 1
  end
end

-- Get all currently set keymaps
local modes = { "n", "i", "v", "x", "o", "c", "t" }
local all_keymaps = {}

for _, mode in ipairs(modes) do
  local keymaps = vim.api.nvim_get_keymap(mode)
  for _, keymap in ipairs(keymaps) do
    -- Only include keymaps with descriptions
    if keymap.desc and keymap.desc ~= "" then
      table.insert(all_keymaps, {
        mode = mode,
        key = keymap.lhs,
        desc = keymap.desc,
      })
    end
  end
end

print(string.format("Collected %d keymaps with descriptions", #all_keymaps))

if format == "json" then
  -- Export as JSON
  local json_lines = { "{", '  "keymaps": [' }
  for i, keymap in ipairs(all_keymaps) do
    local entry = string.format(
      '    {"mode": "%s", "key": "%s", "desc": "%s"}',
      keymap.mode,
      keymap.key:gsub('"', '\\"'),
      keymap.desc:gsub('"', '\\"')
    )
    if i < #all_keymaps then
      entry = entry .. ","
    end
    table.insert(json_lines, entry)
  end
  table.insert(json_lines, "  ],")
  table.insert(json_lines, string.format('  "total": %d', #all_keymaps))
  table.insert(json_lines, "}")

  local json = table.concat(json_lines, "\n")
  local file = io.open(output_file, "w")
  if file then
    file:write(json)
    file:close()
    print(string.format("✅ Exported to %s", output_file))
  else
    error("Failed to write to " .. output_file)
  end
elseif format == "md" or format == "markdown" then
  -- Export as Markdown
  local md_lines = {
    "# Keymap Reference",
    "",
    string.format("Total keymaps: %d", #all_keymaps),
    "",
    "_Auto-generated with `make export-keymaps`_",
    "",
  }

  if by_group then
    -- Auto-detect groups from keymap-utils
    local kmu = require("keymap-utils")
    local group_descs = kmu.get_group_descriptions()

    -- Build group_names map from auto-detected groups
    -- Note: <leader> is expanded to a space in actual keymaps
    local group_names = {}
    for _, group_desc in ipairs(group_descs) do
      local key = group_desc[1] -- e.g., "<leader>g"
      local group_name = group_desc.group -- e.g., "Git"
      -- Replace <leader> with space
      key = key:gsub("<leader>", " ")
      group_names[key] = group_name
    end

    print(string.format("Auto-detected %d groups from keymaps", vim.tbl_count(group_names)))

    -- Extract group from key
    local function get_group(key)
      -- Check for specific leader groups (longest match first for " db" before " d")
      local sorted_prefixes = {}
      for prefix in pairs(group_names) do
        table.insert(sorted_prefixes, prefix)
      end
      table.sort(sorted_prefixes, function(a, b) return #a > #b end)

      for _, prefix in ipairs(sorted_prefixes) do
        if key:sub(1, #prefix) == prefix then
          return prefix, group_names[prefix]
        end
      end

      -- Check for simple leader (space prefix)
      if key:sub(1, 1) == " " then
        return " ", "Leader (uncategorized)"
      end
      return "other", "Other Keymaps"
    end

    local groups = {}

    for _, keymap in ipairs(all_keymaps) do
      local group_key, group_name = get_group(keymap.key)
      if not groups[group_key] then
        groups[group_key] = { name = group_name, keymaps = {} }
      end
      table.insert(groups[group_key].keymaps, keymap)
    end

    -- Sort groups
    local group_keys = {}
    for key in pairs(groups) do
      table.insert(group_keys, key)
    end
    table.sort(group_keys)

    for _, group_key in ipairs(group_keys) do
      local group = groups[group_key]
      table.insert(md_lines, string.format("## %s", group.name))
      table.insert(md_lines, "")
      table.insert(md_lines, "| Mode | Key | Description |")
      table.insert(md_lines, "|------|-----|-------------|")

      -- Sort keymaps by key
      table.sort(group.keymaps, function(a, b)
        if a.key == b.key then
          return a.mode < b.mode
        end
        return a.key < b.key
      end)

      for _, keymap in ipairs(group.keymaps) do
        local key = keymap.key:gsub("|", "\\|")
        local desc = keymap.desc:gsub("|", "\\|")
        table.insert(md_lines, string.format("| `%s` | `%s` | %s |", keymap.mode, key, desc))
      end
      table.insert(md_lines, "")
    end
  else
    -- Group by mode (original behavior)
    local by_mode = {}
    for _, keymap in ipairs(all_keymaps) do
      if not by_mode[keymap.mode] then
        by_mode[keymap.mode] = {}
      end
      table.insert(by_mode[keymap.mode], keymap)
    end

    -- Sort modes
    local modes_list = {}
    for mode in pairs(by_mode) do
      table.insert(modes_list, mode)
    end
    table.sort(modes_list)

    -- Mode names
    local mode_names = {
      n = "Normal",
      i = "Insert",
      v = "Visual",
      x = "Visual Block",
      o = "Operator-pending",
      c = "Command-line",
      t = "Terminal",
    }

    for _, mode in ipairs(modes_list) do
      local mode_name = mode_names[mode] or mode
      table.insert(md_lines, string.format("## %s Mode", mode_name))
      table.insert(md_lines, "")
      table.insert(md_lines, "| Key | Description |")
      table.insert(md_lines, "|-----|-------------|")

      -- Sort keymaps by key
      table.sort(by_mode[mode], function(a, b)
        return a.key < b.key
      end)

      for _, keymap in ipairs(by_mode[mode]) do
        local key = keymap.key:gsub("|", "\\|") -- Escape pipes for markdown
        local desc = keymap.desc:gsub("|", "\\|")
        table.insert(md_lines, string.format("| `%s` | %s |", key, desc))
      end
      table.insert(md_lines, "")
    end
  end

  local md = table.concat(md_lines, "\n")
  local file = io.open(output_file, "w")
  if file then
    file:write(md)
    file:close()
    print(string.format("✅ Exported to %s", output_file))
  else
    error("Failed to write to " .. output_file)
  end
else
  error("Unknown format: " .. format .. ". Use 'json' or 'md'")
end
