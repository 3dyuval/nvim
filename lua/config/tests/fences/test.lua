-- Tests for fenced code block functionality
-- Uses nvim-surround for surround operations and code.lua for text objects
-- Run via: make test

local code = require("utils.code")

-- Helper functions (same pattern as nvim-surround tests)
local set_curpos = function(pos)
  vim.api.nvim_win_set_cursor(0, { pos[1], pos[2] - 1 })
end

local set_lines = function(lines)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end

local check_lines = function(lines)
  assert.are.same(lines, vim.api.nvim_buf_get_lines(0, 0, -1, false))
end

local get_curpos = function()
  local pos = vim.api.nvim_win_get_cursor(0)
  return { pos[1], pos[2] + 1 }
end

-- Helper to setup buffer and ensure treesitter parses
local function setup_md_buffer(lines)
  local bufnr = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_win_set_buf(0, bufnr)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].filetype = "markdown"
  -- Force treesitter to parse synchronously
  local parser = vim.treesitter.get_parser(bufnr, "markdown")
  parser:parse()
  return bufnr
end

describe("fenced code blocks", function()
  before_each(function()
    -- Create a fresh buffer for each test
    local bufnr = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_win_set_buf(0, bufnr)
  end)

  describe("find_fence_at_cursor", function()
    it("finds fence when cursor is inside content", function()
      setup_md_buffer({
        "```lua",
        "local x = 1",
        "```",
      })
      set_curpos({ 2, 1 })

      local node, bufnr = code.find_fence_at_cursor()
      assert.is_not_nil(node)
      assert.is_not_nil(bufnr)
    end)

    it("returns nil when cursor is outside fence", function()
      setup_md_buffer({
        "some text",
        "```lua",
        "local x = 1",
        "```",
        "more text",
      })
      set_curpos({ 1, 1 })

      local node = code.find_fence_at_cursor()
      assert.is_nil(node)
    end)
  end)

  describe("get_fence_type", function()
    it("returns language from fence", function()
      setup_md_buffer({
        "```lua",
        "local x = 1",
        "```",
      })
      set_curpos({ 2, 1 })

      local node, bufnr = code.find_fence_at_cursor()
      local fence_type = code.get_fence_type(node, bufnr)
      assert.are.equal("lua", fence_type)
    end)

    it("returns nil for fence without language", function()
      setup_md_buffer({
        "```",
        "some code",
        "```",
      })
      set_curpos({ 2, 1 })

      local node, bufnr = code.find_fence_at_cursor()
      local fence_type = code.get_fence_type(node, bufnr)
      assert.is_nil(fence_type)
    end)

    it("handles fence with dashes in language", function()
      setup_md_buffer({
        "```type-script",
        "const x = 1",
        "```",
      })
      set_curpos({ 2, 1 })

      local node, bufnr = code.find_fence_at_cursor()
      local fence_type = code.get_fence_type(node, bufnr)
      assert.are.equal("type-script", fence_type)
    end)
  end)

  describe("change_or_add_fence_type", function()
    it("changes existing fence type", function()
      setup_md_buffer({
        "```lua",
        "local x = 1",
        "```",
      })
      set_curpos({ 2, 1 })

      code.change_or_add_fence_type("python")

      check_lines({
        "```python",
        "local x = 1",
        "```",
      })
    end)

    it("adds type to fence without language", function()
      setup_md_buffer({
        "```",
        "some code",
        "```",
      })
      set_curpos({ 2, 1 })

      code.change_or_add_fence_type("javascript")

      check_lines({
        "```javascript",
        "some code",
        "```",
      })
    end)
  end)

  describe("text objects r` and t`", function()
    it("selects inner fence content with r`", function()
      setup_md_buffer({
        "```lua",
        "line 1",
        "line 2",
        "```",
      })
      set_curpos({ 2, 1 })

      -- Use the select function directly instead of keymap
      code.select_fenced_code_block_inner()
      vim.cmd("normal y")
      local yanked = vim.fn.getreg('"')

      assert.are.equal("line 1\nline 2\n", yanked)
    end)

    it("selects around fence with t`", function()
      setup_md_buffer({
        "```lua",
        "content",
        "```",
      })
      set_curpos({ 2, 1 })

      -- Use the select function directly instead of keymap
      code.select_fenced_code_block_around()
      vim.cmd("normal y")
      local yanked = vim.fn.getreg('"')

      assert.are.equal("```lua\ncontent\n```\n", yanked)
    end)
  end)
end)
