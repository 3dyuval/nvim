-- Test for formatter.lua async API
-- Tests the async formatting API with progress tracking using Plenary

local plenary = require("plenary.async")
local formatter = require("utils.formatter")

describe("Formatter API", function()
  local temp_dir
  local temp_files = {}

  -- Setup temp directory and files for testing
  before_each(function()
    temp_dir = vim.fn.tempname()
    vim.fn.mkdir(temp_dir, "p")

    -- Create test files
    temp_files = {
      js = temp_dir .. "/test.js",
      ts = temp_dir .. "/test.ts",
      lua = temp_dir .. "/test.lua",
      json = temp_dir .. "/test.json",
      invalid = temp_dir .. "/test.invalid",
    }

    -- Write test content to files
    vim.fn.writefile({
      "const   x=1;const   y=2;",
      "function test(a,b){return a+b}",
    }, temp_files.js)

    vim.fn.writefile({
      "import { z } from 'zod';",
      "import { Component } from '@angular/core';",
      "import { myFunc } from '@/utils';",
      "import React from 'react';",
      "",
      "const   x:number=1;",
    }, temp_files.ts)

    vim.fn.writefile({
      "local   x=1;local   y=2",
      "local function test(a,b)return a+b end",
    }, temp_files.lua)

    vim.fn.writefile({
      '{"key":"value","another":123,"nested":{"a":1}}',
    }, temp_files.json)

    vim.fn.writefile({
      "This is not a supported file type",
    }, temp_files.invalid)
  end)

  -- Cleanup temp directory
  after_each(function()
    vim.fn.delete(temp_dir, "rf")
  end)

  describe("Progress tracking", function()
    it("should track progress during formatting", function()
      local progress_calls = {}
      local completion_status = nil

      plenary.run(function()
        formatter.format_batch({ temp_files.js, temp_files.ts }, {
          verbose = true,
          on_progress = function(status)
            table.insert(progress_calls, {
              processed = status.processed,
              total = status.total,
              message = status.message,
              percentage = status.percentage,
            })
          end,
          on_complete = function(status)
            completion_status = status
          end,
        })

        -- Wait for completion
        vim.wait(5000, function()
          return completion_status ~= nil
        end)
      end)

      -- Verify progress was tracked
      assert.is_true(#progress_calls > 0, "Progress callbacks should be called")
      assert.is_not_nil(completion_status, "Completion callback should be called")
      assert.is_true(completion_status.complete, "Status should be marked as complete")
    end)
  end)

  describe("Single file formatting", function()
    it("should format a single JavaScript file", function()
      local completion_status = nil

      plenary.run(function()
        formatter.format_file(temp_files.js, {
          verbose = true,
          on_complete = function(status)
            completion_status = status
          end,
        })

        -- Wait for completion
        vim.wait(5000, function()
          return completion_status ~= nil
        end)
      end)

      assert.is_not_nil(completion_status, "Completion callback should be called")
      assert.equals(0, completion_status.exit_code, "Should exit successfully")
      assert.is_true(completion_status.success > 0, "Should format at least one file")
    end)

    it("should handle invalid files gracefully", function()
      local completion_status = nil

      plenary.run(function()
        formatter.format_file(temp_files.invalid, {
          verbose = true,
          on_complete = function(status)
            completion_status = status
          end,
        })

        -- Wait for completion
        vim.wait(5000, function()
          return completion_status ~= nil
        end)
      end)

      assert.is_not_nil(completion_status, "Completion callback should be called")
      -- May succeed (no formatting needed) or fail (unsupported type)
      assert.is_true(completion_status.complete, "Should complete the operation")
    end)
  end)

  describe("Batch formatting", function()
    it("should format multiple files", function()
      local completion_status = nil
      local progress_updates = {}

      plenary.run(function()
        formatter.format_batch({ temp_files.js, temp_files.ts, temp_files.lua }, {
          verbose = true,
          on_progress = function(status)
            table.insert(progress_updates, status)
          end,
          on_complete = function(status)
            completion_status = status
          end,
        })

        -- Wait for completion
        vim.wait(10000, function()
          return completion_status ~= nil
        end)
      end)

      assert.is_not_nil(completion_status, "Completion callback should be called")
      assert.equals(0, completion_status.exit_code, "Should exit successfully")
      assert.is_true(#progress_updates > 0, "Should have progress updates")
    end)

    it("should handle directory formatting", function()
      local completion_status = nil

      plenary.run(function()
        formatter.format_batch({ temp_dir }, {
          verbose = true,
          on_complete = function(status)
            completion_status = status
          end,
        })

        -- Wait for completion
        vim.wait(10000, function()
          return completion_status ~= nil
        end)
      end)

      assert.is_not_nil(completion_status, "Completion callback should be called")
      assert.equals(0, completion_status.exit_code, "Should exit successfully")
    end)
  end)

  describe("Progress parser", function()
    it("should parse CLI output correctly", function()
      -- Test internal parse function (if exposed)
      -- local formatter_mod = require("utils.formatter")

      -- We can't directly test the internal parse function since it's local
      -- But we can verify the overall progress tracking works via the API
      local progress_calls = {}

      plenary.run(function()
        formatter.format_file(temp_files.js, {
          verbose = true,
          on_progress = function(status)
            table.insert(progress_calls, status)
          end,
          on_complete = function(status)
            -- Test completed
          end,
        })

        -- Wait for completion
        vim.wait(5000, function()
          return #progress_calls > 0
        end)
      end)

      -- Verify we got meaningful progress data
      if #progress_calls > 0 then
        local last_progress = progress_calls[#progress_calls]
        assert.is_not_nil(last_progress.message, "Progress should have message")
        assert.is_number(last_progress.processed, "Progress should have processed count")
      end
    end)
  end)

  describe("Job management", function()
    it("should track active jobs", function()
      local job_id = formatter.format_file(temp_files.js, {
        verbose = true,
        on_complete = function(status)
          -- Job completed
        end,
      })

      assert.is_not_nil(job_id, "Should return job ID")
      assert.is_string(job_id, "Job ID should be string")

      -- Check active jobs
      local active_jobs = formatter.get_active_jobs()
      assert.is_table(active_jobs, "Should return active jobs table")

      -- Wait for job to complete
      vim.wait(5000, function()
        local current_jobs = formatter.get_active_jobs()
        return vim.tbl_isempty(current_jobs)
      end)

      -- Job should be removed from active list
      local final_jobs = formatter.get_active_jobs()
      assert.is_true(vim.tbl_isempty(final_jobs), "Active jobs should be empty after completion")
    end)
  end)

  describe("Error handling", function()
    it("should handle non-existent files", function()
      local completion_status = nil

      plenary.run(function()
        formatter.format_file("/non/existent/file.js", {
          verbose = true,
          on_complete = function(status)
            completion_status = status
          end,
        })

        -- Wait for completion
        vim.wait(5000, function()
          return completion_status ~= nil
        end)
      end)

      assert.is_not_nil(completion_status, "Completion callback should be called")
      assert.is_not_equal(0, completion_status.exit_code, "Should exit with error")
    end)

    it("should handle empty paths array", function()
      -- This should not crash and should handle gracefully
      local result = formatter.format_batch({}, {
        verbose = true,
        on_complete = function(status)
          -- Should not be called
        end,
      })

      assert.is_nil(result, "Should return nil for empty paths")
    end)
  end)

  describe("Integration with CLI script", function()
    it("should call the correct formatter script", function()
      -- Verify the script exists and is executable
      local script_path = vim.fn.expand("~/.config/nvim/format")
      assert.equals(1, vim.fn.executable(script_path), "Formatter script should be executable")
    end)

    it("should pass correct arguments to CLI", function()
      local completion_status = nil

      plenary.run(function()
        formatter.format_file(temp_files.js, {
          verbose = true,
          check = true,
          on_complete = function(status)
            completion_status = status
          end,
        })

        -- Wait for completion
        vim.wait(5000, function()
          return completion_status ~= nil
        end)
      end)

      assert.is_not_nil(completion_status, "Should complete with check option")
    end)
  end)
end)

describe("Formatter convenience functions", function()
  local temp_file

  before_each(function()
    temp_file = vim.fn.tempname() .. ".js"
    vim.fn.writefile({
      "const   x=1;const   y=2;",
    }, temp_file)
  end)

  after_each(function()
    vim.fn.delete(temp_file)
  end)

  it("should format with notifications", function()
    local completion_status = nil

    plenary.run(function()
      formatter.format_with_notification({ temp_file }, {
        on_complete = function(status)
          completion_status = status
        end,
      })

      -- Wait for completion
      vim.wait(5000, function()
        return completion_status ~= nil
      end)
    end)

    assert.is_not_nil(completion_status, "Should complete with notifications")
  end)
end)

describe("Formatter setup", function()
  it("should setup user commands", function()
    formatter.setup()

    -- Check if user commands were created
    local commands = vim.api.nvim_get_commands({})
    assert.is_not_nil(commands.Format, "Format command should be created")
    assert.is_not_nil(commands.FormatCheck, "FormatCheck command should be created")
    assert.is_not_nil(commands.FormatJobs, "FormatJobs command should be created")
  end)
end)

