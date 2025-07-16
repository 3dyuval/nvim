-- Enhanced diff highlighting using colorscheme colors
local function setup_diff_highlights()
  -- Get colors from current theme
  local function get_hl_color(group, attr)
    local hl = vim.api.nvim_get_hl(0, { name = group })
    return hl[attr] and string.format("#%06x", hl[attr]) or nil
  end

  -- Use theme colors with fallbacks
  local green = get_hl_color("String", "fg") or get_hl_color("GitSignsAdd", "fg") or "#a3d977"
  local red = get_hl_color("Error", "fg") or get_hl_color("GitSignsDelete", "fg") or "#ff6b6b"
  local yellow = get_hl_color("Warning", "fg") or get_hl_color("GitSignsChange", "fg") or "#ffeb3b"
  -- local bg_normal = get_hl_color("Normal", "bg") or "#1e1e1e" -- Reserved for future use
  local comment = get_hl_color("Comment", "fg") or "#666666"

  -- Create darker variants for backgrounds
  local function darken_color(color, amount)
    amount = amount or 0.3
    local r = tonumber(color:sub(2, 3), 16)
    local g = tonumber(color:sub(4, 5), 16)
    local b = tonumber(color:sub(6, 7), 16)

    r = math.floor(r * amount)
    g = math.floor(g * amount)
    b = math.floor(b * amount)

    return string.format("#%02x%02x%02x", r, g, b)
  end

  -- Enhanced diff highlighting using theme colors
  vim.api.nvim_set_hl(0, "DiffAdd", {
    bg = darken_color(green, 0.2),
    fg = green,
  })
  vim.api.nvim_set_hl(0, "DiffDelete", {
    bg = darken_color(red, 0.2),
    fg = red,
  })
  vim.api.nvim_set_hl(0, "DiffChange", {
    bg = darken_color(yellow, 0.2),
    fg = yellow,
  })
  vim.api.nvim_set_hl(0, "DiffText", {
    bg = darken_color(yellow, 0.4),
    fg = yellow,
    bold = true,
  })

  -- Line number highlighting using theme colors
  vim.api.nvim_set_hl(0, "LineNrAbove", { fg = comment })
  vim.api.nvim_set_hl(0, "LineNrBelow", { fg = comment })
  vim.api.nvim_set_hl(0, "CursorLineNr", { fg = yellow, bold = true })
end

-- Apply highlights when entering diff buffers
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    if vim.wo.diff then
      setup_diff_highlights()
      -- Show line numbers prominently in diff mode
      vim.wo.number = true
      vim.wo.relativenumber = false
    end
  end,
})

return {
  setup = setup_diff_highlights,
}
