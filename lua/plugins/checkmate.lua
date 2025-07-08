return {
  {
    dir = "/home/yuval/checkmate.nvim",
    name = "checkmate.nvim",
    ft = { "markdown", "lua", "python", "javascript", "typescript" },
    opts = {
      files = {
        "*.md",
        "*.ts",
      },
      -- Enable treesitter detection for testing
      treesitter_detection = {
        enabled = true,
        languages = { "lua", "python", "javascript", "typescript" },
        activate_in_all_comments = true,
      },
      keys = {
        ["<leader>tr"] = { rhs = "<cmd>Checkmate toggle<CR>" },
        ["<leader>tn"] = { rhs = "<cmd>Checkmate create<CR>" },
        ["<leader>ta"] = { rhs = "<cmd>Checkmate archive<CR>" },
      },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = { "markdown", "typescript", "javascript", "lua", "python" },
    config = function()
      -- Setup render-markdown with injections
      require('render-markdown').setup({
        file_types = { "markdown", "typescript", "javascript", "lua", "python" },
        checkbox = {
          enabled = true,
          position = "inline",
          unchecked = {
            icon = "󰄱 ",
            highlight = "RenderMarkdownUnchecked",
          },
          checked = {
            icon = "󰱒 ",
            highlight = "RenderMarkdownChecked",
          },
        },
        injections = {
          typescript = {
            enabled = true,
            query = [[
              (comment) @injection.content
              (#lua-match? @injection.content ".*%[[ x]%].*")
              (#set! injection.language "markdown")
              (#set! injection.combined)
            ]],
          },
          javascript = {
            enabled = true,
            query = [[
              (comment) @injection.content
              (#lua-match? @injection.content ".*%[[ x]%].*")
              (#set! injection.language "markdown")
              (#set! injection.combined)
            ]],
          },
          lua = {
            enabled = true,
            query = [[
              (comment) @injection.content
              (#lua-match? @injection.content ".*%[[ x]%].*")
              (#set! injection.language "markdown")
              (#set! injection.combined)
            ]],
          },
          python = {
            enabled = true,
            query = [[
              (comment) @injection.content
              (#lua-match? @injection.content ".*%[[ x]%].*")
              (#set! injection.language "markdown")
              (#set! injection.combined)
            ]],
          },
        },
      })
    end,
  },
}
