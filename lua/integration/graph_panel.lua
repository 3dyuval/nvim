--- GraphPanel: Displays gitgraph output instead of file tree
--- Part of the custom view kind system for composable views

local oop = require("diffview.oop")
local Panel = require("diffview.ui.panel").Panel
local config = require("diffview.config")

---@class GraphPanel : Panel
local GraphPanel = oop.create_class("GraphPanel", Panel)

GraphPanel.bufopts = vim.tbl_extend("force", Panel.bufopts, {
  filetype = "DiffviewGraph",
})

---@param render_data table Graph render data {lines, highlights}
function GraphPanel:init(render_data)
  local conf = config.get_config()
  self:super({
    config = conf.file_panel.win_config,
    bufname = "DiffviewGraph",
  })
  self.render_data = render_data

  self:on_autocmd("BufNew", {
    callback = function()
      self:setup_buffer()
    end,
  })
end

function GraphPanel:setup_buffer()
  local conf = self:apply_keymaps("file_panel", { nowait = true })
  local help_keymap = config.find_help_keymap(conf.keymaps.file_panel)
  if help_keymap then
    self.help_mapping = help_keymap[2]
  end
end

---@override
function GraphPanel:open()
  GraphPanel.super_class.open(self)
  local conf = self:get_config()
  if not (conf.type == "split" and conf.width == "auto") then
    vim.cmd("wincmd =")
  end
end

---Render gitgraph data to buffer
---@override
function GraphPanel:render()
  if not self.render_data then
    return
  end

  local bufnr = self.bufid
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })

  -- Write gitgraph lines
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, self.render_data.lines)

  -- Apply gitgraph highlights
  for _, hl in ipairs(self.render_data.highlights) do
    vim.api.nvim_buf_add_highlight(bufnr, -1, hl.hg, hl.row, hl.start, hl.stop)
  end

  vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
end

---Redraw the buffer (called after render)
---@override
function GraphPanel:redraw()
  GraphPanel.super_class.redraw(self)
end

return GraphPanel
