local M = {}

local dap = require("dap")
local dapui = require("dapui")

---@class BreakpointItem
---@field file string
---@field line number
---@field text string
---@field condition? string
---@field hitCondition? string
---@field logMessage? string
---@field enabled boolean
---@field bufnr number

--- Get all breakpoints formatted for Snacks picker
---@return BreakpointItem[]
local function get_breakpoints()
  local breakpoints = {}

  -- Get breakpoints using the correct DAP API
  local dap_breakpoints = require("dap.breakpoints")
  local all_bps = dap_breakpoints.get()

  if not all_bps or vim.tbl_isempty(all_bps) then
    return breakpoints
  end

  for bufnr, bps in pairs(all_bps) do
    local filename = vim.api.nvim_buf_get_name(bufnr)
    local display_name = vim.fn.fnamemodify(filename, ":~:.")

    for _, bp in ipairs(bps) do
      -- Get the actual line text
      local line_text = ""
      if vim.api.nvim_buf_is_loaded(bufnr) then
        local lines = vim.api.nvim_buf_get_lines(bufnr, bp.line - 1, bp.line, false)
        if #lines > 0 then
          line_text = vim.trim(lines[1])
        end
      end

      -- Create display text with file:line format
      local display_text = string.format("%s:%d", display_name, bp.line)
      if line_text ~= "" then
        display_text = display_text .. " " .. line_text
      end

      -- Add condition info if present
      local info_parts = {}
      if bp.condition then
        table.insert(info_parts, "if: " .. bp.condition)
      end
      if bp.hitCondition then
        table.insert(info_parts, "hits: " .. bp.hitCondition)
      end
      if bp.logMessage then
        table.insert(info_parts, "log: " .. bp.logMessage)
      end

      if #info_parts > 0 then
        display_text = display_text .. " (" .. table.concat(info_parts, ", ") .. ")"
      end

      local item = {
        file = filename,
        line = bp.line,
        text = display_text,
        condition = bp.condition,
        hitCondition = bp.hitCondition,
        logMessage = bp.logMessage,
        enabled = bp.enabled ~= false,
        bufnr = bufnr,
      }
      -- Add display text directly to the item
      item.item = display_text
      table.insert(breakpoints, item)
    end
  end

  -- Sort by file then line
  table.sort(breakpoints, function(a, b)
    if a.file == b.file then
      return a.line < b.line
    end
    return a.file < b.file
  end)

  return breakpoints
end

--- Jump to breakpoint location
---@param bp BreakpointItem
local function jump_to_breakpoint(bp)
  -- Load buffer if not loaded
  if not vim.api.nvim_buf_is_loaded(bp.bufnr) then
    vim.cmd("edit " .. vim.fn.fnameescape(bp.file))
  else
    vim.api.nvim_set_current_buf(bp.bufnr)
  end

  -- Jump to line
  vim.api.nvim_win_set_cursor(0, { bp.line, 0 })
  vim.cmd("normal! zz") -- Center line on screen
end

--- Toggle breakpoint enabled/disabled
---@param bp BreakpointItem
local function toggle_breakpoint(bp)
  local dap_breakpoints = require("dap.breakpoints")
  dap_breakpoints.toggle({
    condition = bp.condition,
    hit_condition = bp.hitCondition,
    log_message = bp.logMessage,
  }, bp.bufnr, bp.line)
end

--- Remove breakpoint
---@param bp BreakpointItem
local function remove_breakpoint(bp)
  local dap_breakpoints = require("dap.breakpoints")
  dap_breakpoints.remove(bp.bufnr, bp.line)
end

--- Edit breakpoint condition
---@param bp BreakpointItem
local function edit_condition(bp)
  vim.ui.input({
    prompt = "Breakpoint condition: ",
    default = bp.condition or "",
  }, function(condition)
    if condition ~= nil then
      -- Remove existing breakpoint
      remove_breakpoint(bp)

      -- Add new one with condition (if not empty)
      if condition ~= "" then
        dap.set_breakpoint(condition, bp.hitCondition, bp.logMessage)
      end
    end
  end)
end

