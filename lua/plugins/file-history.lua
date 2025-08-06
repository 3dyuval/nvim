return {
  "dawsers/file-history.nvim",
  dependencies = {
    "folke/snacks.nvim",
  },
  config = function()
    local file_history = require("file_history")
    file_history.setup({
      -- Default values
      backup_dir = "~/.file-history-git",
      git_cmd = "git",

      -- Use default hostname detection
      hostname = nil,
      key_bindings = {

        -- Fixed to match documentation defaults and resolve conflicts
        revert_to_selected = "<C-r>", -- Fixed: was <C-Enter>
        open_file_diff_tab = "<M-d>", -- Fixed: was <C-d>
        open_buffer_diff_tab = "<M-d>", -- Fixed: was <C-d>
        toggle_incremental = "<M-l>", -- Added: missing feature
        delete_history = "<M-d>", -- Added: missing feature
        purge_history = "<M-p>", -- Added: missing feature
      },
    })

    vim.keymap.set("n", "<leader>hh", function()
      file_history.history()
    end, { silent = true, desc = "local history of file" })
    vim.keymap.set("n", "<leader>ha", function()
      file_history.files()
    end, { silent = true, desc = "All files in backup repository" })

    -- ========================================================================
    -- PROJECT-SCOPED FILE HISTORY EXTENSION
    -- ========================================================================
    -- Implementation of project-scoped file history picker
    -- This extends the plugin with M.project_files() functionality
    -- Based on feature request: https://github.com/dawsers/file-history.nvim/issues/3

    -- Project detection utility functions
    local function get_git_root()
      local handle = io.popen("git rev-parse --show-toplevel 2>/dev/null")
      if not handle then
        return nil
      end
      local result = handle:read("*a")
      handle:close()
      if result and result ~= "" then
        return vim.trim(result)
      end
      return nil
    end

    local function get_project_root()
      -- Try git root first
      local git_root = get_git_root()
      if git_root then
        return git_root
      end
      -- Fallback to current working directory
      return vim.fn.getcwd()
    end

    -- Project-scoped file history finder (mirrors file_history_files_finder)
    local function file_history_project_files_finder(_)
      local fh = require("file_history.fh")

      -- Get all files from the plugin's files() function
      local entries = vim.iter(fh.file_history_files()):flatten():totable()
      if #entries == 0 then
        return {}
      end

      -- Get current project root and hostname for filtering
      local project_root = get_project_root()
      local hostname = vim.fn.hostname()
      local project_prefix = hostname .. project_root

      local results = {}
      for _, entry in pairs(entries) do
        if entry and entry ~= "" then
          -- Only include files that belong to the current project
          if entry:sub(1, #project_prefix) == project_prefix then
            local result = {}
            local index = string.find(entry, "/")
            if index then
              -- If file is local, enable preview (same logic as original)
              if hostname == string.sub(entry, 1, index - 1) then
                result.file = string.sub(entry, index)
                result.text = result.file
              else
                result.file = nil
                result.text = entry
              end
              -- This is the name, or reference for deleting/purging etc
              result.name = entry
              result.hash = "HEAD"
              table.insert(results, result)
            end
          end
        end
      end
      return results
    end

    -- Project-scoped file history picker (mirrors file_history_files_picker)
    local function file_history_project_files_picker()
      local actions = require("file_history.actions")
      local snacks_picker = require("snacks.picker")

      local fhp = {}
      fhp.win = {
        title = "FileHistory project files",
        input = {
          keys = {
            [file_history.opts.key_bindings.delete_history] = {
              "delete_history",
              desc = "Delete file's history",
              mode = { "n", "i" },
            },
            [file_history.opts.key_bindings.purge_history] = {
              "purge_history",
              desc = "Purge file's history",
              mode = { "n", "i" },
            },
          },
        },
      }
      fhp.finder = file_history_project_files_finder
      fhp.format = function(item)
        local ret = {}
        ret[#ret + 1] = { item.text or "", "FileHistoryFile" }
        return ret
      end
      fhp.preview = function(ctx)
        if ctx.item.file and vim.uv.fs_stat(ctx.item.file) then
          snacks_picker.preview.file(ctx)
        else
          ctx.preview:reset()
        end
      end
      fhp.actions = {
        delete_history = function(picker, _)
          actions.delete_history(picker)
          picker:close()
        end,
        purge_history = function(picker, _)
          actions.purge_history(picker)
          picker:close()
        end,
      }
      fhp.confirm = function(_, item)
        actions.open_selected_file_hash_in_new_tab(item)
      end
      return fhp
    end

    -- Add project_files method to the file_history module
    file_history.project_files = function()
      local snacks_picker = require("snacks.picker")
      snacks_picker.pick(file_history_project_files_picker())
    end

    -- ========================================================================
    -- DIFFVIEW INTEGRATION EXTENSION
    -- ========================================================================
    -- Replace default vim diff with DiffView for better visualization

    local original_actions = require("file_history.actions")

    -- Enhanced open_buffer_diff_tab using DiffView
    local function diffview_open_buffer_diff(item, data)
      if not data.buf then
        return
      end

      local current_file = vim.api.nvim_buf_get_name(data.buf)

      if current_file == "" then
        vim.notify("No file currently open", vim.log.levels.ERROR)
        return
      end

      -- Check if DiffView is available, fallback to original if not
      local has_diffview = pcall(require, "diffview")
      if has_diffview then
        -- Use DiffView to compare current file with historical version
        local cmd =
          string.format("DiffviewOpen %s -- %s", item.hash, vim.fn.fnamemodify(current_file, ":."))
        vim.cmd(cmd)
      else
        -- Fallback to original vim diff method
        vim.notify("DiffView not available, using fallback diff", vim.log.levels.WARN)
        require("file_history.actions").open_buffer_diff_tab(item, data)
      end
    end

    -- Enhanced open_file_diff_tab using DiffView
    local function diffview_open_file_diff(item)
      -- Check if DiffView is available, fallback to original if not
      local has_diffview = pcall(require, "diffview")
      if has_diffview then
        -- Compare HEAD with selected commit for the specific file
        local cmd = string.format("DiffviewOpen HEAD..%s -- %s", item.hash, item.file)
        vim.cmd(cmd)
      else
        -- Fallback to original vim diff method
        vim.notify("DiffView not available, using fallback diff", vim.log.levels.WARN)
        require("file_history.actions").open_file_diff_tab(item)
      end
    end

    -- Override the original actions with DiffView versions
    original_actions.open_buffer_diff_tab = diffview_open_buffer_diff
    original_actions.open_file_diff_tab = diffview_open_file_diff

    -- Note: Complex workaround removed since key bindings are now properly configured
    -- Now uses DiffView for enhanced diff visualization instead of basic vim diff
  end,
}
