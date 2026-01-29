-- This document tests for critical keys tested in neovim using plenary
-- the describe blocks can have semantic/positional/organizational meaning
-- or it should test different implementations, to document workarounds
-- made while using highly customized keyboard layout and mappings
-- for more context on the organizational methodology @../../../CLAUDE.md
--
-- Entry point for all config tests. Include other test modules here:
require("config.tests.fences.test")
require("config.tests.tags.test")
require("config.tests.surround.test")

-- # Editing
describe("normal inserts/replace", function()
  local function test_insert(key, position, description)
    local initial_line = "hello world"
    local cursor_col = 6
    local expected_result = position == "before" and "helloX world" or "hello Xworld"

    -- Setup buffer with initial content
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { initial_line })
    vim.api.nvim_win_set_cursor(0, { 1, cursor_col })

    -- Execute the key and type 'X'
    vim.cmd("normal " .. key .. "X")
    vim.cmd("stopinsert")

    local result = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
    assert.are.equal(expected_result, result)
  end
  it('should insert before using "r"', function()
    test_insert("r", "before", "insert before cursor")
  end)
  it('should insert after using "t"', function()
    test_insert("t", "after", "insert after cursor")
  end)
end)
describe("paste inserts/replace", function()
  it('should paste before using "v"', function()
    -- todo
  end)
  it('should paste after using "V"', function()
    -- todo
  end)
  it('should paste+replace using "-"', function()
    -- todo
  end)
end)
describe("delete and yank", function()
  it("should delete without registers using _xx", function()
    -- todo
  end)
end)
-- Navigation
describe("Navigation between tabs", function()
  it("should move to tab to the right using <C-.>", function()
    -- todo
  end)
  it("should move to tab to the left using <C-p>", function()
    -- todo
  end)
end)
