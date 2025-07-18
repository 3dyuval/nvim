-- Initialize the formatter API
local formatter = require("utils.formatter")

-- Setup formatter with default options
formatter.setup({
  verbose = false,
  auto_notification = true,
  progress_interval = 1000, -- ms
})

-- Create additional keymaps for formatting
vim.keymap.set("n", "<leader>ff", function()
  formatter.format_current_buffer({ verbose = true })
end, { desc = "Format current buffer" })

vim.keymap.set("n", "<leader>fF", function()
  formatter.format_current_buffer({ verbose = true, check = true })
end, { desc = "Check current buffer formatting" })

vim.keymap.set("n", "<leader>fd", function()
  formatter.format_batch({ vim.fn.getcwd() }, { verbose = true })
end, { desc = "Format current directory" })

vim.keymap.set("n", "<leader>fj", function()
  local jobs = formatter.get_active_jobs()
  if vim.tbl_isempty(jobs) then
    vim.notify("No active formatting jobs", vim.log.levels.INFO)
  else
    for job_id, job_info in pairs(jobs) do
      local status = job_info.status
      vim.notify(string.format("Job %s: %s", job_id, status.message), vim.log.levels.INFO)
    end
  end
end, { desc = "Show active formatting jobs" })

return formatter