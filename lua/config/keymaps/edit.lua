-- [nfnl] fnl/config/keymaps/edit.fnl
local base = "Checkmate "
local function register(bufnr, prefix, node)
  for key, tail in pairs(node) do
    local lhs = (prefix .. key)
    if (type(tail) == "string") then
      vim.keymap.set("n", lhs, ("<Cmd>" .. base .. tail .. "<CR>"), {buffer = bufnr, silent = true, desc = (base .. tail)})
    else
      register(bufnr, lhs, tail)
    end
  end
  return nil
end
local tree = {["<leader>t"] = {r = "create", n = "toggle", y = "check", x = "uncheck", c = "archive", l = "lint", ["="] = "cycle_next", ["-"] = "cycle_previous", X = "remove_all_metadata", ["]"] = "metadata jump_next", ["["] = "metadata jump_previous", v = "metadata select_value"}}
local function _2_(ev)
  return register(ev.buf, "", tree)
end
return vim.api.nvim_create_autocmd("FileType", {pattern = "markdown", group = vim.api.nvim_create_augroup("checkmate_keymaps", {clear = true}), callback = _2_})
