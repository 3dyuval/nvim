-- Tests for surround keymaps (Graphite layout)
-- Verifies: ys (add), xs (delete), ws (change), s/S (visual)
-- Run via: make test

local function set_curpos(pos)
  vim.api.nvim_win_set_cursor(0, { pos[1], pos[2] - 1 })
end

local function set_lines(lines)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end

local function check_lines(lines)
  assert.are.same(lines, vim.api.nvim_buf_get_lines(0, 0, -1, false))
end

-- Add nvim-surround to runtimepath (needed for headless plenary tests)
local surround_path = vim.fn.stdpath("data") .. "/lazy/nvim-surround"
if vim.fn.isdirectory(surround_path) == 1 then
  vim.opt.runtimepath:append(surround_path)
end

-- Initialize nvim-surround with custom config before tests
-- This mirrors the setup from lua/plugins/surround.lua
require("nvim-surround").setup({
  keymaps = {
    insert = "<C-g>s",
    insert_line = "<C-g>S",
    normal = "ys",
    normal_cur = "yss",
    normal_line = "yS",
    normal_cur_line = "ySS",
    visual = "S",
    visual_line = "gS",
    delete = "ds",
    change = "cs",
    change_line = "cS",
  },
  surrounds = {
    -- Custom spacing: opening = non-spaced, closing = spaced
    ["("] = { add = { "(", ")" } },
    [")"] = { add = { "( ", " )" } },
    ["{"] = { add = { "{", "}" } },
    ["}"] = { add = { "{ ", " }" } },
    ["<"] = { add = { "< ", " >" } },
    [">"] = { add = { "<", ">" } },
    ["["] = { add = { "[", "]" } },
    ["]"] = { add = { "[ ", " ]" } },
    -- Markdown
    ["*"] = { add = { "**", "**" } },
    ["_"] = { add = { "_", "_" } },
    ["~"] = { add = { "~", "~" } },
  },
})

-- Set up graphite mappings (xs, ws, xst)
vim.keymap.set("n", "xs", "<Plug>(nvim-surround-delete)", { desc = "Delete surround" })
vim.keymap.set("n", "ws", "<Plug>(nvim-surround-change)", { desc = "Change surround" })
vim.keymap.set("n", "xst", function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("dst", true, false, true), "m", false)
end, { desc = "Delete surrounding tag" })

