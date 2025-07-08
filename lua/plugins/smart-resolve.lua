return {
  {
    "smart-resolve",
    dir = vim.fn.stdpath("config"),
    name = "smart-resolve",
    dependencies = { "sindrets/diffview.nvim" },
    config = function()
      -- Install git-resolve-conflict if not present
      local function install_git_resolve_conflict()
        local handle = io.popen("which git-resolve-conflict 2>/dev/null")
        local result = handle:read("*a")
        handle:close()

        if result == "" then
          vim.notify("Installing git-resolve-conflict...", vim.log.levels.INFO)
          vim.fn.system("npm install -g git-resolve-conflict")
        end
      end

      -- Auto-install on startup
      install_git_resolve_conflict()

      -- Jump to next/previous conflict functions
      local function next_conflict()
        local found = vim.fn.search("^<<<<<<<", "W")
        if found == 0 then
          vim.notify("No more conflicts found", vim.log.levels.INFO)
        end
      end

      local function prev_conflict()
        local found = vim.fn.search("^<<<<<<<", "bW")
        if found == 0 then
          vim.notify("No more conflicts found", vim.log.levels.INFO)
        end
      end

      -- Smart resolve function
      local function smart_resolve_current_file()
        local file = vim.api.nvim_buf_get_name(0)
        if file == "" then
          vim.notify("No file in current buffer", vim.log.levels.WARN)
          return
        end

        -- Check if file has conflicts
        local has_conflicts = vim.fn.search("^<<<<<<< ", "nw") > 0
        if not has_conflicts then
          return
        end

        -- Present options
        local choices = {
          "1. Union (merge both changes)",
          "2. Ours (keep our changes)",
          "3. Theirs (keep their changes)",
          "4. Cancel",
        }

        vim.ui.select(choices, {
          prompt = "Smart resolve conflicts in " .. vim.fn.fnamemodify(file, ":t") .. ":",
        }, function(choice, idx)
          if not choice or idx == 4 then
            return
          end

          local strategies = { "union", "ours", "theirs" }
          local strategy = strategies[idx]

          -- Get git root directory
          local git_root = vim.fn.system("git rev-parse --show-toplevel"):gsub("\n", "")
          
          -- Convert absolute path to relative path from git root
          local relative_file = file:gsub("^" .. git_root .. "/", "")
          
          -- Check if file is actually in Git conflict state
          local git_status_cmd = string.format("cd %s && git status --porcelain %s", 
                                             vim.fn.shellescape(git_root), 
                                             vim.fn.shellescape(relative_file))
          local git_output = vim.fn.system(git_status_cmd)
          vim.notify("Git status: '" .. (git_output == "" and "clean" or git_output:gsub("\n", "")) .. "'", vim.log.levels.INFO)
          
          -- Also check what git-resolve-conflict expects
          local git_diff_cmd = string.format("cd %s && git diff --name-only --diff-filter=U", vim.fn.shellescape(git_root))
          local unmerged_files = vim.fn.system(git_diff_cmd)
          vim.notify("Unmerged files: '" .. unmerged_files:gsub("\n", ", ") .. "'", vim.log.levels.INFO)
          
          -- Check if our file is in that list
          local file_in_unmerged = unmerged_files:find(relative_file, 1, true) ~= nil
          vim.notify("File '" .. relative_file .. "' in unmerged list: " .. tostring(file_in_unmerged), vim.log.levels.INFO)
          
          -- If file was staged, unstage it first to put it back in conflicted state
          if git_output:match("^UU") == nil and git_output:match("^AA") == nil then
            local reset_cmd = string.format("cd %s && git reset HEAD -- %s", 
                                           vim.fn.shellescape(git_root),
                                           vim.fn.shellescape(relative_file))
            vim.notify("Unstaging file to restore conflict state", vim.log.levels.INFO)
            vim.fn.system(reset_cmd)
          end
          
          -- Run git-resolve-conflict from git root
          local cmd = string.format("cd %s && git-resolve-conflict --%s %s", 
                                   vim.fn.shellescape(git_root),
                                   strategy, 
                                   vim.fn.shellescape(relative_file))
          vim.notify("Running: " .. cmd, vim.log.levels.INFO)
          local output = vim.fn.system(cmd)
          local exit_code = vim.v.shell_error
          
          vim.notify("Exit code: " .. exit_code .. ", Output: " .. (output or ""), vim.log.levels.INFO)

          if exit_code == 0 then
            -- Reload the buffer to show resolved conflicts
            vim.cmd("checktime")
            vim.notify(string.format("Resolved conflicts using '%s' strategy", strategy), vim.log.levels.INFO)
          else
            vim.notify("Failed to resolve conflicts: " .. output, vim.log.levels.ERROR)
          end
        end)
      end

      -- Auto-load in diffview merge mode
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "*",
        callback = function()
          -- Check if we're in diffview merge mode
          local bufname = vim.api.nvim_buf_get_name(0)
          local is_diffview = bufname:match("diffview://") ~= nil
          local is_merge_mode = vim.fn.exists("*diffview#get_current_view") == 1

          if is_diffview or vim.wo.diff then
            -- Add diffview-specific keymap (silently)
            vim.keymap.set("n", "<leader>gr", smart_resolve_current_file, {
              buffer = true,
              desc = "Smart resolve conflicts (diffview)",
            })
          end
        end,
      })

      -- Auto-trigger when opening files with conflicts (once per buffer)
      local notified_buffers = {}
      vim.api.nvim_create_autocmd("BufReadPost", {
        pattern = "*",
        callback = function()
          local bufnr = vim.api.nvim_get_current_buf()
          if notified_buffers[bufnr] then
            return
          end

          -- Check if file has conflicts
          local has_conflicts = vim.fn.search("^<<<<<<< ", "nw") > 0
          if has_conflicts then
            notified_buffers[bufnr] = true
            vim.notify("Conflicts detected! Use <leader>gr for smart resolution", vim.log.levels.WARN)
          end
        end,
      })

      -- Command and global keymap
      vim.api.nvim_create_user_command("SmartResolve", smart_resolve_current_file, {
        desc = "Smart resolve conflicts in current file",
      })

      vim.keymap.set("n", "<leader>gr", smart_resolve_current_file, {
        desc = "Smart resolve conflicts",
      })

      -- Conflict navigation keymaps
      vim.keymap.set("n", "]x", next_conflict, { desc = "Next conflict" })
      vim.keymap.set("n", "[x", prev_conflict, { desc = "Previous conflict" })
    end,
  },
}

