-- [nfnl] fnl/config/keymaps/markdown.fnl
local base = "Checkmate "
local function register_checkmate(bufnr, prefix, node)
  for key, tail in pairs(node) do
    local lhs = (prefix .. key)
    if type(tail) == "string" then
      vim.keymap.set(
        "n",
        lhs,
        ("<Cmd>" .. base .. tail .. "<CR>"),
        { buffer = bufnr, silent = true, desc = (base .. tail) }
      )
    else
      register_checkmate(bufnr, lhs, tail)
    end
  end
  return nil
end
local tree = {
  ["<leader>t"] = {
    t = "create",
    ["<CR>"] = "toggle",
    y = "check",
    x = "uncheck",
    c = "archive",
    l = "lint",
    ["="] = "cycle_next",
    ["-"] = "cycle_previous",
    X = "remove_all_metadata",
    ["]"] = "metadata jump_next",
    ["["] = "metadata jump_previous",
    v = "metadata select_value",
  },
}
local function register_links(bufnr)
  vim.keymap.set("n", "<leader>tl", "gliw", { buffer = bufnr, desc = "Add link to word" })
  return vim.keymap.set("v", "<leader>tl", "gl", { buffer = bufnr, desc = "Add link (visual)" })
end
local group = vim.api.nvim_create_augroup("checkmate_keymaps", { clear = true })
local function _2_(ev)
  return register_checkmate(ev.buf, "", tree)
end
vim.api.nvim_create_autocmd("FileType", { pattern = "markdown", group = group, callback = _2_ })
local function _3_(ev)
  return register_links(ev.buf)
end
return vim.api.nvim_create_autocmd(
  "FileType",
  { pattern = { "markdown", "text", "feature", "gitcommit" }, group = group, callback = _3_ }
)
