local run_ai_run = require("run-ai-run")
local M = {}

local DEBUG = true

local function open_debug_buffer(info)
  local buf = vim.api.nvim_create_buf(false, true)
  local lines = {
    "=== Git Command ===",
    info.git_cmd or "",
    "",
    "=== Message Options ===",
  }
  for _, line in ipairs(vim.split(vim.inspect(info.msg_opts or {}), "\n")) do
    table.insert(lines, line)
  end
  table.insert(lines, "")
  table.insert(lines, "=== Prompt to Agent ===")
  for _, line in ipairs(vim.split(info.prompt or "", "\n")) do
    table.insert(lines, line)
  end
  table.insert(lines, "")
  table.insert(lines, "=== Git Diff ===")
  for _, line in ipairs(vim.split(info.diff or "", "\n")) do
    table.insert(lines, line)
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
  vim.cmd("vsplit")
  vim.api.nvim_win_set_buf(0, buf)
end

--- Build prompt from message options
---@param msg_opts table Message options (conventional, body, short, detailed, footer, type, scope)
---@return string prompt
local function build_prompt(msg_opts)
  local parts = { "write a commit message" }

  if msg_opts.conventional then
    local conv = "using conventional commit format: <type>(<scope>): <subject>"
    if msg_opts.commit_type and msg_opts.scope then
      conv = conv .. ". Use type=" .. msg_opts.commit_type .. " and scope=" .. msg_opts.scope
    elseif msg_opts.commit_type then
      conv = conv .. ". Use type=" .. msg_opts.commit_type .. ", infer appropriate scope from the diff"
    elseif msg_opts.scope then
      conv = conv .. ". Use scope=" .. msg_opts.scope .. ", infer appropriate type (feat/fix/chore/etc) from the diff"
    else
      conv = conv .. ". Infer appropriate type and scope from the diff"
    end
    table.insert(parts, conv)
  end

  if msg_opts.short then
    table.insert(parts, "max 10 words")
  elseif msg_opts.detailed then
    table.insert(parts, "with full detailed context")
  end

  if msg_opts.body then
    table.insert(parts, "include detailed body explaining WHY")
  end

  if msg_opts.footer and msg_opts.footer ~= "" then
    table.insert(parts, "add footer: " .. msg_opts.footer)
  end

  return table.concat(parts, ", ") .. " based on this diff"
end

function M.generateCommitMessage(opts)
  opts = opts or {}
  local msg_options = opts.msg_options or {}
  local on_success = opts.on_success or function(message) end
  local on_error = opts.on_error or function(error_msg) end
  local diff = opts.diff -- pass diff directly

  if not diff or diff == "" then
    on_error("No diff provided")
    return
  end

  local prompt = build_prompt(msg_options) .. "\n\n" .. diff

  if DEBUG then
    vim.schedule(function()
      open_debug_buffer({
        git_cmd = "(diff passed directly)",
        msg_opts = msg_options,
        prompt = build_prompt(msg_options),
        diff = diff,
      })
    end)
  end

  run_ai_run.run(prompt, {
    on_success = function(message)
      message = message:gsub("[\n\r]+$", "")
      if message and message ~= "" then
        on_success(message)
      else
        on_error("Failed to generate AI commit message")
      end
    end,
    on_error = function(err)
      on_error("Failed to generate AI commit message")
    end,
  })
end

-- TODO: neogit staged view can be stale, using direct diff pass instead
-- function M.generateCommitMessageFromGit(opts)
--   opts = opts or {}
--   local diff_options = opts.diff_options or { cached = true }
--   local msg_options = opts.msg_options or {}
--   local on_success = opts.on_success or function(message) end
--   local on_error = opts.on_error or function(error_msg) end
--   local diff_args = { "diff" }
--   if diff_options.cached then
--     table.insert(diff_args, "--cached")
--   end
--   if diff_options.stat then
--     table.insert(diff_args, "--stat")
--   end
--   if diff_options.name_only then
--     table.insert(diff_args, "--name-only")
--   end
--   if diff_options.ignore_whitespace then
--     table.insert(diff_args, "--ignore-all-space")
--   end
--   if diff_options.find_renames then
--     table.insert(diff_args, "-M")
--   end
--   if diff_options.find_copies then
--     table.insert(diff_args, "-C")
--   end
--
--   local git_cmd = "git " .. table.concat(diff_args, " ")
--
--   run_ai_run
--     .job({
--       command = "git",
--       args = diff_args,
--       on_exit = function(diff_job, return_val)
--         if return_val ~= 0 then
--           vim.schedule(function()
--             on_error("Git diff failed")
--           end)
--           return
--         end
--         local diff = table.concat(diff_job:result(), "\n")
--         if diff == "" then
--           vim.schedule(function()
--             on_error("No changes found")
--           end)
--           return
--         end
--
--         M.generateCommitMessage({
--           diff = diff,
--           msg_options = msg_options,
--           on_success = on_success,
--           on_error = on_error,
--         })
--       end,
--     })
--     :start()
-- end
return M
