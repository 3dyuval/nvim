return {
  "dawsers/file-history.nvim",
  dependencies = {
    "folke/snacks.nvim",
  },
  config = function()
    local file_history = require("file_history")
    file_history.setup({
      backup_dir = "~/.file-history-git",
      git_cmd = "git",
      hostname = nil,
      key_bindings = {
        revert_to_selected = "<C-Enter>", -- Fixed: was <C-Enter>
        open_file_diff_tab = "<M-d>", -- Fixed: was <C-d>
        open_buffer_diff_tab = "<M-d>", -- Fixed: was <C-d>
        toggle_incremental = "<M-l>",
        delete_history = "<M-d>",
        purge_history = "<M-p>",
      },
    })

    vim.keymap.set("n", "<leader>hh", function()
      file_history.history()
    end, { silent = true, desc = "local history of file" })
    vim.keymap.set("n", "<leader>ha", function()
      file_history.files()
    end, { silent = true, desc = "All files in backup repository" })

    -- DIFFVIEW INTEGRATION EXTENSION
    local original_actions = require("file_history.actions")

    local function diffview_open_buffer_diff(item, data)
      if not data.buf then
        return
      end

      local current_file = vim.api.nvim_buf_get_name(data.buf)

      if current_file == "" then
        vim.notify("No file currently open", vim.log.levels.ERROR)
        return
      end

      -- Trust that DiffView is available and handle errors gracefully
      local success, err = pcall(function()
        local cmd =
          string.format("DiffviewOpen %s -- %s", item.hash, vim.fn.fnamemodify(current_file, ":."))
        vim.cmd(cmd)
      end)

      if not success then
        vim.notify("DiffView command failed: " .. tostring(err), vim.log.levels.ERROR)
        -- Fallback to original vim diff method
        require("file_history.actions").open_buffer_diff_tab(item, data)
      end
    end

    local function diffview_open_file_diff(item)
      local success, err = pcall(function()
        local cmd = string.format("DiffviewOpen HEAD..%s -- %s", item.hash, item.file)
        vim.cmd(cmd)
      end)

      if not success then
        vim.notify("DiffView command failed: " .. tostring(err), vim.log.levels.ERROR)
        require("file_history.actions").open_file_diff_tab(item)
      end
    end

    original_actions.open_buffer_diff_tab = diffview_open_buffer_diff
    original_actions.open_file_diff_tab = diffview_open_file_diff
  end,
}
