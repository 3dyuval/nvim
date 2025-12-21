-- Custom Neogit conflict resolution popup
local M = {}

-- Simple resolution using git checkout (Neogit style)
local function git_checkout_resolve(file_path, strategy)
  local git = require("neogit.lib.git")

  if strategy == "ours" then
    -- Use Neogit's git CLI API: git checkout --ours <file>
    local result = git.cli.checkout.ours.files(file_path).call({ await = true })
    if result.code == 0 then
      -- Stage the file
      git.cli.add.files(file_path).call({ await = true })
      return true
    else
      vim.notify(
        "Failed to checkout --ours: " .. (result.stderr and result.stderr[1] or "unknown error"),
        vim.log.levels.ERROR
      )
      return false
    end
  elseif strategy == "theirs" then
    -- Use Neogit's git CLI API: git checkout --theirs <file>
    local result = git.cli.checkout.theirs.files(file_path).call({ await = true })
    if result.code == 0 then
      -- Stage the file
      git.cli.add.files(file_path).call({ await = true })
      return true
    else
      vim.notify(
        "Failed to checkout --theirs: " .. (result.stderr and result.stderr[1] or "unknown error"),
        vim.log.levels.ERROR
      )
      return false
    end
  elseif strategy == "union" then
    -- No direct git checkout equivalent for union - fall back to complex method
    return require("git-resolve-conflict").resolve_union(file_path)
  else
    vim.notify("Unknown strategy: " .. strategy, vim.log.levels.ERROR)
    return false
  end
end

-- Define the resolve functions
local function resolve_ours_cmd()
  local status = require("neogit.buffers.status").instance()
  if not status then
    vim.notify("No Neogit status buffer found", vim.log.levels.WARN)
    return
  end

  local item = status.buffer.ui:get_item_under_cursor()
  if item then
    vim.notify("Item found: " .. vim.inspect({
      name = item.name,
      absolute_path = item.absolute_path,
      mode = item.mode,
    }), vim.log.levels.INFO)

    if item.absolute_path then
      local success = require("git-resolve-conflict").resolve_ours(item.absolute_path)
      if success then
        status:refresh()
      end
    else
      vim.notify("Item has no absolute_path: " .. vim.inspect(item), vim.log.levels.WARN)
    end
  else
    vim.notify("No item under cursor", vim.log.levels.WARN)
  end
end

local function resolve_theirs_cmd()
  local status = require("neogit.buffers.status").instance()
  if not status then
    return
  end

  local item = status.buffer.ui:get_item_under_cursor()
  if item and item.absolute_path then
    local success = require("git-resolve-conflict").resolve_theirs(item.absolute_path)
    if success then
      status:refresh()
    end
  else
    vim.notify("No file under cursor", vim.log.levels.WARN)
  end
end

local function resolve_union_cmd()
  local status = require("neogit.buffers.status").instance()
  if not status then
    return
  end

  local item = status.buffer.ui:get_item_under_cursor()
  if item and item.absolute_path then
    local success = require("git-resolve-conflict").resolve_union(item.absolute_path)
    if success then
      status:refresh()
    end
  else
    vim.notify("No file under cursor", vim.log.levels.WARN)
  end
end

-- Get all conflicted files from Neogit's repository state
local function get_all_conflicted_files()
  local git = require("neogit.lib.git")
  local conflicted = {}

  -- Check sections that can contain conflicted files
  local sections_to_check = { "unstaged", "staged", "upstream.unmerged", "pushRemote.unmerged" }

  for _, section_path in ipairs(sections_to_check) do
    local section = git.repo.state
    for part in section_path:gmatch("[^%.]+") do
      if section and section[part] then
        section = section[part]
      else
        section = nil
        break
      end
    end

    if section and section.items then
      for _, item in ipairs(section.items) do
        -- Check if item has conflict modes (UU, AA, DD, AU, UA, DU, UD)
        if
          item.absolute_path
          and item.mode
          and (
            item.mode == "UU"
            or item.mode == "AA"
            or item.mode == "DD"
            or item.mode == "AU"
            or item.mode == "UA"
            or item.mode == "DU"
            or item.mode == "UD"
          )
        then
          table.insert(conflicted, item.absolute_path)
        end
      end
    end
  end

  return conflicted
end

