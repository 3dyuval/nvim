-- [nfnl] fnl/plugins/ufo.fnl
local function provider_selector(_bufnr, filetype, _buftype)
  if (filetype == "typescript") or (filetype == "typescriptreact") then
    return { "lsp", "indent" }
  elseif filetype == "gitcommit" then
    return { "indent" }
  else
    return { "treesitter", "indent" }
  end
end
local function fold_virt_text_handler(virt_text, lnum, end_lnum, width, truncate)
  local new_virt_text = {}
  local suffix_fmt = string.format(" \243\176\129\130 %d ", (end_lnum - lnum))
  local suf_width = vim.fn.strdisplaywidth(suffix_fmt)
  local target_width = (width - suf_width)
  local suffix = suffix_fmt
  local cur_width = 0
  for _, chunk in ipairs(virt_text) do
    local chunk_text = chunk[1]
    local chunk_width = vim.fn.strdisplaywidth(chunk_text)
    if target_width > (cur_width + chunk_width) then
      table.insert(new_virt_text, chunk)
      cur_width = (cur_width + chunk_width)
    else
      local trimmed = truncate(chunk_text, (target_width - cur_width))
      local hl_group = chunk[2]
      local trimmed_width = vim.fn.strdisplaywidth(trimmed)
      table.insert(new_virt_text, { trimmed, hl_group })
      if (cur_width + trimmed_width) < target_width then
        suffix = (suffix .. string.rep(" ", (target_width - cur_width - trimmed_width)))
      else
      end
      break
    end
  end
  table.insert(new_virt_text, { suffix, "MoreMsg" })
  return new_virt_text
end
return {
  "kevinhwang91/nvim-ufo",
  dependencies = { "kevinhwang91/promise-async" },
  event = "BufReadPost",
  opts = {
    provider_selector = provider_selector,
    close_fold_kinds_for_ft = { default = { "imports" }, typescript = { "imports" }, typescriptreact = { "imports" } },
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
    fold_virt_text_handler = fold_virt_text_handler,
  },
}
