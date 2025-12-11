-- Import utility modules
local cli = require("utils.cli")
local clipboard = require("utils.clipboard")
local code = require("utils.code")
local editor = require("utils.editor")
local files = require("utils.files")
local git = require("utils.git")
local helpers = require("utils.helpers")
local history = require("utils.history")
local kmu = require("plugins.keymap-utils")
local search = require("utils.search")
local smart_diff = require("utils.smart-diff")

-- lil-style declarative mapping (now from keymap-utils)
local func = kmu.flags.func
local opts = kmu.flags.opts
local mode = kmu.flags.mode
local x = kmu.mod("x")
local n = kmu.mod("n")
local ctrl = kmu.key("C")
local _ = kmu._

-- Use keymap-utils as unified toolkit
local cmd = kmu.cmd
local remap = kmu.remap
local safe_del = kmu.safe_del
local desc = kmu.desc

-- Create smart map that auto-extracts group descriptions and auto-injects [func] = func_map
local map = kmu.create_smart_map()

-- Disable LazyVim default keymaps
pcall(vim.keymap.del, "n", "<leader>gd")
pcall(vim.keymap.del, "n", "<leader> ")
pcall(vim.keymap.del, "n", "<leader><space>")

-- ============================================================================
-- GRAPHITE LAYOUT: Core Navigation (HAEI) + Basic Operations
-- ============================================================================

map({
  [mode] = { "n", "o", "x" },
  h = desc({ desc = "Left", value = "h" }),
  e = desc({ desc = "Up", value = "k" }),
  a = desc({ desc = "Down", value = "j" }),
  i = desc({ desc = "Right", value = "l" }),
  p = desc({ desc = "First non-blank character", value = "^" }),
  ["0"] = desc({ desc = "Beginning of line", value = "0" }),
  ["."] = desc({ desc = "End of line", value = "$" }),
})

map({
  x = {
    x = desc({ desc = "Delete line", value = "dd" }), -- xx → dd
  },
  [x] = {
    x = desc({ desc = "Delete", value = "d" }), -- Visual mode x → d
  },
})

-- Handle count-aware 'x' separately (needs different logic than nested xx)
remap({ "n" }, "x", helpers.count_aware_delete, { desc = "Delete", expr = true })

-- Smooth scrolling (Graphite layout) - works with snacks.scroll
map({
  [mode] = { "n", "v", "x" },
  ga = desc({ desc = "Scroll down (Graphite)", value = "<C-d>zz" }),
  ge = desc({ desc = "Scroll up (Graphite)", value = "<C-u>zz" }),
  gs = desc({ desc = "Center screen (Graphite)", value = "zz" }),
})

-- ============================================================================
-- GIT OPERATIONS
-- ============================================================================

map({
  -- Smart context-aware diff operations (lowercase)
  g = {
    o = desc({ desc = "Get hunk (smart)", value = smart_diff.smart_diffget }),
    p = desc({ desc = "Put hunk (smart)", value = smart_diff.smart_diffput }),
    i = desc({ desc = "Go to top", value = "gg" }),
    h = desc({ desc = "Go to bottom", value = "G" }),
  },
  ["<leader>g"] = {
    -- Git conflict resolution (uppercase - file-level operations)
    P = desc({ desc = "Resolve file: ours", value = smart_diff.smart_resolve_ours }),
    O = desc({ desc = "Resolve file: theirs", value = smart_diff.smart_resolve_theirs }),
    U = desc({ desc = "Resolve file: union (both)", value = smart_diff.smart_resolve_union }),
    R = desc({ desc = "Restore conflict markers", value = smart_diff.smart_restore_conflicts }),

    -- Neogit and diffview commands
    n = desc({ desc = "Neogit in current dir", value = cmd(":Neogit cwd=%:p:h") }),
    c = desc({ desc = "Neogit commit", value = cmd(":Neogit commit") }),
    d = desc({ desc = "Diff view open", value = cmd("DiffviewOpen") }),
    S = desc({ desc = "Diff view stash", value = cmd("DiffviewFileHistory -g --range=stash") }),
    h = desc({ desc = "Current file history", value = ":DiffviewFileHistory %" }),
    D = desc({
      desc = "Compare current file with branch",
      value = helpers.compare_current_file_with_branch,
    }),
    f = desc({
      desc = "Compare current file with file",
      value = helpers.compare_current_file_with_file,
    }),

    -- Git tools
    z = desc({ desc = "Lazygit (Root Dir)", value = git.lazygit_root }),
    Z = desc({ desc = "Lazygit (cwd)", value = git.lazygit_cwd }),
    b = desc({ desc = "Git branches (all)", value = git.git_branches_picker }),
  },

  -- Gitsigns toggle commands under <leader>ug
  ["<leader>ug"] = {
    g = desc({ desc = "Toggle Git Signs", value = "<leader>uG" }), -- Maps to default LazyVim toggle
    l = desc({ desc = "Toggle line highlights", value = cmd("Gitsigns toggle_linehl") }),
    n = desc({ desc = "Toggle number highlights", value = cmd("Gitsigns toggle_numhl") }),
    w = desc({ desc = "Toggle word diff", value = cmd("Gitsigns toggle_word_diff") }),
    b = desc({
      desc = "Toggle current line blame",
      value = cmd("Gitsigns toggle_current_line_blame"),
    }),
  },
})

