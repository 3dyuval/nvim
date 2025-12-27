local run_ai_run = require("run-ai-run")
local M = {}

local DEBUG = false

-- Files to exclude from full diff (noisy/generated files)
M.ignored_files = {
  "lazy-lock.json",
  "package-lock.json",
  "pnpm-lock.yaml",
  "yarn.lock",
}

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
  vim.api.nvim_buf_set_name(buf, "AI Commit Debug")
  vim.cmd("vsplit")
  vim.api.nvim_win_set_buf(0, buf)
end

-- Close debug buffer if it exists
function M.close_debug_buffer()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(buf)
    if name:match("AI Commit Debug$") then
      local wins = vim.fn.win_findbuf(buf)
      for _, win in ipairs(wins) do
        vim.api.nvim_win_close(win, true)
      end
      vim.api.nvim_buf_delete(buf, { force = true })
      break
    end
  end
end

-- Message options (conventional, body, short, detailed, footer, type, scope)
---@param msg_opts table
---@return string prompt
local function build_prompt(msg_opts)
  local parts = { "write a commit message" }

  -- User-provided values or placeholders
  local subject_wrap = msg_opts.subject_wrap or 50
  local body_wrap = msg_opts.wrap or 72
  local _type = (msg_opts.commit_type and msg_opts.commit_type ~= "") and msg_opts.commit_type or "<TYPE>"
  local _scope = (msg_opts.scope and msg_opts.scope ~= "") and msg_opts.scope or "<SCOPE>"
  local _subject = (msg_opts.subject and msg_opts.subject ~= "") and msg_opts.subject or "<SUBJECT>"

  if msg_opts.conventional then
    table.insert(parts, "using conventional commit format: " .. _type .. "(" .. _scope .. "): " .. _subject)
    table.insert(parts, "complete fields marked with <> based on the diff")
  elseif msg_opts.subject and msg_opts.subject ~= "" then
    table.insert(parts, msg_opts.subject)
  end

  table.insert(parts, "subject line max " .. subject_wrap .. " characters")

  if msg_opts.body then
    if msg_opts.body_format == "paragraph" then
      table.insert(parts, "include body as natural paragraph explaining WHY")
    else
      table.insert(parts, "include body as bullet points describing WHAT changed at high level")
    end
    table.insert(parts, "wrap body lines at " .. body_wrap .. " characters")
  else
    table.insert(parts, "subject line ONLY, no body")
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

  -- Preview prompt mode: show prompt and wait for confirmation
  if msg_options.preview_prompt then
    local buf = vim.api.nvim_create_buf(false, true)
    local lines = vim.split(prompt, "\n")
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
    vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })
    vim.api.nvim_buf_set_name(buf, "AI Prompt Preview")

    vim.cmd("split")
    vim.api.nvim_win_set_buf(0, buf)

    -- Keymaps: <CR> to proceed, q to cancel
    vim.keymap.set("n", "<CR>", function()
      vim.api.nvim_win_close(0, true)
      vim.api.nvim_buf_delete(buf, { force = true })
      msg_options.preview_prompt = false -- prevent recursion
      M.generateCommitMessage(opts)
    end, { buffer = buf, desc = "Proceed with AI generation" })

    vim.keymap.set("n", "q", function()
      vim.api.nvim_win_close(0, true)
      vim.api.nvim_buf_delete(buf, { force = true })
      vim.notify("AI commit cancelled", vim.log.levels.INFO)
    end, { buffer = buf, desc = "Cancel" })

    vim.notify("Press <CR> to proceed, q to cancel", vim.log.levels.INFO)
    return
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

return M
