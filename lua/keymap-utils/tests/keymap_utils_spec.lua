-- Plenary tests for keymap-utils
-- Run with: PlenaryBustedFile lua/keymap-utils/tests/keymap_utils_spec.lua

describe("keymap-utils", function()
  local ku = require("keymap-utils")

  before_each(function()
    ku.clear_collected_keymaps()
  end)

  describe("create_smart_map table syntax", function()
    local test_key = "<leader>_smartmap_test"
    local map = ku.create_smart_map()

    after_each(function()
      pcall(vim.keymap.del, "n", test_key)
      pcall(vim.keymap.del, "n", test_key .. "a")
      pcall(vim.keymap.del, "n", test_key .. "b")
    end)

    it("accepts action at [1] with desc", function()
      map({
        [test_key] = { ":echo 'test'<CR>", desc = "Test action" },
      })
      local mapping = vim.fn.maparg(test_key, "n", false, true)
      assert.equals("Test action", mapping.desc)
    end)

    it("accepts rhs as alternative to [1]", function()
      map({
        [test_key] = { rhs = ":echo 'rhs test'<CR>", desc = "RHS test" },
      })
      local mapping = vim.fn.maparg(test_key, "n", false, true)
      assert.equals("RHS test", mapping.desc)
    end)

    it("supports nested groups", function()
      map({
        [test_key] = {
          a = { ":echo 'nested a'<CR>", desc = "Nested A" },
          b = { ":echo 'nested b'<CR>", desc = "Nested B" },
        },
      })
      local mapping_a = vim.fn.maparg(test_key .. "a", "n", false, true)
      local mapping_b = vim.fn.maparg(test_key .. "b", "n", false, true)
      assert.equals("Nested A", mapping_a.desc)
      assert.equals("Nested B", mapping_b.desc)
    end)

    it("supports group descriptions for which-key", function()
      -- This test verifies groups are collected, not that which-key receives them
      map({
        [test_key] = {
          group = "Test Group",
          a = { ":echo 'in group'<CR>", desc = "In group" },
        },
      })
      local groups = ku.get_group_descriptions()
      local found = false
      for _, g in ipairs(groups) do
        if g[1] == test_key and g.group == "Test Group" then
          found = true
        end
      end
      assert.is_true(found)
    end)

    it("supports remap option for chaining mappings", function()
      local test_remap_key = "<leader>_remap_test"
      map({
        [test_remap_key] = { "j", desc = "Remap to j", remap = true },
      })
      local mapping = vim.fn.maparg(test_remap_key, "n", false, true)
      assert.equals("Remap to j", mapping.desc)
      -- noremap=0 means remap is enabled (will follow other mappings)
      assert.equals(0, mapping.noremap)
      pcall(vim.keymap.del, "n", test_remap_key)
    end)

    it("defaults to noremap (no remap) when remap not specified", function()
      local test_noremap_key = "<leader>_noremap_test"
      map({
        [test_noremap_key] = { "j", desc = "Default noremap" },
      })
      local mapping = vim.fn.maparg(test_noremap_key, "n", false, true)
      -- noremap=1 means it won't follow other mappings
      assert.equals(1, mapping.noremap)
      pcall(vim.keymap.del, "n", test_noremap_key)
    end)

    it("supports cmd = '...' syntax for commands", function()
      local test_cmd_key = "<leader>_cmd_test"
      map({
        [test_cmd_key] = { cmd = "echo 'hello'", desc = "Echo command" },
      })
      local mapping = vim.fn.maparg(test_cmd_key, "n", false, true)
      assert.equals("<Cmd>echo 'hello'<CR>", mapping.rhs)
      assert.equals("Echo command", mapping.desc)
      pcall(vim.keymap.del, "n", test_cmd_key)
    end)

    it("supports cmd with exec = false for prefill only", function()
      local test_prefill_key = "<leader>_prefill_test"
      map({
        [test_prefill_key] = { cmd = "Octo ", exec = false, desc = "Octo prefill" },
      })
      local mapping = vim.fn.maparg(test_prefill_key, "n", false, true)
      assert.equals(":Octo ", mapping.rhs)
      assert.equals("Octo prefill", mapping.desc)
      pcall(vim.keymap.del, "n", test_prefill_key)
    end)

    it("supports cmd in nested groups", function()
      local test_nested_cmd_key = "<leader>_nested_cmd"
      map({
        [test_nested_cmd_key] = {
          group = "Test",
          a = { cmd = "Neogit", desc = "Open Neogit" },
        },
      })
      local mapping = vim.fn.maparg(test_nested_cmd_key .. "a", "n", false, true)
      assert.equals("<Cmd>Neogit<CR>", mapping.rhs)
      pcall(vim.keymap.del, "n", test_nested_cmd_key .. "a")
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

  describe("inspection", function()
    it("starts with empty collected keymaps", function()
      ku.clear_collected_keymaps()
      assert.equals(0, ku.get_keymap_count())
    end)

    it("get_flat_keymaps_table returns table", function()
      local keymaps = ku.get_flat_keymaps_table()
      assert.is_table(keymaps)
    end)
  end)

  describe("disabled keymaps", function()
    local test_key = "<leader>_disabled_test"
    local map = ku.create_smart_map()

    before_each(function()
      ku.clear_disabled_keymaps()
    end)

    after_each(function()
      pcall(vim.keymap.del, "n", test_key)
      pcall(vim.keymap.del, "n", test_key .. "a")
      pcall(vim.keymap.del, "n", test_key .. "b")
    end)

    it("does not map keymap with disabled = true", function()
      map({
        [test_key] = { ":echo 'disabled'<CR>", desc = "Disabled keymap", disabled = true },
      })
      local mapping = vim.fn.maparg(test_key, "n", false, true)
      assert.equals("", mapping.rhs or "")
    end)

    it("stores disabled keymap in collection", function()
      map({
        [test_key] = { ":echo 'disabled'<CR>", desc = "Disabled keymap", disabled = true },
      })
      local disabled = ku.get_disabled_keymaps()
      assert.equals(1, #disabled)
      assert.equals(test_key, disabled[1].key)
      assert.equals("Disabled keymap", disabled[1].desc)
      assert.is_true(disabled[1].disabled)
    end)

    it("maps active keymaps while storing disabled ones", function()
      map({
        [test_key] = {
          a = { ":echo 'active'<CR>", desc = "Active keymap" },
          b = { ":echo 'disabled'<CR>", desc = "Disabled keymap", disabled = true },
        },
      })
      local mapping_a = vim.fn.maparg(test_key .. "a", "n", false, true)
      local mapping_b = vim.fn.maparg(test_key .. "b", "n", false, true)
      assert.equals("Active keymap", mapping_a.desc)
      assert.equals("", mapping_b.rhs or "")

      local disabled = ku.get_disabled_keymaps()
      assert.equals(1, #disabled)
      assert.equals(test_key .. "b", disabled[1].key)
    end)

    it("clear_disabled_keymaps empties the collection", function()
      map({
        [test_key] = { ":echo 'disabled'<CR>", desc = "Disabled", disabled = true },
      })
      assert.equals(1, #ku.get_disabled_keymaps())
      ku.clear_disabled_keymaps()
      assert.equals(0, #ku.get_disabled_keymaps())
    end)
  end)

  describe("keymap tree", function()
    local test_key = "<leader>_tree_test"
    local map = ku.create_smart_map()

    before_each(function()
      ku.clear_keymap_tree()
      ku.clear_disabled_keymaps()
    end)

    after_each(function()
      pcall(vim.keymap.del, "n", test_key .. "a")
      pcall(vim.keymap.del, "n", test_key .. "b")
      pcall(vim.keymap.del, "n", test_key .. "ga")
    end)

    it("builds tree for simple keymaps", function()
      map({
        [test_key] = {
          a = { ":echo 'a'<CR>", desc = "Action A" },
          b = { ":echo 'b'<CR>", desc = "Action B" },
        },
      })
      local tree = ku.get_keymap_tree()
      assert.is_not_nil(tree[test_key])
      assert.is_not_nil(tree[test_key]["a"])
      assert.is_not_nil(tree[test_key]["b"])
    end)

    it("builds tree with group metadata", function()
      map({
        [test_key] = {
          group = "Test Group",
          a = { ":echo 'a'<CR>", desc = "Action A" },
        },
      })
      local tree = ku.get_keymap_tree()
      assert.is_not_nil(tree[test_key]._meta)
      assert.equals("group", tree[test_key]._meta.type)
      assert.equals("Test Group", tree[test_key]._meta.group)
    end)

    it("stores keymap metadata in tree nodes", function()
      map({
        [test_key] = {
          a = { ":echo 'a'<CR>", desc = "Action A" },
        },
      })
      local tree = ku.get_keymap_tree()
      local meta = tree[test_key]["a"]._meta
      assert.equals("keymap", meta.type)
      assert.equals("Action A", meta.desc)
      assert.equals(test_key .. "a", meta.key)
    end)

    it("flatten_keymap_tree returns items with depth", function()
      map({
        [test_key] = {
          group = "Test",
          a = { ":echo 'a'<CR>", desc = "Action A" },
        },
      })
      local flat = ku.flatten_keymap_tree()
      assert.is_true(#flat >= 2) -- at least group + keymap

      local has_group = false
      local has_keymap = false
      for _, item in ipairs(flat) do
        if item.type == "group" and item.group == "Test" then
          has_group = true
          assert.equals(0, item.depth)
        end
        if item.type == "keymap" and item.desc == "Action A" then
          has_keymap = true
          assert.equals(1, item.depth)
        end
      end
      assert.is_true(has_group)
      assert.is_true(has_keymap)
    end)

    it("clear_keymap_tree empties the tree", function()
      map({
        [test_key] = {
          a = { ":echo 'a'<CR>", desc = "Action A" },
        },
      })
      assert.is_not_nil(next(ku.get_keymap_tree()))
      ku.clear_keymap_tree()
      assert.is_nil(next(ku.get_keymap_tree()))
    end)
  end)

  describe("modifier flags", function()
    local map = ku.create_smart_map()
    local ctrl = ku.ctrl
    local shift = ku.shift
    local alt = ku.alt

    before_each(function()
      ku.clear_keymap_tree()
    end)

    after_each(function()
      pcall(vim.keymap.del, "n", "<C-p>")
      pcall(vim.keymap.del, "n", "<C-.>")
      pcall(vim.keymap.del, "n", "<S-a>")
      pcall(vim.keymap.del, "n", "<A-x>")
      pcall(vim.keymap.del, "n", "<C-S-p>")
    end)

    it("applies ctrl modifier to child keys", function()
      map({
        [ctrl] = {
          p = { ":echo 'ctrl-p'<CR>", desc = "Ctrl P" },
        },
      })
      local mapping = vim.fn.maparg("<C-p>", "n", false, true)
      assert.equals("Ctrl P", mapping.desc)
    end)

    it("applies shift modifier to child keys", function()
      map({
        [shift] = {
          a = { ":echo 'shift-a'<CR>", desc = "Shift A" },
        },
      })
      local mapping = vim.fn.maparg("<S-a>", "n", false, true)
      assert.equals("Shift A", mapping.desc)
    end)

    it("applies alt modifier to child keys", function()
      map({
        [alt] = {
          x = { ":echo 'alt-x'<CR>", desc = "Alt X" },
        },
      })
      local mapping = vim.fn.maparg("<A-x>", "n", false, true)
      assert.equals("Alt X", mapping.desc)
    end)

    it("combines nested modifiers", function()
      map({
        [ctrl] = {
          [shift] = {
            p = { ":echo 'ctrl-shift-p'<CR>", desc = "Ctrl Shift P" },
          },
        },
      })
      local mapping = vim.fn.maparg("<C-S-p>", "n", false, true)
      assert.equals("Ctrl Shift P", mapping.desc)
    end)

    it("applies modifier to multiple children", function()
      map({
        [ctrl] = {
          p = { ":echo 'prev'<CR>", desc = "Previous" },
          ["."] = { ":echo 'next'<CR>", desc = "Next" },
        },
      })
      local mapping_p = vim.fn.maparg("<C-p>", "n", false, true)
      local mapping_dot = vim.fn.maparg("<C-.>", "n", false, true)
      assert.equals("Previous", mapping_p.desc)
      assert.equals("Next", mapping_dot.desc)
    end)

    it("stores modified key in tree", function()
      map({
        [ctrl] = {
          p = { ":echo 'ctrl-p'<CR>", desc = "Ctrl P" },
        },
      })
      local tree = ku.get_keymap_tree()
      assert.is_not_nil(tree["<C-p>"])
      assert.is_not_nil(tree["<C-p>"]._meta)
      assert.equals("<C-p>", tree["<C-p>"]._meta.key)
    end)
  end)
end)
