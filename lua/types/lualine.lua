---@meta

---@class lualine.Component
---@field [1] string|function Component content
---@field color string|table|function Color configuration
---@field cond function|boolean Condition to show component
---@field draw_empty boolean Draw component when empty
---@field icon string|table Icon configuration
---@field on_click function Click handler
---@field padding number|table Padding configuration
---@field separator string|table Separator configuration

---@class lualine.Section : lualine.Component[]

---@class lualine.Sections
---@field lualine_a lualine.Section
---@field lualine_b lualine.Section
---@field lualine_c lualine.Section
---@field lualine_x lualine.Section
---@field lualine_y lualine.Section
---@field lualine_z lualine.Section

---@class lualine.Config
---@field options table General options
---@field sections lualine.Sections Active statusline sections
---@field inactive_sections lualine.Sections Inactive statusline sections
---@field tabline table Tabline configuration
---@field winbar table Winbar configuration
---@field inactive_winbar table Inactive winbar configuration
---@field extensions table Extensions configuration