-- ============================================================================
-- COPY FILE TO CLIPBOARD
-- ============================================================================

map({
  ["<leader>p"] = {
    c = desc({ desc = "Copy file path (relative to cwd)", value = clipboard.copy_file_path }),
    p = desc({ desc = "Copy file path (from home)", value = clipboard.copy_file_path_from_home }),
    n = desc({ desc = "Copy file name", value = clipboard.copy_file_name }),
    a = desc({
      desc = 'Copy file name with "@" prefix',
      value = function()
        clipboard.copy_file_path_claude_style()
      end,
    }),
    t = desc({
      desc = "Send selected text to Claude",
      value = function()
        os.execute("kitten @ send-text --match 'CLD=1' " .. "test")
      end,
    }),
    o = desc({ desc = "Copy object path", value = clipboard.copy_code_path }),
    O = desc({
      desc = "Copy object path (with types)",
      value = clipboard.copy_code_path_with_types,
    }),
    w = desc({ desc = "Open file in web browser", value = cmd("OpenFileInRepo") }),
    l = desc({ desc = "Copy file path to clipboard", value = clipboard.copy_file_path_with_line }),
    L = desc({ desc = "Copy file URL with line to clipboard", value = cmd("YankLineUrl +") }),
  },
})

-- ============================================================================
-- CODE OPERATIONS
-- ============================================================================

map({
  g = {
    D = desc({ desc = "Go to source definition", value = code.go_to_source_definition }),
    R = desc({ desc = "File references", value = code.file_references }),
  },
})

map({
  ["<leader>c"] = {
    -- TypeScript/Import operations
    o = desc({ desc = "Organize + Remove Unused Imports", value = code.organize_imports }),
    O = desc({
      desc = "Organize Imports + Fix All Diagnostics",
      value = code.organize_imports_and_fix,
    }),
    i = desc({ desc = "Add missing imports", value = code.add_missing_imports }),
    u = desc({ desc = "Remove unused imports", value = code.remove_unused_imports }),
    F = desc({ desc = "Fix all diagnostics", value = code.fix_all }),
    V = desc({ desc = "Select TS workspace version", value = code.select_ts_version }),
    t = desc({ desc = "TypeScript type check", value = editor.typescript_check }),
    P = desc({ desc = "Copy file contents", value = clipboard.copy_file_contents }),
  },
})

-- ============================================================================
-- FILE OPERATIONS
-- ============================================================================

map({
  [ctrl] = {
    f = desc({ desc = "Find files (snacks + fff)", value = files.find_files_snacks }),
    s = desc({ desc = "Save file", value = files.save_file }),
    S = desc({ desc = "Save and stage file", value = files.save_and_stage_file }),
  },
})

-- ============================================================================
-- HISTORY OPERATIONS
-- ============================================================================

map({
  ["<leader>h"] = {
    h = desc({ desc = "Local file history", value = history.local_file_history }),
    H = desc({ desc = "All files in backup", value = history.all_files_in_backup }),
    b = desc({ desc = "Browser bookmarks", value = cmd("BrowserBookmarks") }),
    f = desc({ desc = "Browser history", value = cmd("BrowserHistory") }),
    s = desc({ desc = "Smart history picker", value = history.smart_file_history }),
    l = desc({ desc = "Git log", value = history.git_log_picker }),
    u = desc({ desc = "View undo list", value = cmd("undolist") }),
    T = desc({ desc = "Manual backup with tag", value = history.manual_backup_with_tag }),
    p = desc({ desc = "Project files history", value = history.project_files_history }),
    y = desc({ desc = "Yank history", value = Snacks.picker.yanky }),
  },
})

