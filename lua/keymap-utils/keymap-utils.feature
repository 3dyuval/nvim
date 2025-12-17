Feature: Smart keymap binding for neovim
  Implementation: ./init.lua

  Background:
    Given keymap-utils is required as "kmu"
    And a smart map is created with "local map = kmu.create_smart_map()"

  # ==========================================================================
  # IMPLEMENTED: Basic Keymap Binding
  # ==========================================================================

  @implemented
  Scenario: Simple keymap with action and description
    When I define a keymap:
      """lua
      map({
        h = { "h", desc = "Left" },
      })
      """
    Then "h" is mapped to "h" in normal mode
    And the keymap has description "Left"

  @implemented
  Scenario: Keymap with function action
    When I define a keymap:
      """lua
      map({
        ["<leader>f"] = { some_function, desc = "Do something" },
      })
      """
    Then "<leader>f" calls "some_function" in normal mode

  @implemented
  Scenario: Keymap with rhs alternative syntax
    When I define a keymap:
      """lua
      map({
        h = { rhs = "h", desc = "Left" },
      })
      """
    Then "h" is mapped to "h" in normal mode

  @implemented
  Scenario: Keymap with vim options
    When I define a keymap:
      """lua
      map({
        gf = { some_function, desc = "Follow link", expr = true, silent = true },
      })
      """
    Then "gf" is mapped with "expr = true" and "silent = true"

  @implemented
  Scenario: Keymap with del option to remove alternative key
    When I define a keymap:
      """lua
      map({
        h = { "h", desc = "Left", del = "j" },
      })
      """
    Then "h" is mapped to "h"
    And "j" keymap is deleted

  # ==========================================================================
  # IMPLEMENTED: Mode Specification
  # ==========================================================================

  @implemented
  Scenario: Keymap with explicit mode
    When I define a keymap:
      """lua
      map({
        [mode] = { "n", "o", "x" },
        h = { "h", desc = "Left" },
      })
      """
    Then "h" is mapped in normal, operator-pending, and visual modes

  @implemented
  Scenario: Keymap with mode modifier for nested keys
    Given "local x = kmu.mod('x')" creates a visual mode modifier
    When I define a keymap:
      """lua
      map({
        x = { "dd", desc = "Delete line" },
        [x] = {
          x = { "d", desc = "Delete selection" },
        },
      })
      """
    Then "x" maps to "dd" in normal mode
    And "x" maps to "d" in visual mode

  # ==========================================================================
  # IMPLEMENTED: Modifier Keys
  # ==========================================================================

  @implemented
  Scenario: Keymap with ctrl modifier
    Given "local ctrl = kmu.key('C')" creates a Ctrl modifier
    And "local _ = kmu._" is the key template
    When I define a keymap:
      """lua
      map({
        [ctrl + _] = {
          p = { cmd("BufferLineCyclePrev"), desc = "Previous buffer" },
        },
      })
      """
    Then "<C-p>" is mapped to ":BufferLineCyclePrev<CR>"

  @implemented
  Scenario: Keymap with multiple modifiers
    Given "local ctrl = kmu.key('C')" and "local shift = kmu.key('S')"
    When I define a keymap:
      """lua
      map({
        [ctrl + shift + _] = {
          s = { cmd("wa"), desc = "Save all" },
        },
      })
      """
    Then "<C-S-s>" is mapped to ":wa<CR>"

  # ==========================================================================
  # IMPLEMENTED: Nested Groups (Which-Key Integration)
  # ==========================================================================

  @implemented
  Scenario: Nested group with which-key description
    When I define a keymap:
      """lua
      map({
        ["<leader>g"] = {
          group = "Git",
          n = { cmd("Neogit"), desc = "Open Neogit" },
        },
      })
      """
    Then "<leader>gn" is mapped to ":Neogit<CR>"
    And which-key shows "<leader>g" as group "Git"

  @implemented
  Scenario: Deeply nested groups
    When I define a keymap:
      """lua
      map({
        ["<leader>g"] = {
          group = "Git",
          d = {
            group = "Diff",
            o = { cmd("DiffviewOpen"), desc = "Open" },
            c = { cmd("DiffviewClose"), desc = "Close" },
          },
        },
      })
      """
    Then "<leader>gdo" is mapped to ":DiffviewOpen<CR>"
    And "<leader>gdc" is mapped to ":DiffviewClose<CR>"
    And which-key shows "<leader>gd" as group "Diff"

  @implemented
  Scenario: Register groups with which-key
    When I call "kmu.register_groups()"
    Then all collected group descriptions are registered with which-key

  # ==========================================================================
  # IMPLEMENTED: Command Syntax
  # ==========================================================================

  @implemented
  Scenario: Command using cmd key (preferred)
    When I define a keymap:
      """lua
      map({
        ["<leader>gn"] = { cmd = "Neogit", desc = "Open Neogit" },
      })
      """
    Then "<leader>gn" is mapped to "<Cmd>Neogit<CR>"

  @implemented
  Scenario: Command prefill only (no execution)
    When I define a keymap:
      """lua
      map({
        ["<leader>o"] = { cmd = "Octo ", exec = false, desc = "Octo command" },
      })
      """
    Then "<leader>o" is mapped to ":Octo "
    And the command line is pre-filled without executing

  @implemented
  Scenario: Raw command string (purist approach)
    When I define a keymap:
      """lua
      map({
        ["<leader>gn"] = { "<Cmd>Neogit<CR>", desc = "Open Neogit" },
      })
      """
    Then "<leader>gn" is mapped to "<Cmd>Neogit<CR>"

  @implemented @deprecated
  Scenario: Command helper function (alternative)
    When I use "cmd('Neogit')"
    Then it returns "<Cmd>Neogit<CR>"
    # Note: cmd() helper still works but cmd = "..." syntax is preferred

  @implemented @deprecated
  Scenario: Command helper without execution
    When I use "cmd('s/foo/bar', false)"
    Then it returns ":s/foo/bar"
    # Note: cmd() helper still works but cmd = "...", exec = false is preferred

  # ==========================================================================
  # IMPLEMENTED: Introspection API
  # ==========================================================================

  @implemented
  Scenario: Get collected group descriptions
    Given keymaps with groups have been defined
    When I call "kmu.get_group_descriptions()"
    Then I receive a table of { key, group = "name" } entries

  @implemented
  Scenario: Get flat keymaps table
    Given keymaps have been defined using introspect config
    When I call "kmu.get_flat_keymaps_table()"
    Then I receive a table of { mode, key, action, opts } entries

  @implemented
  Scenario: Detect keymap conflicts
    Given a set of keymaps
    When I call "kmu.detect_conflicts(keymaps, include_builtins)"
    Then I receive a list of conflicts with type "duplicate" or "builtin-override"

  # ==========================================================================
  # IMPLEMENTED: Disabled Keymaps
  # ==========================================================================

  @implemented
  Scenario: Keymap with disabled flag is not mapped
    When I define a keymap:
      """lua
      map({
        j = { "j", desc = "Down", disabled = true },
      })
      """
    Then "j" is NOT mapped in nvim
    And the keymap is stored in disabled_keymaps collection

  @implemented
  Scenario: Nested group with disabled keymap
    When I define a keymap:
      """lua
      map({
        ["<leader>g"] = {
          group = "Git",
          n = { cmd("Neogit"), desc = "Open Neogit" },
          x = { cmd("OldGitCmd"), desc = "Legacy", disabled = true },
        },
      })
      """
    Then "<leader>gn" is mapped
    And "<leader>gx" is NOT mapped
    And "<leader>gx" is stored in disabled_keymaps with desc "Legacy"

  @implemented
  Scenario: Cascading disabled flag disables all children
    Given "local disabled = kmu.disabled" is the disabled flag
    When I define a keymap:
      """lua
      map({
        [disabled] = true,
        ["<leader>n"] = {
          group = "Notes",
          n = { cmd = "ObsidianNew", desc = "New note" },
          t = { cmd = "ObsidianToday", desc = "Today's note" },
        },
      })
      """
    Then "<leader>nn" is NOT mapped in nvim
    And "<leader>nt" is NOT mapped in nvim
    And both keymaps are stored in disabled_keymaps collection
    And both keymaps appear in KMUInspect with '*' prefix

  # ==========================================================================
  # IMPLEMENTED: KMUInspect Command (Snacks Picker)
  # ==========================================================================

  @implemented
  Scenario: Inspect all keymaps with KMUInspect command
    Given keymaps have been defined (some with disabled = true)
    When I run ":KMUInspect"
    Then a Snacks picker opens
    And it shows all active keymaps from vim.api
    And it shows disabled keymaps with '*' prefix
    And I can search/filter keymaps
    And I can jump to source file for function keymaps

  @implemented
  Scenario: Picker shows keymap details
    When I select a keymap in the picker
    Then the preview shows:
      | Field       | Example                |
      | mode        | n                      |
      | key         | <leader>gn             |
      | description | Open Neogit            |
      | rhs/action  | <Cmd>Neogit<CR>        |
      | source file | ~/.config/nvim/lua/... |
      | disabled    | false                  |

  @implemented
  Scenario: Picker filters by mode
    When I run ":KMUInspect --mode=n"
    Then only keymaps for normal mode are shown

  @implemented
  Scenario: Filter for keymap-utils only keymaps
    When I run ":KMUInspect --kmu-only"
    Then only keymaps registered through keymap-utils are shown
    And they are displayed in tree view with native Snacks tree formatting

  @implemented
  Scenario: Search matches both command and description
    Given keymaps have been defined:
      """lua
      map({
        ["<leader>n"] = {
          group = "Notes",
          n = { cmd = "ObsidianNew", desc = "New note" },
          t = { cmd = "ObsidianToday", desc = "Today's note" },
        },
      })
      """
    When I run ":KMUInspect" and search for "obs"
    Then the picker shows keymaps containing "Obsidian" in the command
    When I search for "note"
    Then the picker shows keymaps containing "note" in the description
    And both searches find the same keymaps

  # ==========================================================================
  # IMPLEMENTED: Keymap Tree Structure
  # ==========================================================================

  @implemented
  Scenario: Tree structure tracks keymap hierarchy
    When I define keymaps:
      """lua
      map({
        ["<leader>g"] = {
          group = "Git",
          n = { cmd("Neogit"), desc = "Open Neogit" },
          d = {
            group = "Diff",
            o = { cmd("DiffviewOpen"), desc = "Open" },
          },
        },
      })
      """
    Then kmu.get_keymap_tree() returns a tree with:
      | Path                    | Type   | Group/Desc    |
      | <leader>g               | group  | Git           |
      | <leader>g > n           | keymap | Open Neogit   |
      | <leader>g > d           | group  | Diff          |
      | <leader>g > d > o       | keymap | Open          |

  @implemented
  Scenario: Flatten tree for display
    Given a keymap tree exists
    When I call "kmu.flatten_keymap_tree()"
    Then I get items with depth info for indentation:
      | depth | type   | key_part | desc/group  |
      | 0     | group  | <leader>g| Git         |
      | 1     | keymap | n        | Open Neogit |
      | 1     | group  | d        | Diff        |
      | 2     | keymap | o        | Open        |

  @implemented
  Scenario: Tree view in picker with Snacks native tree lines
    When I run ":KMUInspect --kmu-only"
    Then the picker shows tree structure with Snacks tree icons:
      """
      ▼ [n] <leader>g  Git
      ├─  [n] n        Open Neogit
      └─▼ [n] d        Diff
        └─  [n] o      Open Diffview
      """

  @implemented
  Scenario: Expand and collapse groups in tree view
    Given I run ":KMUInspect --kmu-only"
    When I select a group with children
    And I press "h" (collapse)
    Then the group shows "▶" icon and children are hidden
    When I press "i" (expand)
    Then the group shows "▼" icon and children are visible
    And pressing Enter on a group also toggles expand/collapse

  @implemented
  Scenario: File preview for keymaps with function callbacks
    Given a keymap is defined with a function callback
    When I select that keymap in KMUInspect
    Then the preview shows the actual source file at the function definition line

  # ==========================================================================
  # PLANNED: Unified Collection (for export-keymaps.lua reuse)
  # ==========================================================================

  @planned
  Scenario: Collect keymaps using unified collector
    When I call "require('keymap-utils.collect').collect(opts)"
    Then it returns keymaps with fields:
      | Field    | Description                        |
      | mode     | Keymap mode (n, i, v, x, o, c, t)  |
      | key      | Left-hand side (lhs)               |
      | desc     | Description                        |
      | file     | Source file (if function callback) |
      | line     | Source line (if function callback) |
      | disabled | true if disabled keymap            |

  @planned
  Scenario: Collect uses snacks internally
    Given snacks.nvim is available
    When "collect()" is called
    Then it delegates to "snacks.picker.source.vim.keymaps"
    And merges in disabled keymaps from keymap-utils
    And applies filters (with_desc, modes, etc.)
