-- [nfnl] fnl/plugins/lint.fnl
local function _1_(_, opts)
  opts.linters_by_ft = (opts.linters_by_ft or {})
  opts.linters_by_ft.zsh = {"zsh"}
  require("lint").linters["zsh"] = {cmd = "zsh", args = {"-n"}, stream = "stderr", ignore_exitcode = true, parser = require("lint.parser").from_pattern("%s*(.-):%s*(%d+):%s*(.*)", 2, nil, "%3", {source = "zsh"}), stdin = false}
  return nil
end
return {{"mfussenegger/nvim-lint", opts = _1_}}