-- ============================================================================
-- BUFFER NAVIGATION
-- ============================================================================

map({
  [mode] = { "n" },
  [ctrl + _] = {
    p = desc({ desc = "Previous buffer", value = cmd("BufferLineCyclePrev") }),
    ["."] = desc({ desc = "Next buffer", value = cmd("BufferLineCycleNext") }),
  },
})

-- ============================================================================
-- RELOAD/CONFIG
-- ============================================================================

map({
  ["<leader>r"] = {
    c = desc({ desc = "Reload config", value = editor.reload_config }),
    r = desc({ desc = "Reload keymaps", value = editor.reload_keymaps }),
    l = desc({ desc = "Lazy sync plugins", value = cmd("Lazy sync") }),
  },
})

-- ============================================================================
-- TODO COMMENTS
-- ============================================================================

map({
  ["]t"] = desc({ desc = "Next Todo Comment", value = require("todo-comments").jump_next }),
  ["[t"] = desc({ desc = "Previous Todo Comment", value = require("todo-comments").jump_prev }),
  ["<leader>x"] = {
    t = desc({ desc = "Todo (Trouble)", value = cmd("Trouble todo toggle") }),
    T = desc({
      desc = "Todo/Fix/Fixme",
      value = cmd("Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}"),
    }),
  },
})

-- ============================================================================
-- SEARCH/REPLACE
-- ============================================================================

map({
  ["<leader>s"] = {
    D = desc({ desc = "Project Diagnostics", value = cmd("ProjectDiagnostics") }),
    r = desc({ desc = "Search/Replace within range (Grug-far)", value = search.grug_far_range }),
    F = desc({
      desc = "Search/Replace in current file (Grug-far)",
      value = search.grug_far_current_file,
    }),
    R = desc({
      desc = "Search/Replace in current directory (Grug-far)",
      value = search.grug_far_current_directory,
    }),
  },
})

-- ============================================================================
-- DATABASE KEYMAPS (vim-dadbod operations)
-- ============================================================================

map({
  ["<leader>db"] = {
    u = desc({ desc = "Toggle DBUI", value = cmd("DBUIToggle") }),
    f = desc({ desc = "Find buffer", value = cmd("DBUIFindBuffer") }),
    r = desc({ desc = "Rename buffer", value = cmd("DBUIRenameTab") }),
    q = desc({ desc = "Last query info", value = cmd("DBUILastQueryInfo") }),
  },
})

-- ============================================================================
-- GITHUB KEYMAPS (Snacks GH + Octo hybrid)
-- ============================================================================

