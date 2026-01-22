local M = {}

M.large_preview = {
  layout = {
    box = "horizontal",
    width = 0.9,
    height = 0.9,
    {
      box = "vertical",
      width = 0.4,
      { win = "input", height = 1 },
      { win = "list" },
    },
    { win = "preview", border = true, width = 0.5 },
  },
}

return M