--- Open Snacks breakpoints picker
function M.pick()
  local breakpoints = get_breakpoints()

  if #breakpoints == 0 then
    vim.notify("No breakpoints found", vim.log.levels.INFO)
    return
  end

  -- Create properly formatted items for Snacks picker
  local items = {}

  for _, bp in ipairs(breakpoints) do
    table.insert(items, {
      file = bp.file, -- Required for preview
      line = bp.line, -- Required for preview
      col = 1, -- Required col field
      text = bp.text, -- Base text without icon
      enabled = bp.enabled,
      condition = bp.condition,
      hitCondition = bp.hitCondition,
      logMessage = bp.logMessage,
      bufnr = bp.bufnr,
      bp = bp, -- Store original for actions
    })
  end

  Snacks.picker.pick({
    name = "breakpoints",
    items = items,
    focus = "list", -- Default focus to list
    format = function(item)
      local icon = item.enabled and "🔴" or "⚪"
      return {
        { icon .. " ", hl = item.enabled and "DiagnosticError" or "Comment" },
        { item.text, hl = "Normal" },
      }
    end,
    actions = {
      jump = {
        action = function(picker, item)
          if item and item.bp then
            picker:close()
            jump_to_breakpoint(item.bp)
          end
        end,
      },
      toggle = {
        action = function(picker, item)
          if item and item.bp then
            toggle_breakpoint(item.bp)
            picker:close()
            M.pick()
          end
        end,
      },
      remove = {
        action = function(picker, item)
          if item and item.bp then
            remove_breakpoint(item.bp)
            picker:close()
            M.pick()
          end
        end,
      },
      edit_condition = {
        action = function(picker, item)
          if item and item.bp then
            picker:close()
            edit_condition(item.bp)
          end
        end,
      },
      clear_all = {
        action = function(picker)
          vim.ui.input({
            prompt = "Clear all breakpoints? (y/N): ",
          }, function(input)
            if input and input:lower() == "y" then
              dap.clear_breakpoints()
              picker:close()
            end
          end)
        end,
      },
    },
    win = {
      input = {
        keys = {
          ["/"] = "toggle_focus", -- Toggle between input and list
        },
      },
      list = {
        keys = {
          ["/"] = "toggle_focus", -- Toggle between list and input
          -- ["i"] = "focus_input",   -- Directly focus input
          ["<CR>"] = "jump",
          ["t"] = "toggle",
          ["d"] = "remove",
          ["c"] = "edit_condition",
          ["D"] = "clear_all",
          ["g?"] = function()
            -- Create help buffer
            local buf = vim.api.nvim_create_buf(false, true)

            -- Help content
            local help_lines = {
              " DAP Breakpoints Picker Help",
              "",
              " Navigation:",
              " <CR>   - Jump to breakpoint location",
              " /      - Toggle focus between input and list",
              " i      - Focus input window",
              "",
              " Actions:",
              " t      - Toggle breakpoint enabled/disabled",
              " d      - Remove breakpoint",
              " c      - Edit breakpoint condition",
              " D      - Clear all breakpoints",
              " g?     - Show this help",
              " <Esc>  - Close picker",
              "",
              " Icons:",
              " 🔴     - Enabled breakpoint",
              " ⚪     - Disabled breakpoint",
              "",
              " Press any key to close this help...",
            }

            -- Set buffer content
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, help_lines)
            vim.api.nvim_buf_set_option(buf, "modifiable", false)
            vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

            -- Get current window dimensions
            local width = vim.api.nvim_win_get_width(0)
            local height = vim.api.nvim_win_get_height(0)

            -- Create floating window
            local win = vim.api.nvim_open_win(buf, true, {
              relative = "win",
              width = width - 2,
              height = math.floor(height / 2),
              row = 0,
              col = 1,
              style = "minimal",
              border = "rounded",
              title = " Breakpoints Help ",
              title_pos = "center",
              zindex = 1000, -- High z-index to appear above picker
            })

            -- Set window options
            vim.api.nvim_win_set_option(win, "wrap", false)
            vim.api.nvim_win_set_option(win, "cursorline", true)

            -- Close on any key press
            vim.keymap.set("n", "<buffer>", function()
              vim.api.nvim_win_close(win, true)
            end, { buffer = buf, silent = true })

            -- Also close on escape
            vim.keymap.set("n", "<Esc>", function()
              vim.api.nvim_win_close(win, true)
            end, { buffer = buf, silent = true })
          end,
        },
      },
    },
  })
end

return M

