return {
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
    "folke/snacks.nvim",
  },
  config = function(_, opts)
    require("utils.neogit-commands").setup()

    -- Autocmd to insert AI-generated commit message
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "gitcommit",
      callback = function(args)
        if vim.g.neogit_ai_message then
          -- Insert the AI message at the beginning of the buffer
          vim.api.nvim_buf_set_lines(args.buf, 0, 0, false, { vim.g.neogit_ai_message, "" })
          -- Clear the message so it doesn't get reused
          vim.g.neogit_ai_message = nil
        end
      end,
    })

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

    require("neogit").setup(opts)
  end,

  opts = {
    kind = "vsplit",
    graph_style = "kitty",
    integrations = {
      diffview = true,
      telescope = false,
      snacks = true,
    },
    merge_editor = {
      kind = "auto",
    },
    commit_view = {
      kind = "vsplit",
    },
    log_view = {
      kind = "tab",
    },
    autoinstall = true,
    -- Set default popup configurations
    builders = {
      NeogitLogPopup = function(popup)
        -- Enable graph, color, and decorate by default
        for _, arg in ipairs(popup.state.args) do
          if arg.cli == "graph" and arg.type == "switch" then
            arg.enabled = true
          elseif arg.cli == "color" and arg.type == "switch" then
            arg.enabled = true
          elseif arg.cli == "decorate" and arg.type == "switch" then
            arg.enabled = true
          end
        end
      end,
    },
    mappings = {
      popup = {
        ["m"] = false,
        ["M"] = "MergePopup",
      },
      status = {
        ["C"] = "YankSelected",
        ["m"] = false, -- disable merge to use your custom binding
        ["s"] = "Stage", -- override 's' key to stage files
        ["<leader>q"] = "Close", -- Close Neogit
        ["I"] = function()
          require("utils.ai_popup").create()
        end,
        ["E"] = function()
          require("utils.neogit-commands").create_conflict_popup()
        end,
      },
    },
  },
}