describe("surround", function()
  before_each(function()
    local bufnr = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_win_set_buf(0, bufnr)
    vim.bo[bufnr].modifiable = true
  end)

  describe("add surround (ys)", function()
    it("surrounds word with parentheses using ys", function()
      set_lines({ "hello world" })
      set_curpos({ 1, 1 })
      vim.cmd("normal ysiw(")
      check_lines({ "(hello) world" })
    end)

    it("surrounds word with spaced parentheses using )", function()
      set_lines({ "hello world" })
      set_curpos({ 1, 1 })
      vim.cmd("normal ysiw)")
      check_lines({ "( hello ) world" })
    end)

    it("surrounds word with brackets using [", function()
      set_lines({ "hello world" })
      set_curpos({ 1, 1 })
      vim.cmd("normal ysiw[")
      check_lines({ "[hello] world" })
    end)

    it("surrounds word with spaced brackets using ]", function()
      set_lines({ "hello world" })
      set_curpos({ 1, 1 })
      vim.cmd("normal ysiw]")
      check_lines({ "[ hello ] world" })
    end)

    it("surrounds word with braces using {", function()
      set_lines({ "hello world" })
      set_curpos({ 1, 1 })
      vim.cmd("normal ysiw{")
      check_lines({ "{hello} world" })
    end)

    it("surrounds word with spaced braces using }", function()
      set_lines({ "hello world" })
      set_curpos({ 1, 1 })
      vim.cmd("normal ysiw}")
      check_lines({ "{ hello } world" })
    end)

    it("surrounds word with double quotes", function()
      set_lines({ "hello world" })
      set_curpos({ 1, 1 })
      vim.cmd('normal ysiw"')
      check_lines({ '"hello" world' })
    end)

    it("surrounds word with single quotes", function()
      set_lines({ "hello world" })
      set_curpos({ 1, 1 })
      vim.cmd("normal ysiw'")
      check_lines({ "'hello' world" })
    end)
  end)

  describe("surround line (yss)", function()
    it("surrounds entire line with parentheses", function()
      set_lines({ "hello world" })
      set_curpos({ 1, 1 })
      vim.cmd("normal yss(")
      check_lines({ "(hello world)" })
    end)

    it("surrounds entire line with quotes", function()
      set_lines({ "hello world" })
      set_curpos({ 1, 1 })
      vim.cmd('normal yss"')
      check_lines({ '"hello world"' })
    end)
  end)

  describe("delete surround (ds)", function()
    it("deletes parentheses", function()
      set_lines({ "(hello) world" })
      set_curpos({ 1, 2 })
      vim.cmd("normal ds(")
      check_lines({ "hello world" })
    end)

    it("deletes brackets", function()
      set_lines({ "[hello] world" })
      set_curpos({ 1, 2 })
      vim.cmd("normal ds[")
      check_lines({ "hello world" })
    end)

    it("deletes braces", function()
      set_lines({ "{hello} world" })
      set_curpos({ 1, 2 })
      vim.cmd("normal ds{")
      check_lines({ "hello world" })
    end)

    it("deletes double quotes", function()
      set_lines({ '"hello" world' })
      set_curpos({ 1, 2 })
      vim.cmd('normal ds"')
      check_lines({ "hello world" })
    end)

    it("deletes single quotes", function()
      set_lines({ "'hello' world" })
      set_curpos({ 1, 2 })
      vim.cmd("normal ds'")
      check_lines({ "hello world" })
    end)
  end)

  describe("change surround (cs)", function()
    it("changes parentheses to brackets", function()
      set_lines({ "(hello) world" })
      set_curpos({ 1, 2 })
      vim.cmd("normal cs([")
      check_lines({ "[hello] world" })
    end)

    it("changes brackets to braces", function()
      set_lines({ "[hello] world" })
      set_curpos({ 1, 2 })
      vim.cmd("normal cs[{")
      check_lines({ "{hello} world" })
    end)

    it("changes double quotes to single quotes", function()
      set_lines({ '"hello" world' })
      set_curpos({ 1, 2 })
      vim.cmd("normal cs\"'")
      check_lines({ "'hello' world" })
    end)
  end)

  describe("visual surround (S)", function()
    it("surrounds visual selection with parentheses", function()
      set_lines({ "hello world" })
      set_curpos({ 1, 1 })
      vim.cmd("normal viwS(")
      check_lines({ "(hello) world" })
    end)

    it("surrounds visual selection with quotes", function()
      set_lines({ "hello world" })
      set_curpos({ 1, 1 })
      vim.cmd('normal viwS"')
      check_lines({ '"hello" world' })
    end)

    it("surrounds visual line selection with newlines", function()
      set_lines({ "hello world" })
      set_curpos({ 1, 1 })
      vim.cmd("normal VS(")
      check_lines({ "(", "hello world", ")" })
    end)
  end)

  describe("markdown surrounds", function()
    it("surrounds with bold (**)", function()
      set_lines({ "hello world" })
      set_curpos({ 1, 1 })
      vim.cmd("normal ysiw*")
      check_lines({ "**hello** world" })
    end)

    it("surrounds with italic (_)", function()
      set_lines({ "hello world" })
      set_curpos({ 1, 1 })
      vim.cmd("normal ysiw_")
      check_lines({ "_hello_ world" })
    end)

    it("surrounds with strikethrough (~)", function()
      set_lines({ "hello world" })
      set_curpos({ 1, 1 })
      vim.cmd("normal ysiw~")
      check_lines({ "~hello~ world" })
    end)

    it("deletes bold markers (requires 2x ds*)", function()
      set_lines({ "**hello** world" })
      set_curpos({ 1, 3 })
      -- Custom * surround adds ** but ds* deletes single * pairs
      -- Need to run twice or add custom find/delete patterns
      vim.cmd("normal ds*ds*")
      check_lines({ "hello world" })
    end)

    it("deletes italic markers", function()
      set_lines({ "_hello_ world" })
      set_curpos({ 1, 2 })
      vim.cmd("normal ds_")
      check_lines({ "hello world" })
    end)
  end)

  describe("delete surrounding tag (dst)", function()
    it("deletes surrounding HTML tag", function()
      set_lines({ "<div>hello</div>" })
      set_curpos({ 1, 6 })
      vim.cmd("normal dst")
      check_lines({ "hello" })
    end)

    it("deletes nested tag from inside", function()
      set_lines({ "<div><span>hello</span></div>" })
      set_curpos({ 1, 12 })
      vim.cmd("normal dst")
      check_lines({ "<div>hello</div>" })
    end)
  end)

  describe("graphite mappings (xs, ws)", function()
    it("xs deletes surround (mapped to ds)", function()
      set_lines({ "(hello) world" })
      set_curpos({ 1, 2 })
      vim.cmd("normal xs(")
      check_lines({ "hello world" })
    end)

    it("ws changes surround (mapped to cs)", function()
      set_lines({ "(hello) world" })
      set_curpos({ 1, 2 })
      vim.cmd("normal ws([")
      check_lines({ "[hello] world" })
    end)

    -- xst uses feedkeys which doesn't work reliably in headless mode
    pending("xst deletes surrounding tag")
  end)
end)
