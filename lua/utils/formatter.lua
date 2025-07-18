local M = {}

-- Dependencies
local plenary_job = require("plenary.job")

-- Constants
local FORMATTER_SCRIPT = vim.fn.expand("~/.config/nvim/format")
local PROGRESS_ICONS = {
  processing = "⏳",
  success = "✅",
  error = "❌",
  warning = "⚠️",
  info = "ℹ️"
}

-- State management
local active_jobs = {}
local job_counter = 0

-- ============================================================================
-- UTILITIES
-- ============================================================================

-- Generate unique job ID
local function generate_job_id()
  job_counter = job_counter + 1
  return "formatter_job_" .. job_counter
end

-- Log helper
local function log(level, message)
  vim.schedule(function()
    vim.notify(message, level)
  end)
end

-- Parse formatter script output for progress
local function parse_progress_line(line)
  -- Match patterns from our CLI script
  local patterns = {
    -- [INFO] Using ROOT_DIR: /path
    { pattern = "^%[INFO%]%s+(.+)$", type = "info" },
    -- [VERBOSE] Processing file: path (extension: ext)
    { pattern = "^%[VERBOSE%]%s+Processing file:%s+(.+)%s+%(extension:%s+(%w+)%)$", type = "processing", extract = { "file", "ext" } },
    -- [VERBOSE] Formatted file with Tool
    { pattern = "^%[VERBOSE%]%s+Formatted.+%s+(.+)%s+with%s+(%w+)$", type = "success", extract = { "file", "tool" } },
    -- [ERROR] Failed to format file
    { pattern = "^%[ERROR%]%s+Failed to format%s+(.+)$", type = "error", extract = { "file" } },
    -- [WARN] warnings
    { pattern = "^%[WARN%]%s+(.+)$", type = "warning" },
    -- Biome output: "Formatted 1 file in 2ms. Fixed 1 file."
    { pattern = "^Formatted%s+(%d+)%s+files?%s+in%s+%d+ms%..*$", type = "success", extract = { "count" } },
    -- "All files processed successfully"
    { pattern = "^All files processed successfully$", type = "complete" },
    -- "Some files failed to process"
    { pattern = "^Some files failed to process$", type = "error" },
  }

  for _, p in ipairs(patterns) do
    local matches = { line:match(p.pattern) }
    if #matches > 0 then
      local result = {
        type = p.type,
        message = line,
        raw = line
      }
      
      if p.extract then
        for i, key in ipairs(p.extract) do
          result[key] = matches[i]
        end
      end
      
      return result
    end
  end
  
  return { type = "raw", message = line, raw = line }
end

-- ============================================================================
-- PROGRESS TRACKING
-- ============================================================================

-- Progress tracker class
local ProgressTracker = {}
ProgressTracker.__index = ProgressTracker

function ProgressTracker.new(total_files, callbacks)
  local self = setmetatable({}, ProgressTracker)
  self.total_files = total_files or 0
  self.processed_files = 0
  self.success_count = 0
  self.error_count = 0
  self.warning_count = 0
  self.current_file = nil
  self.callbacks = callbacks or {}
  self.start_time = vim.loop.now()
  return self
end

function ProgressTracker:update(parsed_output)
  local changed = false
  
  if parsed_output.type == "processing" and parsed_output.file then
    self.current_file = parsed_output.file
    changed = true
  elseif parsed_output.type == "success" then
    if parsed_output.file then
      self.success_count = self.success_count + 1
      self.processed_files = self.processed_files + 1
      changed = true
    elseif parsed_output.count then
      self.success_count = self.success_count + tonumber(parsed_output.count)
      self.processed_files = self.processed_files + tonumber(parsed_output.count)
      changed = true
    end
  elseif parsed_output.type == "error" then
    self.error_count = self.error_count + 1
    if parsed_output.file then
      self.processed_files = self.processed_files + 1
    end
    changed = true
  elseif parsed_output.type == "warning" then
    self.warning_count = self.warning_count + 1
    changed = true
  end
  
  if changed and self.callbacks.on_progress then
    vim.schedule(function()
      self.callbacks.on_progress(self:get_status())
    end)
  end
end

