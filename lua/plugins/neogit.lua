-- In your neogit.lua config
vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "BufWinEnter" }, {
  pattern = "NeogitStatus",
  callback = function(args)
    -- Force override any conflicting global mappings
    vim.keymap.set("n", "s", "Stage", {
      buffer = args.buf,
      desc = "Stage item under cursor",
      nowait = true,
      remap = true, -- Allow Neogit's internal mapping to work
    })
  end,
})

return {
  "NeogitOrg/neogit",
  config = function()
    require("utils.neogit-commands").setup()
    require("neogit").setup({
      auto_refresh = true,
      kind = "vsplit",
      graph_style = "kitty",
      remember_settings = false,
      integrations = {
        diffview = true,
      },
      merge_editor = {
        kind = "auto",
      },
      commit_view = {
        kind = "vsplit",
      },
      status = {
        UU = "󱠿",
      },
      mappings = {
        rebase_editor = {
          ["E"] = "MoveUp", -- move commit up
          ["A"] = "MoveDown", -- move commit down
        },
        popup = {
          ["m"] = false,
          ["M"] = "MergePopup",
        },
        status = {
          ["C"] = "YankSelected",
          ["m"] = function() end, -- disable merge to use your custom binding
          ["<leader>q"] = "Close", -- Close Neogit
          -- Custom conflict resolution popup (using E for rEsolve)
          ["E"] = function()
            require("utils.neogit-commands").create_conflict_popup()
          end,
          -- Git conflict resolution keybindings (matching keymaps.lua)
          ["gP"] = function()
            local status = require("neogit.buffers.status").instance()
            if not status then
              return
            end

            local item = status.buffer.ui:get_item_under_cursor()
            if item and item.absolute_path then
              local success = require("git-resolve-conflict").resolve_ours(item.absolute_path)
              if success then
                status:refresh()
              end
            else
              vim.notify("No file under cursor", vim.log.levels.WARN)
            end
          end,
          ["gp"] = function()
            local status = require("neogit.buffers.status").instance()
            if not status then
              return
            end

            local item = status.buffer.ui:get_item_under_cursor()
            if item and item.absolute_path then
              vim.cmd("edit " .. vim.fn.fnameescape(item.absolute_path))
              require("git-conflict").choose("ours")
            else
              vim.notify("No file under cursor", vim.log.levels.WARN)
            end
          end,
          ["gO"] = function()
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
          end,
          ["go"] = function()
            local status = require("neogit.buffers.status").instance()
            if not status then
              return
            end

            local item = status.buffer.ui:get_item_under_cursor()
            if item and item.absolute_path then
              vim.cmd("edit " .. vim.fn.fnameescape(item.absolute_path))
              require("git-conflict").choose("theirs")
            else
              vim.notify("No file under cursor", vim.log.levels.WARN)
            end
          end,
          ["gU"] = function()
            require("git-resolve-conflict").resolve_union()
          end,
        },
      },
      autoinstall = true,
    })

    -- Explicit buffer-local mapping override for neogit
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "NeogitStatus",
      callback = function(args)
        vim.keymap.set("n", "E", function()
          require("utils.neogit-commands").create_conflict_popup()
        end, {
          buffer = args.buf,
          desc = "File resolution popup",
          nowait = true, -- Override global mapping immediately
        })

        -- Force disable 'm' key in Neogit
        pcall(vim.keymap.del, "n", "m", { buffer = args.buf })
      end,
    })
  end,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
    "folke/snacks.nvim",
    "3dyuval/git-resolve-conflict.nvim",
  },
}