-- Resolve all conflicted files with a given strategy (complex method)
local function resolve_all_conflicts(strategy)
  local conflicted_files = get_all_conflicted_files()

  if #conflicted_files == 0 then
    vim.notify("No conflicted files found", vim.log.levels.INFO)
    return
  end

  local resolved = 0
  local failed = 0

  for _, file_path in ipairs(conflicted_files) do
    local success
    if strategy == "ours" then
      success = require("git-resolve-conflict").resolve_ours(file_path)
    elseif strategy == "theirs" then
      success = require("git-resolve-conflict").resolve_theirs(file_path)
    elseif strategy == "union" then
      success = require("git-resolve-conflict").resolve_union(file_path)
    end

    if success then
      resolved = resolved + 1
    else
      failed = failed + 1
    end
  end

  vim.notify(
    string.format(
      "Resolved %d/%d files with '%s' strategy (git-resolve-conflict)",
      resolved,
      resolved + failed,
      strategy
    ),
    vim.log.levels.INFO
  )

  -- Refresh status
  local status = require("neogit.buffers.status").instance()
  if status then
    status:refresh()
  end
end

-- Resolve all conflicted files with GitConflict commands (simple method)
local function resolve_all_conflicts_simple(strategy)
  local conflicted_files = get_all_conflicted_files()

  if #conflicted_files == 0 then
    vim.notify("No conflicted files found", vim.log.levels.INFO)
    return
  end

  local resolved = 0
  local failed = 0

  for _, file_path in ipairs(conflicted_files) do
    local success = git_checkout_resolve(file_path, strategy)

    if success then
      resolved = resolved + 1
    else
      failed = failed + 1
    end
  end

  vim.notify(
    string.format("Resolved %d/%d files with '%s' strategy (git checkout)", resolved, resolved + failed, strategy),
    vim.log.levels.INFO
  )

  -- Refresh status
  local status = require("neogit.buffers.status").instance()
  if status then
    status:refresh()
  end
end

-- Create custom conflict resolution popup using Neogit's popup builder
function M.create_conflict_popup()
  -- Capture the current item BEFORE opening the popup
  local status = require("neogit.buffers.status").instance()
  if not status then
    vim.notify("No Neogit status buffer found", vim.log.levels.WARN)
    return
  end

  local current_item = status.buffer.ui:get_item_under_cursor()
  local has_current_file = current_item and current_item.absolute_path

  local heading = has_current_file and ("File Resolution for: " .. current_item.name) or "File Resolution"

  -- Create action functions that take popup as parameter
  local function make_resolve_action(strategy)
    return function(popup)
      if not has_current_file then
        vim.notify("No file under cursor", vim.log.levels.WARN)
        return
      end

      -- Check if --resolve flag is enabled
      local use_complex = vim.tbl_contains(popup:get_arguments(), "--resolve")

      local success
      if use_complex then
        -- Use git-resolve-conflict
        if strategy == "ours" then
          success = require("git-resolve-conflict").resolve_ours(current_item.absolute_path)
        elseif strategy == "theirs" then
          success = require("git-resolve-conflict").resolve_theirs(current_item.absolute_path)
        elseif strategy == "union" then
          success = require("git-resolve-conflict").resolve_union(current_item.absolute_path)
        end
      else
        -- Use git checkout
        success = git_checkout_resolve(current_item.absolute_path, strategy)
      end

      if success then
        status:refresh()
      end
    end
  end

  -- Functions for resolving ALL conflicts
  local function make_resolve_all_action(strategy)
    return function(popup)
      -- Check if --resolve flag is enabled
      local use_complex = vim.tbl_contains(popup:get_arguments(), "--resolve")

      if use_complex then
        resolve_all_conflicts(strategy)
      else
        resolve_all_conflicts_simple(strategy)
      end
    end
  end

  -- Build the popup
  local p = require("neogit.lib.popup")
    .builder()
    :name("NeogitFileResolutionPopup")
    :switch("r", "resolve", "Use git-resolve-conflict")
    :group_heading(heading)
    :action("p", "put (ours)", make_resolve_action("ours"))
    :action("o", "get (theirs)", make_resolve_action("theirs"))
    :action("u", "union (both)", make_resolve_action("union"))
    :new_action_group("Apply to ALL conflicted files")
    :action("P", "Put all (ours)", make_resolve_all_action("ours"))
    :action("O", "Get all (theirs)", make_resolve_all_action("theirs"))
    :action("U", "Union all (both)", make_resolve_all_action("union"))
    :build()

  p:show()
  return p
end

function M.setup()
  -- Create user command to show the popup
  vim.api.nvim_create_user_command("NeogitConflictResolve", M.create_conflict_popup, {
    desc = "Open Neogit conflict resolution popup",
  })
end

return M