function ProgressTracker:get_status()
  local elapsed = (vim.loop.now() - self.start_time) / 1000
  local status = {
    processed = self.processed_files,
    total = self.total_files,
    success = self.success_count,
    errors = self.error_count,
    warnings = self.warning_count,
    current_file = self.current_file,
    elapsed = elapsed,
    percentage = self.total_files > 0 and math.floor((self.processed_files / self.total_files) * 100) or 0
  }
  
  -- Generate status message
  if self.current_file then
    status.message = string.format("%s Processing %s", PROGRESS_ICONS.processing, 
      vim.fn.fnamemodify(self.current_file, ":t"))
  elseif self.processed_files > 0 then
    status.message = string.format("Processed %d/%d files (%d%%) - %d success, %d errors", 
      self.processed_files, self.total_files, status.percentage, self.success_count, self.error_count)
  else
    status.message = "Starting formatter..."
  end
  
  return status
end

function ProgressTracker:complete(exit_code)
  local final_status = self:get_status()
  final_status.complete = true
  final_status.exit_code = exit_code
  
  -- Generate completion message
  if exit_code == 0 then
    if self.success_count > 0 then
      final_status.message = string.format("%s Formatted %d files successfully", 
        PROGRESS_ICONS.success, self.success_count)
    else
      final_status.message = string.format("%s No files needed formatting", PROGRESS_ICONS.info)
    end
  else
    final_status.message = string.format("%s Formatting failed - %d errors", 
      PROGRESS_ICONS.error, self.error_count)
  end
  
  if self.warning_count > 0 then
    final_status.message = final_status.message .. string.format(" (%d warnings)", self.warning_count)
  end
  
  if self.callbacks.on_complete then
    vim.schedule(function()
      self.callbacks.on_complete(final_status)
    end)
  end
end

-- ============================================================================
-- CORE FORMATTER API
-- ============================================================================

-- Estimate file count for progress tracking
local function estimate_file_count(paths)
  local count = 0
  for _, path in ipairs(paths) do
    if vim.fn.isdirectory(path) == 1 then
      -- Estimate based on supported file types
      local result = vim.fn.system(string.format(
        "find %s -type f \\( -name '*.js' -o -name '*.jsx' -o -name '*.ts' -o -name '*.tsx' -o -name '*.json' -o -name '*.lua' \\) | wc -l",
        vim.fn.shellescape(path)
      ))
      count = count + tonumber(result) or 0
    else
      count = count + 1
    end
  end
  return count
end

-- Run formatter with progress tracking
function M.format_batch(paths, options)
  options = options or {}
  
  if not paths or #paths == 0 then
    log(vim.log.levels.WARN, "No paths provided for formatting")
    return
  end
  
  -- Validate formatter script exists
  if vim.fn.executable(FORMATTER_SCRIPT) ~= 1 then
    log(vim.log.levels.ERROR, "Formatter script not found or not executable: " .. FORMATTER_SCRIPT)
    return
  end
  
  local job_id = generate_job_id()
  local estimated_files = estimate_file_count(paths)
  
  -- Create progress tracker
  local tracker = ProgressTracker.new(estimated_files, {
    on_progress = options.on_progress,
    on_complete = options.on_complete
  })
  
  -- Build command arguments
  local args = vim.list_extend({}, paths)
  if options.verbose then
    table.insert(args, 1, "--verbose")
  end
  if options.check then
    table.insert(args, 1, "--check")
  end
  if options.dry_run then
    table.insert(args, 1, "--dry-run")
  end
  
  -- Create job
  local job = plenary_job:new({
    command = FORMATTER_SCRIPT,
    args = args,
    cwd = vim.fn.getcwd(),
    env = {
      ROOT_DIR = vim.fn.expand("~/.config/nvim")
    },
    on_stdout = function(_, line)
      local parsed = parse_progress_line(line)
      tracker:update(parsed)
    end,
    on_stderr = function(_, line)
      local parsed = parse_progress_line(line)
      tracker:update(parsed)
    end,
    on_exit = function(_, exit_code)
      tracker:complete(exit_code)
      active_jobs[job_id] = nil
    end
  })
  
  -- Store job for potential cancellation
  active_jobs[job_id] = {
    job = job,
    tracker = tracker,
    paths = paths,
    options = options
  }
  
  -- Start job
  job:start()
  
  -- Initial progress callback
  if options.on_progress then
    vim.schedule(function()
      options.on_progress(tracker:get_status())
    end)
  end
  
  return job_id
end

