-- Snacks-related keymaps module
local M = {}

-- Generic toggle function for snacks picker settings
local function toggle_snacks_picker_setting(setting_name)
  return function()
    local snacks = require("snacks")
    local current_value = snacks.config.picker[setting_name]
    snacks.config.picker[setting_name] = not current_value
    local status = snacks.config.picker[setting_name] and "enabled" or "disabled"
    vim.notify("Snacks picker " .. setting_name .. " files: " .. status)
  end
end

-- Export toggle function
M.toggle_snacks_picker_setting = toggle_snacks_picker_setting

-- Export individual toggle functions
M.toggle_ignored = toggle_snacks_picker_setting("ignored")
M.toggle_hidden = toggle_snacks_picker_setting("hidden")

return M
