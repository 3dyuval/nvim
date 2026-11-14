-- [nfnl] fnl/workspace/commitlint.fnl
local function _1_(args)
  local bufnr = args.buf
  local script = (vim.fn.stdpath("config") .. "/scripts/commitlint.sh")
  local name = vim.api.nvim_buf_get_name(bufnr)
  local cwd
  if name and (name ~= "") then
    cwd = vim.fs.dirname(name)
  else
    cwd = vim.fn.getcwd()
  end
  local function _3_(out)
    if vim.api.nvim_buf_is_valid(bufnr) and (out.code == 0) then
      local ok, parsed = pcall(vim.json.decode, (out.stdout or "{}"))
      if ok then
        vim.b[bufnr]["commitlint_types"] = (parsed.types or {})
        vim.b[bufnr]["commitlint_scopes"] = (parsed.scopes or {})
        return nil
      else
        return nil
      end
    else
      return nil
    end
  end
  return vim.system({ "bash", script }, { cwd = cwd, text = true }, vim.schedule_wrap(_3_))
end
vim.api.nvim_create_autocmd("FileType", { pattern = "gitcommit", callback = _1_ })
local function _6_(args)
  local bufnr = args.buf
  local function _7_()
    local ok, blink = pcall(require, "blink.cmp")
    if
      ok
      and vim.api.nvim_buf_is_valid(bufnr)
      and (vim.api.nvim_get_current_buf() == bufnr)
      and vim.startswith(vim.api.nvim_get_mode().mode, "i")
      and not blink.is_visible()
    then
      return blink.show()
    else
      return nil
    end
  end
  return vim.defer_fn(_7_, 100)
end
vim.api.nvim_create_autocmd("FileType", { pattern = "gitcommit", callback = _6_ })
local function _9_()
  if vim.bo.filetype == "gitcommit" then
    local function _10_()
      local ok, blink = pcall(require, "blink.cmp")
      if ok and blink.snippet_active() and not blink.is_visible() then
        return blink.show()
      else
        return nil
      end
    end
    return vim.defer_fn(_10_, 50)
  else
    return nil
  end
end
vim.api.nvim_create_autocmd("User", { pattern = "BlinkCmpAccept", callback = _9_ })
local function _13_(args)
  local bufnr = args.buf
  if vim.fn.executable("commitlint") == 1 then
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local msg = table.concat(lines, "\n")
    local name = vim.api.nvim_buf_get_name(bufnr)
    local cwd
    if name and (name ~= "") then
      cwd = vim.fs.dirname(name)
    else
      cwd = vim.fn.getcwd()
    end
    local function _15_(out)
      if out.code ~= 0 then
        local body
        do
          local s = ((out.stdout or "") .. (out.stderr or ""))
          body = vim.trim(s)
        end
        local _16_
        if body == "" then
          _16_ = "commitlint: invalid commit message"
        else
          _16_ = body
        end
        return vim.notify(_16_, vim.log.levels.ERROR, { title = "commitlint" })
      else
        return nil
      end
    end
    return vim.system({ "commitlint" }, { stdin = msg, text = true, cwd = cwd }, vim.schedule_wrap(_15_))
  else
    return nil
  end
end
vim.api.nvim_create_autocmd("BufWritePost", { pattern = "gitcommit", callback = _13_ })
return {}