-- Format single file
function M.format_file(filepath, options)
  return M.format_batch({ filepath }, options)
end

-- Format current buffer
function M.format_current_buffer(options)
  local filepath = vim.api.nvim_buf_get_name(0)
  if filepath == "" then
    log(vim.log.levels.WARN, "Current buffer has no associated file")
    return
  end
  
  return M.format_file(filepath, options)
end

-- Cancel running job
function M.cancel_job(job_id)
  local job_info = active_jobs[job_id]
  if job_info then
    job_info.job:shutdown()
    active_jobs[job_id] = nil
    log(vim.log.levels.INFO, "Cancelled formatting job: " .. job_id)
    return true
  end
  return false
end

-- Get active jobs
function M.get_active_jobs()
  local jobs = {}
  for job_id, job_info in pairs(active_jobs) do
    jobs[job_id] = {
      paths = job_info.paths,
      options = job_info.options,
      status = job_info.tracker:get_status()
    }
  end
  return jobs
end

-- ============================================================================
-- CONVENIENCE FUNCTIONS
-- ============================================================================

-- Format with progress notification
function M.format_with_notification(paths, options)
  options = options or {}
  
  -- Add default progress notifications
  local original_on_progress = options.on_progress
  local original_on_complete = options.on_complete
  
  options.on_progress = function(status)
    if original_on_progress then
      original_on_progress(status)
    end
    
    -- Update status line or show notification every 10%
    if status.percentage > 0 and status.percentage % 10 == 0 then
      log(vim.log.levels.INFO, status.message)
    end
  end
  
  options.on_complete = function(status)
    if original_on_complete then
      original_on_complete(status)
    end
    
    -- Show completion notification
    local level = status.exit_code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
    log(level, status.message)
  end
  
  return M.format_batch(paths, options)
end

-- Format selected files in picker
function M.format_picker_selection(picker, options)
  if not picker then
    log(vim.log.levels.WARN, "No picker provided")
    return
  end
  
  local picker_extensions = require("utils.picker-extensions")
  local items = {}
  
  -- Get selected or current items
  if picker.selected and #picker.selected > 0 then
    items = picker.selected
  else
    local current_item, err = picker_extensions.get_current_item(picker)
    if current_item and not err then
      items = { current_item }
    end
  end
  
  if #items == 0 then
    log(vim.log.levels.WARN, "No files selected for formatting")
    return
  end
  
  -- Extract file paths
  local paths = {}
  for _, item in ipairs(items) do
    if item.file then
      table.insert(paths, item.file)
    end
  end
  
  if #paths == 0 then
    log(vim.log.levels.WARN, "No valid file paths found in selection")
    return
  end
  
  return M.format_with_notification(paths, options)
end

-- ============================================================================
-- SETUP AND CONFIGURATION
-- ============================================================================

-- Setup formatter with default options
function M.setup(opts)
  opts = opts or {}
  
  -- Set default options
  M.defaults = vim.tbl_deep_extend("force", {
    verbose = false,
    auto_notification = true,
    progress_interval = 1000, -- ms
  }, opts)
  
  -- Create user commands
  vim.api.nvim_create_user_command("Format", function(args)
    local paths = #args.fargs > 0 and args.fargs or { vim.fn.expand("%") }
    M.format_with_notification(paths, { verbose = args.bang })
  end, {
    desc = "Format files using the batch formatter",
    nargs = "*",
    bang = true,
    complete = "file"
  })
  
  vim.api.nvim_create_user_command("FormatCheck", function(args)
    local paths = #args.fargs > 0 and args.fargs or { vim.fn.expand("%") }
    M.format_with_notification(paths, { check = true, verbose = args.bang })
  end, {
    desc = "Check file formatting without making changes",
    nargs = "*",
    bang = true,
    complete = "file"
  })
  
  vim.api.nvim_create_user_command("FormatJobs", function()
    local jobs = M.get_active_jobs()
    if vim.tbl_isempty(jobs) then
      log(vim.log.levels.INFO, "No active formatting jobs")
    else
      for job_id, job_info in pairs(jobs) do
        local status = job_info.status
        log(vim.log.levels.INFO, string.format("Job %s: %s", job_id, status.message))
      end
    end
  end, {
    desc = "Show active formatting jobs"
  })
  
  log(vim.log.levels.INFO, "Formatter API initialized")
end

return M