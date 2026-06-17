-- [nfnl] fnl/plugins/graph.fnl
local function _1_(_, opts)
  require("gitgraph").setup(opts)
  local link
  local function _2_(from, to)
    return vim.api.nvim_set_hl(0, from, {link = to, default = false})
  end
  link = _2_
  local apply
  local function _3_()
    link("GitGraphBranch1", "Function")
    link("GitGraphBranch2", "Type")
    link("GitGraphBranch3", "String")
    link("GitGraphBranch4", "Identifier")
    link("GitGraphBranch5", "Special")
    link("GitGraphHash", "Identifier")
    link("GitGraphTimestamp", "Comment")
    link("GitGraphAuthor", "Type")
    link("GitGraphBranchName", "Function")
    link("GitGraphBranchTag", "Constant")
    return link("GitGraphBranchMsg", "Normal")
  end
  apply = _3_
  apply()
  return vim.api.nvim_create_autocmd("ColorScheme", {callback = apply})
end
return {"isakbm/gitgraph.nvim", opts = {git_cmd = "git", format = {timestamp = "%H:%M:%S %d-%m-%Y", fields = {"hash", "timestamp", "author", "branch_name", "tag"}}, symbols = {merge_commit = vim.fn.nr2char(62970), commit = vim.fn.nr2char(62971), merge_commit_end = vim.fn.nr2char(62966), commit_end = vim.fn.nr2char(62967), GVER = vim.fn.nr2char(62929), GHOR = vim.fn.nr2char(62928), GCLD = vim.fn.nr2char(62935), GCRD = "\226\149\173", GCLU = vim.fn.nr2char(62937), GCRU = vim.fn.nr2char(62936), GLRU = vim.fn.nr2char(62949), GLRD = vim.fn.nr2char(62944), GLUD = vim.fn.nr2char(62942), GRUD = vim.fn.nr2char(62939), GFORKU = vim.fn.nr2char(62950), GFORKD = vim.fn.nr2char(62950), GRUDCD = vim.fn.nr2char(62939), GRUDCU = vim.fn.nr2char(62938), GLUDCD = vim.fn.nr2char(62942), GLUDCU = vim.fn.nr2char(62941), GLRDCL = vim.fn.nr2char(62944), GLRDCR = vim.fn.nr2char(62945), GLRUCL = vim.fn.nr2char(62947), GLRUCR = vim.fn.nr2char(62949)}}, config = _1_}
