return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        git_branches = {
          auto_close = false,
          focus = "list",
          actions = {
            branch_actions_menu = function(picker)
              local item = picker.list:get()
              if not item then
                return
              end

              local function get_branch_name(item)
                if type(item) == "string" then
                  return item
                elseif type(item) == "table" then
                  return item.text or item.value or item[1] -- try common possibilities
                end
              end

              local branch = get_branch_name(item)
              if not branch or branch == "" then
                vim.notify("No branch selected", vim.log.levels.WARN)
                return
              end
              local choices = {
                "Checkout " .. branch,
                "Diff current file vs " .. branch,
                "Diff all files vs " .. branch,
                "Diff " .. branch .. " vs current branch",
                "File history for " .. branch,
                "Create new branch from " .. branch,
                "Delete " .. branch,
                "Rename " .. branch,
                "Merge " .. branch .. " into current",
                "Rebase current onto " .. branch,
                "Show log for " .. branch,
                "Cancel",
              }

              vim.ui.select(choices, {
                prompt = "Git Branch Action:",
              }, function(choice)
                if not choice or choice == "Cancel" then
                  return
                end
                picker:close()

                if choice:match("^Checkout") then
                  vim.cmd("!git checkout " .. branch)
                elseif choice:match("^Diff current file vs") then
                  vim.cmd("DiffviewOpen " .. branch .. " -- " .. vim.fn.expand("%"))
                elseif choice:match("^Diff all files vs") then
                  vim.cmd("DiffviewOpen " .. branch)
                elseif choice:match("^Diff .* vs current branch") then
                  vim.cmd("DiffviewOpen HEAD.." .. branch)
                elseif choice:match("^File history for") then
                  vim.cmd("DiffviewFileHistory --range=" .. branch)
                elseif choice:match("^Create new branch") then
                  vim.ui.input({ prompt = "New branch name:" }, function(new_name)
                    if new_name and #new_name > 0 then
                      vim.cmd("!git checkout -b " .. new_name .. " " .. branch)
                    end
                  end)
                elseif choice:match("^Delete") then
                  vim.cmd("!git branch -d " .. branch)
                elseif choice:match("^Rename") then
                  vim.ui.input({ prompt = "Rename '" .. branch .. "' to:" }, function(new_name)
                    if new_name and #new_name > 0 then
                      vim.cmd("!git branch -m " .. branch .. " " .. new_name)
                    end
                  end)
                elseif choice:match("^Merge") then
                  vim.cmd("!git merge " .. branch)
                elseif choice:match("^Rebase") then
                  vim.cmd("!git rebase " .. branch)
                elseif choice:match("^Show log") then
                  vim.cmd("tabnew | read !git log " .. branch)
                elseif choice:match("^Show diff") then
                  vim.cmd("tabnew | read !git diff " .. branch)
                end
              end)
            end,
          },
          win = {
            list = {
              keys = {
                ["p"] = "branch_actions_menu",
              },
            },
          },
        },
      },
    },
  },
}
