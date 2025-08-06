return {
  "lewis6991/gitsigns.nvim",
  event = "BufReadPre",
  opts = function()
    return {
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        -- Navigation adapted for HAEI layout (]e = next, [e = prev)
        map("n", "A", gs.next_hunk, "Next Hunk")
        map("n", "E", gs.prev_hunk, "Prev Hunk")

        -- Stage/reset hunks
        map({ "n", "v" }, "<leader>gg", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        map({ "n", "v" }, "<leader>gx", ":Gitsigns reset_hunk<CR>", "Reset Hunk")

        -- Buffer operations
        map("n", "<leader>gG", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>gu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>gX", gs.reset_buffer, "Reset Buffer")

        -- Preview and blame
        map("n", "<leader>gp", gs.preview_hunk, "Preview Hunk")
        map("n", "<leader>gB", function()
          gs.blame_line({ full = true })
        end, "Blame Line")

        -- map("n", "<leader>gD", function()
        --   gs.diffthis("~")
        -- end, "Diff This ~")

        -- Text object for hunks
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
      end,
    }
  end,
}
