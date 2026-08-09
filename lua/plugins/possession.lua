-- [nfnl] fnl/plugins/possession.fnl
local persisted_globals = {"FFFLayout", "AiCommitLastSettings"}
local function _1_()
  local has_real_buffer_3f
  local function _2_()
    local found = false
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
      if found then break end
      if (vim.api.nvim_buf_is_loaded(b) and vim.bo[b].buflisted and (vim.bo[b].buftype == "") and (vim.api.nvim_buf_get_name(b) ~= "")) then
        found = true
      else
      end
    end
    return found
  end
  has_real_buffer_3f = _2_
  local function _4_(_name)
    local data = {}
    for _, g in ipairs(persisted_globals) do
      data[g] = vim.g[g]
    end
    return data
  end
  local function _5_(_name, user_data)
    if user_data then
      for _, g in ipairs(persisted_globals) do
        if (user_data[g] ~= nil) then
          vim.g[g] = user_data[g]
        else
        end
      end
    else
    end
    return user_data
  end
  local function _8_(_name, _user_data)
    local function _9_()
      for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if (vim.api.nvim_buf_is_loaded(b) and (vim.bo[b].buftype == "") and (vim.api.nvim_buf_get_name(b) ~= "")) then
          local function _10_()
            return vim.cmd("filetype detect")
          end
          vim.api.nvim_buf_call(b, _10_)
        else
        end
      end
      return nil
    end
    return vim.schedule(_9_)
  end
  return require("possession").setup({autoload = "auto_cwd", autosave = {current = has_real_buffer_3f, cwd = has_real_buffer_3f, on_load = true, on_quit = true}, commands = {save = "PossessionSave", load = "PossessionLoad", save_cwd = "PossessionSaveCwd", load_cwd = "PossessionLoadCwd", delete = "PossessionDelete", list = "PossessionList", list_cwd = "PossessionListCwd"}, hooks = {before_save = _4_, before_load = _5_, after_load = _8_}})
end
return {"jedrzejboczar/possession.nvim", dependencies = {"nvim-lua/plenary.nvim"}, config = _1_, lazy = false}
