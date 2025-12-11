-- Plenary tests for keymap-utils
-- Run with: PlenaryBustedFile lua/plugins/keymap-utils/tests/keymap_utils_spec.lua

describe("keymap-utils", function()
  local ku = require("plugins.keymap-utils")

  before_each(function()
    ku.clear_collected_keymaps()
  end)

  describe("desc", function()
    it("accepts table arg with desc and value", function()
      local result = ku.desc({ desc = "Table description", value = "table_action" })
      assert.equals("table_action", result[1])
      local has_desc = false
      for k, v in pairs(result) do
        if type(v) == "table" and v.desc == "Table description" then
          has_desc = true
        end
      end
      assert.is_true(has_desc)
    end)

    it("accepts table arg with expr", function()
      local result = ku.desc({ desc = "Expr table", value = "expr_action", expr = true })
      local has_expr = false
      for k, v in pairs(result) do
        if type(v) == "table" and v.expr == true then
          has_expr = true
        end
      end
      assert.is_true(has_expr)
    end)

    it("accepts table arg with noremap", function()
      local result = ku.desc({ desc = "Noremap test", value = "noremap_action", noremap = true })
      local has_noremap = false
      for k, v in pairs(result) do
        if type(v) == "table" and v.noremap == true then
          has_noremap = true
        end
      end
      assert.is_true(has_noremap)
    end)

    it("accepts table arg with silent", function()
      local result = ku.desc({ desc = "Silent test", value = "silent_action", silent = true })
      local has_silent = false
      for k, v in pairs(result) do
        if type(v) == "table" and v.silent == true then
          has_silent = true
        end
      end
      assert.is_true(has_silent)
    end)

    it("accepts table arg with multiple opts", function()
      local result = ku.desc({
        desc = "Multi opts",
        value = "multi_action",
        expr = true,
        silent = true,
        noremap = true,
      })
      local opts_found = nil
      for k, v in pairs(result) do
        if type(v) == "table" and v.desc then
          opts_found = v
        end
      end
      assert.is_not_nil(opts_found)
      assert.equals("Multi opts", opts_found.desc)
      assert.is_true(opts_found.expr)
      assert.is_true(opts_found.silent)
      assert.is_true(opts_found.noremap)
    end)
  end)

  describe("detect_conflicts", function()
    it("detects duplicate keymaps", function()
      local keymaps = {
        { mode = "n", key = "<leader>f", action = "action1" },
        { mode = "n", key = "<leader>f", action = "action2" },
      }
      local conflicts = ku.detect_conflicts(keymaps, false)
      assert.equals(1, #conflicts)
      assert.equals("duplicate", conflicts[1].type)
    end)

    it("detects builtin overrides when enabled", function()
      local keymaps = {
        { mode = "n", key = "j", action = "custom_down" },
      }
      local conflicts = ku.detect_conflicts(keymaps, true)
      assert.equals(1, #conflicts)
      assert.equals("builtin-override", conflicts[1].type)
    end)

    it("ignores builtin overrides when disabled", function()
      local keymaps = {
        { mode = "n", key = "j", action = "custom_down" },
      }
      local conflicts = ku.detect_conflicts(keymaps, false)
      assert.equals(0, #conflicts)
    end)

    it("returns empty for unique keymaps", function()
      local keymaps = {
        { mode = "n", key = "<leader>a", action = "action1" },
        { mode = "n", key = "<leader>b", action = "action2" },
      }
      local conflicts = ku.detect_conflicts(keymaps, false)
      assert.equals(0, #conflicts)
    end)

    it("distinguishes conflicts by mode", function()
      local keymaps = {
        { mode = "n", key = "<leader>f", action = "normal_action" },
        { mode = "v", key = "<leader>f", action = "visual_action" },
      }
      local conflicts = ku.detect_conflicts(keymaps, false)
      assert.equals(0, #conflicts) -- same key, different modes = no conflict
    end)
  end)

  describe("map", function()
    local test_key = "<leader>_test_ku_123"

    after_each(function()
      pcall(vim.keymap.del, "n", test_key)
    end)

    it("sets keymap with description", function()
      ku.map("n", test_key, ":echo 'test'<CR>", "Test mapping")
      local mapping = vim.fn.maparg(test_key, "n", false, true)
      assert.equals("Test mapping", mapping.desc)
    end)

    it("accepts multiple modes as table", function()
      ku.map({ "n", "v" }, test_key, ":echo 'test'<CR>", "Multi-mode mapping")
      local n_mapping = vim.fn.maparg(test_key, "n", false, true)
      local v_mapping = vim.fn.maparg(test_key, "v", false, true)
      assert.is_not_nil(n_mapping.desc)
      assert.is_not_nil(v_mapping.desc)
      pcall(vim.keymap.del, "v", test_key)
    end)

    it("overwrites existing keymap without error", function()
      ku.map("n", test_key, ":echo 'first'<CR>", "First")
      ku.map("n", test_key, ":echo 'second'<CR>", "Second")
      local mapping = vim.fn.maparg(test_key, "n", false, true)
      assert.equals("Second", mapping.desc)
    end)
  end)

  describe("safe_del", function()
    it("does not error on non-existent keymap", function()
      assert.has_no.errors(function()
        ku.safe_del("n", "<leader>_nonexistent_keymap_xyz")
      end)
    end)
  end)

  describe("cmd", function()
    it("builds command string with <Cr>", function()
      local result = ku.cmd("echo 'hello'")
      assert.equals("<Cmd>echo 'hello'<Cr>", result)
    end)

    it("builds command without execution when exec=false", function()
      local result = ku.cmd("echo 'hello'", false)
      assert.equals(":echo 'hello'", result)
    end)

    it("allows custom exec suffix", function()
      local result = ku.cmd("echo 'hello'", "<Esc>")
      assert.equals("<Cmd>echo 'hello'<Esc>", result)
    end)
  end)

  describe("prefix", function()
    local test_key = "<leader>_pfx_test"

    after_each(function()
      pcall(vim.keymap.del, "n", test_key .. "a")
    end)

    it("creates prefixed keymap function", function()
      local pfx = ku.prefix(test_key)
      pfx("a", ":echo 'prefixed'<CR>", "Prefixed action")
      local mapping = vim.fn.maparg(test_key .. "a", "n", false, true)
      assert.equals("Prefixed action", mapping.desc)
    end)
  end)

  describe("get_builtin_keymaps", function()
    it("returns table with normal mode builtins", function()
      local builtins = ku.get_builtin_keymaps()
      assert.is_not_nil(builtins.n)
      assert.is_not_nil(builtins.n["j"])
      assert.is_not_nil(builtins.n["k"])
    end)

    it("includes descriptions for builtins", function()
      local builtins = ku.get_builtin_keymaps()
      assert.equals("Down", builtins.n["j"].desc)
    end)
  end)

  describe("normalize_keymaps", function()
    it("adds builtin keymaps to empty input", function()
      local normalized = ku.normalize_keymaps({})
      assert.is_not_nil(normalized.n)
      assert.is_not_nil(normalized.n["j"])
      assert.is_true(normalized.n["j"].builtin)
    end)

    it("preserves user keymaps", function()
      local user = {
        n = {
          ["<leader>x"] = { mode = "n", key = "<leader>x", action = "custom" },
        },
      }
      local normalized = ku.normalize_keymaps(user)
      assert.is_not_nil(normalized.n["<leader>x"])
      assert.equals("custom", normalized.n["<leader>x"].action)
    end)
  end)

  describe("introspection", function()
    it("starts with empty collected keymaps", function()
      ku.clear_collected_keymaps()
      assert.equals(0, ku.get_keymap_count())
    end)

    it("get_flat_keymaps_table returns table", function()
      local keymaps = ku.get_flat_keymaps_table()
      assert.is_table(keymaps)
    end)
  end)
end)