map({
  ["<leader>o"] = {
    [opts] = { group = "GitHub" },

    -- Issues submenu
    i = {
      [opts] = { group = "Issues" },
      l = desc({
        desc = "Issues (open)",
        value = function()
          Snacks.picker.gh_issue({ repo = git.get_github_repo() })
        end,
      }),
      i = desc({
        desc = "Issues (assigned to me)",
        value = function()
          Snacks.picker.gh_issue({ assignee = "@me", repo = git.get_github_repo() })
        end,
      }),
      a = desc({
        desc = "Issues (all - open + closed)",
        value = function()
          Snacks.picker.gh_issue({ state = "all", repo = git.get_github_repo() })
        end,
      }),
      c = desc({
        desc = "Issues (closed)",
        value = function()
          Snacks.picker.gh_issue({ state = "closed", repo = git.get_github_repo() })
        end,
      }),
      b = desc({
        desc = "Issues (filter by author)",
        value = function()
          Snacks.picker.gh_issue({ author = vim.fn.input("Author: "), repo = git.get_github_repo() })
        end,
      }),
      C = desc({ desc = "Create new issue", value = cmd("Octo issue create") }),
      A = {
        [opts] = { group = "Assignees" },
        a = desc({ desc = "Add assignee to issue", value = cmd("Octo assignee add ", false) }),
        d = desc({
          desc = "Remove assignee from issue",
          value = cmd("Octo assignee remove ", false),
        }),
      },
    },

    -- Pull Requests submenu
    p = {
      [opts] = { group = "Pull Requests" },
      l = desc({
        desc = "PRs (open)",
        value = function()
          Snacks.picker.gh_pr({ repo = git.get_github_repo() })
        end,
      }),
      a = desc({
        desc = "PRs (all - open + closed + merged)",
        value = function()
          Snacks.picker.gh_pr({ state = "all", repo = git.get_github_repo() })
        end,
      }),
      m = desc({
        desc = "PRs (merged only)",
        value = function()
          Snacks.picker.gh_pr({ state = "merged", repo = git.get_github_repo() })
        end,
      }),
      c = desc({
        desc = "PRs (closed only)",
        value = function()
          Snacks.picker.gh_pr({ state = "closed", repo = git.get_github_repo() })
        end,
      }),
      d = desc({
        desc = "PRs (draft only)",
        value = function()
          Snacks.picker.gh_pr({ draft = true, repo = git.get_github_repo() })
        end,
      }),
      C = desc({ desc = "Create new PR", value = cmd("Octo pr create") }),
      R = {
        [opts] = { group = "Reviewers" },
        a = desc({ desc = "Add reviewer to PR", value = cmd("Octo reviewer add ", false) }),
        d = desc({ desc = "Remove reviewer from PR", value = cmd("Octo reviewer remove ", false) }),
      },
    },

    -- Review operations (Octo - advanced workflow)
    v = {
      [opts] = { group = "Review" },
      s = desc({ desc = "Start review", value = cmd("Octo review start") }),
      r = desc({ desc = "Resume review", value = cmd("Octo review resume") }),
      S = desc({ desc = "Submit review", value = cmd("Octo review submit") }),
      d = desc({ desc = "Discard review", value = cmd("Octo review discard") }),
      c = desc({ desc = "Review comments", value = cmd("Octo review comments") }),
    },

    -- Thread operations (Octo only)
    t = {
      [opts] = { group = "Threads" },
      r = desc({ desc = "Resolve thread", value = cmd("Octo thread resolve") }),
      u = desc({ desc = "Unresolve thread", value = cmd("Octo thread unresolve") }),
    },

    -- Repo operations (Octo)
    r = {
      [opts] = { group = "Repository" },
      w = desc({ desc = "Browse repo", value = cmd("Octo repo browser") }),
      i = desc({ desc = "My repositories", value = cmd("Octo repo list") }),
      l = desc({ desc = "Copy url", value = cmd("Octo repo url") }),
    },

    -- Comment operations
    a = desc({
      desc = "Add comment",
      value = function()
        local Actions = require("snacks.gh.actions")
        local Api = require("snacks.gh.api")
        local buf = vim.api.nvim_get_current_buf()
        local gh_meta = vim.b[buf].snacks_gh
        local item
        if gh_meta and gh_meta.type and gh_meta.repo and gh_meta.number then
          item = Api.get({ type = gh_meta.type, repo = gh_meta.repo, number = gh_meta.number })
        else
          item = Api.current_pr()
        end
        if item then
          Actions.actions.gh_comment.action(item, { items = { item } })
        else
          vim.notify("Not in a GitHub PR/Issue buffer", vim.log.levels.WARN)
        end
      end,
    }),

    -- Notifications (Octo)
    n = desc({ desc = "Notifications", value = cmd("Octo notifications") }),
  },
})

-- ============================================================================
-- TODO/CHECKMATE KEYMAPS
-- ============================================================================

