return {
  "kevinhwang91/nvim-ufo",
  dependencies = {
    "kevinhwang91/promise-async",
  },
  event = "BufReadPost",
  opts = {
    -- Use LSP + indent for folding (LSP handles imports auto-fold)
    provider_selector = function(bufnr, filetype, buftype)
      if filetype == "typescript" or filetype == "typescriptreact" then
        return { "lsp", "indent" }
      end
      return { "treesitter", "indent" }
    end,
    -- Auto-fold imports when buffer opens
    close_fold_kinds_for_ft = {
      default = { "imports" },
      typescript = { "imports" },
      typescriptreact = { "imports" },
    },
    -- Disable automatic fold restoration
    enable_get_fold_virt_text = true,
    preview = {
      mappings = {
        scrollB = "",
        scrollF = "",
        scrollU = "",
        scrollD = "",
        scrollE = "",
        scrollY = "",
        jump = "",
        close = "q",
      },
    },
    -- Simple fold text with line count
    fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
      local newVirtText = {}
      local suffix = (" 󰁂 %d "):format(endLnum - lnum)
      local sufWidth = vim.fn.strdisplaywidth(suffix)
      local targetWidth = width - sufWidth
      local curWidth = 0
      for _, chunk in ipairs(virtText) do
        local chunkText = chunk[1]
        local chunkWidth = vim.fn.strdisplaywidth(chunkText)
        if targetWidth > curWidth + chunkWidth then
          table.insert(newVirtText, chunk)
        else
          chunkText = truncate(chunkText, targetWidth - curWidth)
          local hlGroup = chunk[2]
          table.insert(newVirtText, { chunkText, hlGroup })
          chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if curWidth + chunkWidth < targetWidth then
            suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
          end
          break
        end
        curWidth = curWidth + chunkWidth
      end
      table.insert(newVirtText, { suffix, "MoreMsg" })
      return newVirtText
    end,
  },
  config = function(_, opts)
    require("ufo").setup(opts)

    -- Ensure foldlevel is respected
    vim.o.foldlevel = 99
    vim.o.foldlevelstart = 99

    -- Remap fold commands to use UFO's implementation
    -- This prevents fold level from being changed by zR/zM
    vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
    vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
    vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds, { desc = "Open folds except kinds" })
    vim.keymap.set("n", "zm", require("ufo").closeFoldsWith, { desc = "Close folds with level" })

    -- Let treesitter handle all folding - removed manual import folding to avoid conflicts
  end,
}
