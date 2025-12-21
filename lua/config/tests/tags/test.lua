-- Tests for HTML tag selection functionality
-- Run via: make test

local code = require("utils.code")

local function set_curpos(pos)
  vim.api.nvim_win_set_cursor(0, { pos[1], pos[2] - 1 })
end

local function setup_html_buffer(lines)
  local bufnr = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_win_set_buf(0, bufnr)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].filetype = "html"
  -- Force treesitter to parse synchronously
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "html")
  if ok and parser then
    parser:parse()
  end
  return bufnr
end

describe("html tags", function()
  before_each(function()
    local bufnr = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_win_set_buf(0, bufnr)
  end)

  describe("select inner tag (it)", function()
    it("selects content between simple tags", function()
      setup_html_buffer({
        "<div>hello</div>",
      })
      set_curpos({ 1, 6 }) -- cursor on 'h' of hello

      -- Use nvim-surround's it text object
      vim.cmd("normal! vit")
      vim.cmd("normal! y")
      local yanked = vim.fn.getreg('"')

      assert.are.equal("hello", yanked)
    end)

    it("selects content in nested tags from inner", function()
      setup_html_buffer({
        "<div><span>inner</span></div>",
      })
      set_curpos({ 1, 12 }) -- cursor on 'i' of inner

      vim.cmd("normal! vit")
      vim.cmd("normal! y")
      local yanked = vim.fn.getreg('"')

      assert.are.equal("inner", yanked)
    end)

    it("selects multiline content", function()
      setup_html_buffer({
        "<div>",
        "  line 1",
        "  line 2",
        "</div>",
      })
      set_curpos({ 2, 3 }) -- cursor on 'l' of line 1

      vim.cmd("normal! vit")
      vim.cmd("normal! y")
      local yanked = vim.fn.getreg('"')

      -- Should select the inner content (may include newlines)
      assert.is_true(yanked:find("line 1") ~= nil)
      assert.is_true(yanked:find("line 2") ~= nil)
    end)
  end)

  describe("select around tag (at)", function()
    it("selects entire tag including opening and closing", function()
      setup_html_buffer({
        "<div>hello</div>",
      })
      set_curpos({ 1, 6 }) -- cursor on 'h' of hello

      vim.cmd("normal! vat")
      vim.cmd("normal! y")
      local yanked = vim.fn.getreg('"')

      assert.are.equal("<div>hello</div>", yanked)
    end)

    it("selects inner tag when nested", function()
      setup_html_buffer({
        "<div><span>inner</span></div>",
      })
      set_curpos({ 1, 12 }) -- cursor on 'i' of inner

      vim.cmd("normal! vat")
      vim.cmd("normal! y")
      local yanked = vim.fn.getreg('"')

      assert.are.equal("<span>inner</span>", yanked)
    end)
  end)

  describe("self-closing tags", function()
    it("selects self-closing tag in HTML", function()
      setup_html_buffer({
        "<div><img src='test.png' /></div>",
      })
      set_curpos({ 1, 7 }) -- cursor on 'i' of img

      code.select_self_closing_tag()
      vim.cmd("normal! y")
      local yanked = vim.fn.getreg('"')

      assert.are.equal("<img src='test.png' />", yanked)
    end)

    it("selects self-closing tag in Vue", function()
      local bufnr = vim.api.nvim_create_buf(true, true)
      vim.api.nvim_win_set_buf(0, bufnr)
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
        "<template>",
        "  <div><MyComponent :prop='value' /></div>",
        "</template>",
      })
      vim.bo[bufnr].filetype = "vue"
      local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "vue")
      if ok and parser then
        parser:parse()
      end
      set_curpos({ 2, 10 }) -- cursor on 'M' of MyComponent

      code.select_self_closing_tag()
      vim.cmd("normal! y")
      local yanked = vim.fn.getreg('"')

      assert.are.equal("<MyComponent :prop='value' />", yanked)
    end)

    -- TSX: vim.treesitter.get_node() returns nil in headless mode
    -- Works in real usage (verified manually). Skip in CI.
    pending("selects self-closing tag in TSX")
  end)
end)