map({
  ["<leader>t"] = {
    r = desc({ desc = "Todo: Create new", value = cmd("Checkmate create") }),
    n = desc({ desc = "Todo: Toggle state", value = cmd("Checkmate toggle") }),
    c = desc({ desc = "Todo: Check (mark done)", value = cmd("Checkmate check") }),
    u = desc({ desc = "Todo: Uncheck", value = cmd("Checkmate uncheck") }),
    a = desc({ desc = "Todo: Archive completed", value = cmd("Checkmate archive") }),
    ["="] = desc({ desc = "Todo: Next state", value = cmd("Checkmate cycle_next") }),
    ["-"] = desc({ desc = "Todo: Previous state", value = cmd("Checkmate cycle_previous") }),
    l = desc({ desc = "Todo: Lint buffer", value = cmd("Checkmate lint") }),
    ["]"] = desc({
      desc = "Todo: Jump to next metadata",
      value = cmd("Checkmate metadata jump_next"),
    }),
    ["["] = desc({
      desc = "Todo: Jump to previous metadata",
      value = cmd("Checkmate metadata jump_previous"),
    }),
    v = desc({
      desc = "Todo: Select metadata value",
      value = cmd("Checkmate metadata select_value"),
    }),
    t = {
      r = {
        s = desc({
          desc = "Todo Metadata: Add @started",
          value = cmd("Checkmate metadata add started"),
        }),
        d = desc({ desc = "Todo Metadata: Add @done", value = cmd("Checkmate metadata add done") }),
        p = desc({
          desc = "Todo Metadata: Add @priority",
          value = cmd("Checkmate metadata add priority"),
        }),
      },
      n = {
        s = desc({
          desc = "Todo Metadata: Toggle @started",
          value = cmd("Checkmate metadata toggle started"),
        }),
        d = desc({
          desc = "Todo Metadata: Toggle @done",
          value = cmd("Checkmate metadata toggle done"),
        }),
        p = desc({
          desc = "Todo Metadata: Toggle @priority",
          value = cmd("Checkmate metadata toggle priority"),
        }),
      },
      x = {
        a = desc({
          desc = "Todo Metadata: Remove all",
          value = cmd("Checkmate remove_all_metadata"),
        }),
        s = desc({
          desc = "Todo Metadata: Remove @started",
          value = cmd("Checkmate metadata remove started"),
        }),
        d = desc({
          desc = "Todo Metadata: Remove @done",
          value = cmd("Checkmate metadata remove done"),
        }),
        p = desc({
          desc = "Todo Metadata: Remove @priority",
          value = cmd("Checkmate metadata remove priority"),
        }),
      },
      s = desc({
        desc = "Todo Metadata: Add @started",
        value = cmd("Checkmate metadata add started"),
      }),
      d = desc({ desc = "Todo Metadata: Add @done", value = cmd("Checkmate metadata add done") }),
      p = desc({
        desc = "Todo Metadata: Add @priority",
        value = cmd("Checkmate metadata add priority"),
      }),
    },
  },
})

-- ============================================================================
-- NOTES MANAGEMENT (Marksman + obsidian.nvim)
-- ============================================================================

local notes = require("utils.notes")

map({
  ["<leader>n"] = {
    n = desc({ desc = "New note", value = cmd("ObsidianNew") }),
    t = desc({ desc = "Today's note", value = cmd("ObsidianToday") }),
    y = desc({ desc = "Yesterday's note", value = cmd("ObsidianYesterday") }),
    T = desc({ desc = "Tomorrow's note", value = cmd("ObsidianTomorrow") }),
    s = desc({ desc = "Search notes", value = cmd("ObsidianSearch") }),
    f = desc({ desc = "Find note", value = cmd("ObsidianQuickSwitch") }),
    b = desc({ desc = "Backlinks", value = cmd("ObsidianBacklinks") }),
    l = desc({ desc = "Links in note", value = cmd("ObsidianLinks") }),
    g = desc({ desc = "Search tags", value = cmd("ObsidianTags") }),
    te = desc({ desc = "Insert template", value = cmd("ObsidianTemplate") }),
    to = desc({ desc = "Table of contents", value = cmd("ObsidianTOC") }),
    r = desc({ desc = "Rename note", value = cmd("ObsidianRename") }),
    p = desc({ desc = "Paste image", value = cmd("ObsidianPasteImg") }),
    o = desc({ desc = "Open in Obsidian app", value = cmd("ObsidianOpen") }),
    w = desc({ desc = "Switch workspace", value = cmd("ObsidianWorkspace") }),
    d = desc({ desc = "Open notes directory", value = notes.open_notes_directory }),
    L = { [x] = desc({ desc = "Link to new note", value = cmd("ObsidianLinkNew") }) },
    k = { [x] = desc({ desc = "Link to existing note", value = cmd("ObsidianLink") }) },
  },
  gf = desc({ desc = "Follow link or file", value = notes.smart_follow_link, expr = true }),
  ["<leader>N"] = desc({ desc = "New note in inbox", value = notes.create_inbox_note }),
})

-- ============================================================================
-- LOAD LEGACY KEYMAPS
-- TODO: Migrate vim.keymap.set() style keymaps to map({}) style above
-- ============================================================================

require("config.keymaps-old")

-- ============================================================================
-- REGISTER GROUP DESCRIPTIONS WITH WHICH-KEY
-- ============================================================================

kmu.register_groups()
