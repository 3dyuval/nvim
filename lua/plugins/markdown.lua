local function get_markdown_functions()
  local ok, markdown = pcall(require, "markdown")
  if not ok then
    vim.notify("markdown.nvim not loaded", vim.log.levels.WARN)
    return {}
  end
  return markdown
end

local text_filetypes = { "markdown", "text", "feature", "gitcommit", "org", "rst" }

return {

  -- Core markdown editing with formatting capabilities
  {
    "tadmccorkle/markdown.nvim",
    ft = text_filetypes,
    opts = {
      -- configuration here or empty for defaults
    },
    keys = {
      -- Markdown-specific commands (only work in markdown files)
      { "<leader>pf", "<cmd>MDTaskToggle<cr>", ft = text_filetypes, desc = "Toggle task checkbox" },
      { "<leader>pl", "<cmd>MDListItemBelow<cr>", ft = text_filetypes, desc = "Add list item below" },
      { "<leader>ph", "]]", ft = text_filetypes, desc = "Next heading" },
      { "<leader>pk", "gliw", mode = "n", ft = text_filetypes, desc = "Add link to word" },
      { "<leader>pk", "gl", mode = "v", ft = text_filetypes, desc = "Add link (visual)" },
    },
  },

  -- Markdown preview in browser with Mermaid support
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    keys = {
      { "<leader>pp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview Toggle" },
    },
    config = function()
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_refresh_slow = 0
      vim.g.mkdp_command_for_global = 0
      vim.g.mkdp_open_to_the_world = 0
      vim.g.mkdp_open_ip = ""
      vim.g.mkdp_browser = ""
      vim.g.mkdp_echo_preview_url = 0
      vim.g.mkdp_browserfunc = ""
      vim.g.mkdp_preview_options = {
        mkit = {},
        katex = {},
        uml = {},
        maid = {}, -- Enable Mermaid diagrams
        disable_sync_scroll = 0,
        sync_scroll_type = "middle",
        hide_yaml_meta = 1,
        sequence_diagrams = {},
        flowchart_diagrams = {},
        content_editable = false,
        disable_filename = 0,
        toc = {},
      }
      vim.g.mkdp_markdown_css = ""
      vim.g.mkdp_highlight_css = ""
      vim.g.mkdp_port = ""
      vim.g.mkdp_page_title = "「${name}」"
      vim.g.mkdp_filetypes = { "markdown" }
      vim.g.mkdp_theme = "dark"
    end,
  },

  -- Enhanced in-buffer markdown rendering
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      file_types = { "markdown" },
      code = {
        sign = false,
        width = "block",
        right_pad = 1,
      },
      heading = {
        sign = false,
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
      },
    },
    ft = { "markdown" },
  },

  -- Markdown task management with checkboxes
  {
    "bngarren/checkmate.nvim",
    ft = text_filetypes,
    opts = {
      files = {
        "*.md",
        "*.txt",
        "*.feature",
        "*.org",
        "*.rst",
      },
      keys = {
        ["<leader>pt"] = { rhs = "<cmd>Checkmate toggle<CR>" },
        ["<leader>pn"] = { rhs = "<cmd>Checkmate create<CR>" },
        ["<leader>pa"] = { rhs = "<cmd>Checkmate archive<CR>" },
      },
    },
  },

  -- Table mode for better markdown tables
  {
    "dhruvasagar/vim-table-mode",
    ft = text_filetypes,
    config = function()
      vim.g.table_mode_corner = "|"
      vim.g.table_mode_corner_corner = "|"
      vim.g.table_mode_header_fillchar = "-"
    end,
    keys = {
      { "<leader>pm", "<cmd>TableModeToggle<cr>", ft = text_filetypes, desc = "Toggle table mode" },
      { "<leader>pr", "<cmd>Tableize<cr>", ft = text_filetypes, desc = "Tableize selection" },
    },
  },
}
