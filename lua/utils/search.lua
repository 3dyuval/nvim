-- Search and replace utilities
local M = {}

M.grug_far_range = function()
  require("grug-far").open({ visualSelectionUsage = "operate-within-range" })
end

M.grug_far_current_file = function()
  require("grug-far").open({
    prefills = {
      paths = vim.fn.expand("%"), -- Current file path
    },
  })
end

M.grug_far_selection_current_file = function()
  require("grug-far").with_visual_selection({
    prefills = {
      paths = vim.fn.expand("%"), -- Current file path
    },
  })
end

M.grug_far_current_directory = function()
  require("grug-far").open({
    prefills = {
      paths = vim.fn.expand("%:h"), -- Current file's directory
    },
  })
end

return M