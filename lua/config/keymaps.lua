-- Import utility modules
local cli = require("utils.cli")
local clipboard = require("utils.clipboard")
local code = require("utils.code")
local editor = require("utils.editor")
local files = require("utils.files")
local git = require("utils.git")
local helpers = require("utils.helpers")
local history = require("utils.history")
local kmu = require("keymap-utils")
local search = require("utils.search")
local smart_diff = require("utils.smart-diff")

-- Keymap-utils declarative mapping
local mode = kmu.flags.mode
local disabled = kmu.flags.disabled
local x = kmu.mod("x")
local v = kmu.mod("v")
local ctrl = kmu.key("C")
local _ = kmu._
local remap = kmu.remap
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
  h = { "h", desc = "Left" },
  e = { "k", desc = "Up" },
  a = { "j", desc = "Down" },
  i = { "l", desc = "Right" },
  p = { "^", desc = "First non-blank character" },
  ["0"] = { "0", desc = "Beginning of line" },
  ["."] = { "$", desc = "End of line" },
})

-- Undo/redo (z replaces u)
map({
  z = { "u", desc = "Undo", remap = true },
  Z = { "<C-r>", desc = "Redo" },
  gz = { "U", desc = "Undo line", remap = true },
})

-- Text objects: r=inner, t=around
map({
  [mode] = { "o", "x" },
  ["r`"] = { code.select_fenced_code_block_inner, desc = "Inner code block" },
  ["t`"] = { code.select_fenced_code_block_around, desc = "Around code block" },
  ["r("] = { "i(", desc = "Inner parentheses" },
  ["r)"] = { "i)", desc = "Inner parentheses" },
  ["r["] = { "i[", desc = "Inner brackets" },
  ["r]"] = { "i]", desc = "Inner brackets" },
  ["r{"] = { "i{", desc = "Inner braces" },
  ["r}"] = { "i}", desc = "Inner braces" },
  ['r"'] = { 'i"', desc = "Inner quotes" },
  ["r'"] = { "i'", desc = "Inner single quotes" },
  ["rw"] = { "iw", desc = "Inner word" },
  ["rW"] = { "iW", desc = "Inner WORD" },
  ["rp"] = { "ip", desc = "Inner paragraph" },
  ["rb"] = { "ib", desc = "Inner block" },
  ["rB"] = { "iB", desc = "Inner Block" },
  ["r<"] = { "i<", desc = "Inner angle brackets" },
  ["r>"] = { "i>", desc = "Inner angle brackets" },
  ["t("] = { "a(", desc = "Around parentheses" },
  ["t)"] = { "a)", desc = "Around parentheses" },
  ["t["] = { "a[", desc = "Around brackets" },
  ["t]"] = { "a]", desc = "Around brackets" },
  ["t{"] = { "a{", desc = "Around braces" },
  ["t}"] = { "a}", desc = "Around braces" },
  ['t"'] = { 'a"', desc = "Around quotes" },
  ["t'"] = { "a'", desc = "Around single quotes" },
  ["tw"] = { "aw", desc = "Around word" },
  ["tW"] = { "aW", desc = "Around WORD" },
  ["tp"] = { "ap", desc = "Around paragraph" },
  ["tb"] = { "ab", desc = "Around block" },
  ["tB"] = { "aB", desc = "Around Block" },
  ["t<"] = { "a<", desc = "Around angle brackets" },
  ["t>"] = { "a>", desc = "Around angle brackets" },
  te = {
    [mode] = { "n", "o", "v" },
    require("utils.code").select_self_closing_tag,
    desc = "Select self-closing tag",
  },
})

map({
  x = {
    x = { "dd", desc = "Delete line" }, -- xx → dd
  },
  [x] = {
    x = { "d", desc = "Delete" }, -- Visual mode x → d
  },
})

-- Handle count-aware 'x' separately (needs different logic than nested xx)
remap({ "n" }, "x", function()
  local count = vim.v.count1
  return count == 1 and "d" or (count .. "d")
end, { desc = "Delete", expr = true })

-- Smooth scrolling (Graphite layout) - works with snacks.scroll
map({
  [mode] = { "n", "v", "x" },
  ga = { "<C-d>zz", desc = "Scroll down (Graphite)" },
  ge = { "<C-u>zz", desc = "Scroll up (Graphite)" },
  gs = { "zz", desc = "Center screen (Graphite)" },
})

-- ============================================================================
-- GIT OPERATIONS
-- ============================================================================

local gs = require("gitsigns")

map({
  -- Smart context-aware diff operations (lowercase)
  g = {
    o = { smart_diff.smart_diffget, desc = "Get hunk (smart)" },
    p = { smart_diff.smart_diffput, desc = "Put hunk (smart)" },
    i = { "gg", desc = "Go to top" },
    h = { "G", desc = "Go to bottom" },
  },
  ["<leader>g"] = {
    -- Git conflict resolution (uppercase - file-level operations)
    P = { smart_diff.smart_resolve_ours, desc = "Resolve file: ours" },
    O = { smart_diff.smart_resolve_theirs, desc = "Resolve file: theirs" },
    U = { smart_diff.smart_resolve_union, desc = "Resolve file: union (both)" },
    R = { smart_diff.smart_restore_conflicts, desc = "Restore conflict markers" },

    -- Neogit and diffview commands
    n = { cmd = ":Neogit cwd=%:p:h", desc = "Neogit in current dir" },
    c = { cmd = ":Neogit commit", desc = "Neogit commit" },
    d = { cmd = "DiffviewOpen", desc = "Diff view open" },
    S = { cmd = "DiffviewFileHistory -g --range=stash", desc = "Diff view stash" },
    h = { ":DiffviewFileHistory %", desc = "Current file history" },
    D = { helpers.compare_current_file_with_branch, desc = "Compare current file with branch" },
    f = { helpers.compare_current_file_with_file, desc = "Compare current file with file" },

    -- Git tools
    z = { git.lazygit_root, desc = "Lazygit (Root Dir)" },
    Z = { git.lazygit_cwd, desc = "Lazygit (cwd)" },
    b = { git.git_branches_picker, desc = "Git branches (all)" },
  },

  -- Gitsigns hunk operations
  ["<leader>gh"] = {
    group = "Hunks",
    s = { [mode] = { "n", "x" }, cmd = "Gitsigns stage_hunk", desc = "Stage Hunk" },
    r = { [mode] = { "n", "x" }, cmd = "Gitsigns reset_hunk", desc = "Reset Hunk" },
    S = { gs.stage_buffer, desc = "Stage Buffer" },
    u = { gs.undo_stage_hunk, desc = "Undo Stage Hunk" },
    R = { gs.reset_buffer, desc = "Reset Buffer" },
    p = { gs.preview_hunk_inline, desc = "Preview Hunk Inline" },
    b = {
      function()
        gs.blame_line({ full = true })
      end,
      desc = "Blame Line",
    },
    B = { gs.blame, desc = "Blame Buffer" },
    d = { gs.diffthis, desc = "Diff This" },
    D = {
      function()
        gs.diffthis("~")
      end,
      desc = "Diff This ~",
    },
  },

  -- Gitsigns toggle commands under <leader>ug
  ["<leader>ug"] = {
    g = { "<leader>uG", desc = "Toggle Git Signs" }, -- Maps to default LazyVim toggle
    l = { cmd = "Gitsigns toggle_linehl", desc = "Toggle line highlights" },
    n = { cmd = "Gitsigns toggle_numhl", desc = "Toggle number highlights" },
    w = { cmd = "Gitsigns toggle_word_diff", desc = "Toggle word diff" },
    b = { cmd = "Gitsigns toggle_current_line_blame", desc = "Toggle current line blame" },
  },

  -- Hunk navigation
  ["]h"] = {
    function()
      if vim.wo.diff then
        vim.cmd.normal({ "]c", bang = true })
      else
        gs.nav_hunk("next")
      end
    end,
    desc = "Next Hunk",
  },
  ["[h"] = {
    function()
      if vim.wo.diff then
        vim.cmd.normal({ "[c", bang = true })
      else
        gs.nav_hunk("prev")
      end
    end,
    desc = "Prev Hunk",
  },
  ["]H"] = {
    function()
      gs.nav_hunk("last")
    end,
    desc = "Last Hunk",
  },
  ["[H"] = {
    function()
      gs.nav_hunk("first")
    end,
    desc = "First Hunk",
  },
})

-- ============================================================================
-- COPY FILE TO CLIPBOARD
-- ============================================================================

map({
  ["<leader>p"] = {
    c = { clipboard.copy_file_path, desc = "Copy file path (relative to cwd)" },
    p = { clipboard.copy_file_path_from_home, desc = "Copy file path (from home)" },
    n = { clipboard.copy_file_name, desc = "Copy file name" },
    a = {
      function()
        clipboard.copy_file_path_claude_style()
      end,
      desc = 'Copy file name with "@" prefix',
    },
    o = { clipboard.copy_code_path, desc = "Copy object path" },
    O = { clipboard.copy_code_path_with_types, desc = "Copy object path (with types)" },
    w = { cmd = "OpenFileInRepo", desc = "Open file in web browser" },
    l = { clipboard.copy_file_path_with_line, desc = "Copy file path to clipboard" },
    L = { cmd = "YankLineUrl +", desc = "Copy file URL with line to clipboard" },
  },
})

-- noice keys override
map({
  ["<leader>sn"] = {
    L = {
      function()
        local messages = require("noice.message.manager").get({}, { history = true, sort = true })
        local last = messages[#messages]
        if last then
          vim.fn.setreg("+", last:content())
          vim.notify("Copied to clipboard")
        end
      end,
      desc = "Copied last notification to clipboard",
    },
    a = {
      cmd = "NoiceAll",
      desc = "Show all notifications",
    },
    l = {
      cmd = "NoiceLast",
      desc = "Show last notification",
    },
    -- { "l", false }, -- Noice Last Message
    -- { "h", false }, -- Noice History
    -- { "d", false }, -- Dismiss All notifications
    -- { "t", false }, -- Noice Picker (Telescope/FzfLua)
    -- { "<S-Enter>", false }, -- Redirect cmdline output to split
    -- { "<c-f>", false }, -- Scroll forward in LSP docs/signature
    -- { "<c-b>", false }, -- Scroll backward in LSP docs/signature
  },
})

-- ============================================================================
-- CODE OPERATIONS
-- ============================================================================

map({
  g = {
    D = { code.go_to_source_definition, desc = "Go to source definition" },
    R = { code.file_references, desc = "File references" },
  },
})

-- map({
--   c = {
--     ["h"] = {
--       [mode] = { "v", "x", "o" },
--       cli.smart_send_selection("l", false),
--       desc = "Send left",
--     },
--     ["a"] = {
--       [mode] = { "v", "x", "o" },
--       cli.smart_send_selection("d", false),
--       desc = "Send down",
--     },
--     ["e"] = {
--       [mode] = { "v", "x", "o" },
--       cli.smart_send_selection("u", false),
--       desc = "Send up",
--     },
--
--     ["i"] = {
--       [mode] = { "v", "x", "o" },
--       cli.smart_send_selection("r", false),
--       desc = "Send right",
--     },
--   },
-- })

map({
  ["<leader>c"] = {
    -- TypeScript/Import operations
    o = { code.organize_imports, desc = "Organize + Remove Unused Imports" },
    O = { code.organize_imports_and_fix, desc = "Organize Imports + Fix All Diagnostics" },
    I = { code.add_missing_imports, desc = "Add missing imports" },
    u = { code.remove_unused_imports, desc = "Remove unused imports" },
    F = { code.fix_all, desc = "Fix all diagnostics" },
    V = { code.select_ts_version, desc = "Select TS workspace version" },
    t = { editor.typescript_check, desc = "TypeScript type check" },
    C = { ":Claude<CR>", desc = "Claude replace" },
  },
})

-- ============================================================================
-- FILE OPERATIONS
-- ============================================================================

map({
  [ctrl] = {
    f = { files.find_files_snacks, desc = "Find files (snacks + fff)" },
    s = { files.save_file, desc = "Save file" },
    S = { files.save_and_stage_file, desc = "Save and stage file" },
  },
})

-- ============================================================================
-- HISTORY OPERATIONS
-- ============================================================================

map({
  ["<leader>h"] = {
    h = { history.local_file_history, desc = "Local file history" },
    H = { history.all_files_in_backup, desc = "All files in backup" },
    b = { cmd = "BrowserBookmarks", desc = "Browser bookmarks" },
    f = { cmd = "BrowserHistory", desc = "Browser history" },
    s = { history.smart_file_history, desc = "Smart history picker" },
    l = { history.git_log_picker, desc = "Git log" },
    u = { cmd = "undolist", desc = "View undo list" },
    T = { history.manual_backup_with_tag, desc = "Manual backup with tag" },
    p = { history.project_files_history, desc = "Project files history" },
    y = { Snacks.picker.yanky, desc = "Yank history" },
  },
})

-- ============================================================================
-- BUFFER NAVIGATION
-- ============================================================================

map({
  [mode] = { "n" },
  [ctrl + _] = {
    p = { cmd = "BufferLineCyclePrev", desc = "Previous buffer" },
    ["."] = { cmd = "BufferLineCycleNext", desc = "Next buffer" },
  },
})

-- ============================================================================
-- RELOAD/CONFIG
-- ============================================================================

map({
  ["<leader>r"] = {
    c = { editor.reload_config, desc = "Reload config" },
    r = { editor.reload_keymaps, desc = "Reload keymaps" },
    l = { cmd = "Lazy sync", desc = "Lazy sync plugins" },
  },
})

-- ============================================================================
-- TODO COMMENTS
-- ============================================================================

map({
  ["]t"] = { require("todo-comments").jump_next, desc = "Next Todo Comment" },
  ["[t"] = { require("todo-comments").jump_prev, desc = "Previous Todo Comment" },
})

-- ============================================================================
-- DIAGNOSTICS (Trouble)
-- ============================================================================

map({
  ["<leader>x"] = {
    x = { cmd = "Trouble diagnostics toggle", desc = "Diagnostics (Trouble)" },
    X = { cmd = "Trouble diagnostics toggle filter.buf=0", desc = "Buffer Diagnostics (Trouble)" },
    L = { cmd = "Trouble loclist toggle", desc = "Location List (Trouble)" },
    Q = { cmd = "Trouble qflist toggle", desc = "Quickfix List (Trouble)" },
    s = { cmd = "Trouble symbols toggle", desc = "Symbols (Trouble)" },
    S = { cmd = "Trouble lsp toggle", desc = "LSP references/definitions (Trouble)" },
    t = { cmd = "Trouble todo toggle", desc = "Todo (Trouble)" },
    T = { cmd = "Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}", desc = "Todo/Fix/Fixme" },
  },
  ["[q"] = {
    function()
      if require("trouble").is_open() then
        require("trouble").prev({ skip_groups = true, jump = true })
      else
        local ok, err = pcall(vim.cmd.cprev)
        if not ok then
          vim.notify(err, vim.log.levels.ERROR)
        end
      end
    end,
    desc = "Previous Trouble/Quickfix Item",
  },
  ["]q"] = {
    function()
      if require("trouble").is_open() then
        require("trouble").next({ skip_groups = true, jump = true })
      else
        local ok, err = pcall(vim.cmd.cnext)
        if not ok then
          vim.notify(err, vim.log.levels.ERROR)
        end
      end
    end,
    desc = "Next Trouble/Quickfix Item",
  },
})

-- ============================================================================
-- SEARCH/REPLACE
-- ============================================================================

map({
  ["<leader>s"] = {
    K = { cmd = "KMUInspect", exec = false, desc = "KMU only inspect" },
    D = { cmd = "ProjectDiagnostics", desc = "Project Diagnostics" },
    F = { search.grug_far_current_file, desc = "Search/Replace in current file (Grug-far)" },
    r = { cmd = "GrugFar", desc = "Search and replace (Grug-far)" },
    R = {
      search.grug_far_current_directory,
      desc = "Search/Replace in current directory (Grug-far)",
    },
  },
})

-- ============================================================================
-- DATABASE KEYMAPS (vim-dadbod operations)
-- ============================================================================

map({
  ["<leader>db"] = {
    u = { cmd = "DBUIToggle", desc = "Toggle DBUI" },
    f = { cmd = "DBUIFindBuffer", desc = "Find buffer" },
    r = { cmd = "DBUIRenameTab", desc = "Rename buffer" },
    q = { cmd = "DBUILastQueryInfo", desc = "Last query info" },
  },
})

-- ============================================================================
-- GITHUB KEYMAPS (Snacks GH + Octo hybrid)
-- ============================================================================

map({
  ["<leader>o"] = {
    group = "GitHub",

    -- Issues submenu
    i = {
      group = "Issues",
      l = {
        function()
          Snacks.picker.gh_issue({ repo = git.get_github_repo() })
        end,
        desc = "Issues (open)",
      },
      i = {
        function()
          Snacks.picker.gh_issue({ assignee = "@me", repo = git.get_github_repo() })
        end,
        desc = "Issues (assigned to me)",
      },
      a = {
        function()
          Snacks.picker.gh_issue({ state = "all", repo = git.get_github_repo() })
        end,
        desc = "Issues (all - open + closed)",
      },
      c = {
        function()
          Snacks.picker.gh_issue({ state = "closed", repo = git.get_github_repo() })
        end,
        desc = "Issues (closed)",
      },
      b = {
        function()
          Snacks.picker.gh_issue({ author = vim.fn.input("Author: "), repo = git.get_github_repo() })
        end,
        desc = "Issues (filter by author)",
      },
      C = { cmd = "Octo issue create", desc = "Create new issue" },
      A = {
        group = "Assignees",
        a = { cmd = "Octo assignee add ", exec = false, desc = "Add assignee to issue" },
        d = { cmd = "Octo assignee remove ", exec = false, desc = "Remove assignee from issue" },
      },
    },

    -- Pull Requests submenu
    p = {
      group = "Pull Requests",
      l = {
        function()
          Snacks.picker.gh_pr({ repo = git.get_github_repo() })
        end,
        desc = "PRs (open)",
      },
      a = {
        function()
          Snacks.picker.gh_pr({ state = "all", repo = git.get_github_repo() })
        end,
        desc = "PRs (all - open + closed + merged)",
      },
      m = {
        function()
          Snacks.picker.gh_pr({ state = "merged", repo = git.get_github_repo() })
        end,
        desc = "PRs (merged only)",
      },
      c = {
        function()
          Snacks.picker.gh_pr({ state = "closed", repo = git.get_github_repo() })
        end,
        desc = "PRs (closed only)",
      },
      d = {
        function()
          Snacks.picker.gh_pr({ draft = true, repo = git.get_github_repo() })
        end,
        desc = "PRs (draft only)",
      },
      C = { cmd = "Octo pr create", desc = "Create new PR" },
      R = {
        group = "Reviewers",
        a = { cmd = "Octo reviewer add ", exec = false, desc = "Add reviewer to PR" },
        d = { cmd = "Octo reviewer remove ", exec = false, desc = "Remove reviewer from PR" },
      },
    },

    -- Review operations (Octo - advanced workflow)
    v = {
      group = "Review",
      s = { cmd = "Octo review start", desc = "Start review" },
      r = { cmd = "Octo review resume", desc = "Resume review" },
      S = { cmd = "Octo review submit", desc = "Submit review" },
      d = { cmd = "Octo review discard", desc = "Discard review" },
      c = { cmd = "Octo review comments", desc = "Review comments" },
    },

    -- Thread operations (Octo only)
    t = {
      group = "Threads",
      r = { cmd = "Octo thread resolve", desc = "Resolve thread" },
      u = { cmd = "Octo thread unresolve", desc = "Unresolve thread" },
    },

    -- Repo operations (Octo)
    r = {
      group = "Repository",
      w = { cmd = "Octo repo browser", desc = "Browse repo" },
      i = { cmd = "Octo repo list", desc = "My repositories" },
      l = { cmd = "Octo repo url", desc = "Copy url" },
    },

    -- Comment operations
    a = {
      function()
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
      desc = "Add comment",
    },

    -- Notifications (Octo)
    n = { cmd = "Octo notifications", desc = "Notifications" },
  },
})

-- ============================================================================
-- TODO/CHECKMATE KEYMAPS
-- ============================================================================

map({
  ["<leader>t"] = {
    r = { cmd = "Checkmate create", desc = "Todo: Create new" },
    n = { cmd = "Checkmate toggle", desc = "Todo: Toggle state" },
    c = { cmd = "Checkmate check", desc = "Todo: Check (mark done)" },
    u = { cmd = "Checkmate uncheck", desc = "Todo: Uncheck" },
    a = { cmd = "Checkmate archive", desc = "Todo: Archive completed" },
    ["="] = { cmd = "Checkmate cycle_next", desc = "Todo: Next state" },
    ["-"] = { cmd = "Checkmate cycle_previous", desc = "Todo: Previous state" },
    l = { cmd = "Checkmate lint", desc = "Todo: Lint buffer" },
    ["]"] = { cmd = "Checkmate metadata jump_next", desc = "Todo: Jump to next metadata" },
    ["["] = { cmd = "Checkmate metadata jump_previous", desc = "Todo: Jump to previous metadata" },
    v = { cmd = "Checkmate metadata select_value", desc = "Todo: Select metadata value" },
    t = {
      r = {
        s = { cmd = "Checkmate metadata add started", desc = "Todo Metadata: Add @started" },
        d = { cmd = "Checkmate metadata add done", desc = "Todo Metadata: Add @done" },
        p = { cmd = "Checkmate metadata add priority", desc = "Todo Metadata: Add @priority" },
      },
      n = {
        s = { cmd = "Checkmate metadata toggle started", desc = "Todo Metadata: Toggle @started" },
        d = { cmd = "Checkmate metadata toggle done", desc = "Todo Metadata: Toggle @done" },
        p = { cmd = "Checkmate metadata toggle priority", desc = "Todo Metadata: Toggle @priority" },
      },
      x = {
        a = { cmd = "Checkmate remove_all_metadata", desc = "Todo Metadata: Remove all" },
        s = { cmd = "Checkmate metadata remove started", desc = "Todo Metadata: Remove @started" },
        d = { cmd = "Checkmate metadata remove done", desc = "Todo Metadata: Remove @done" },
        p = { cmd = "Checkmate metadata remove priority", desc = "Todo Metadata: Remove @priority" },
      },
      s = { cmd = "Checkmate metadata add started", desc = "Todo Metadata: Add @started" },
      d = { cmd = "Checkmate metadata add done", desc = "Todo Metadata: Add @done" },
      p = { cmd = "Checkmate metadata add priority", desc = "Todo Metadata: Add @priority" },
    },
  },
})

-- ============================================================================
-- NOTES MANAGEMENT (Marksman + obsidian.nvim)
-- ============================================================================

local notes = require("utils.notes")

map({
  [disabled] = false,
  ["<leader>O"] = {
    n = { cmd = "ObsidianNew", desc = "New note [title]", icon = "" },
    N = {
      function()
        vim.api.nvim_feedkeys(os.date(":ObsidianNew %y-%m-%d "), "n", false)
      end,
      desc = "New note [YY-MM-DD-title]",
      icon = "",
    },
    o = { cmd = "ObsidianOpen", exec = false, desc = "Open note [query]" },
    q = { cmd = "ObsidianQuickSwitch", desc = "Quick switch [query]" },
    t = { cmd = "ObsidianToday", desc = "Today's note" },
    y = { cmd = "ObsidianYesterday", desc = "Yesterday's note" },
    T = { cmd = "ObsidianTomorrow", desc = "Tomorrow's note" },
    s = { cmd = "ObsidianSearch", desc = "Search notes [query]" },
    b = { cmd = "ObsidianBacklinks", desc = "Backlinks" },
    l = { cmd = "ObsidianLinks", desc = "Links in note" },
    g = { cmd = "ObsidianTags", desc = "Search tags [query]" },
    te = { disabled = true, cmd = "ObsidianTemplate", desc = "Insert template [name]" },
    to = { disabled = true, cmd = "ObsidianTOC", desc = "Table of contents" },
    r = { cmd = "ObsidianRename", desc = "Rename note [name]" },
    p = { cmd = "ObsidianPasteImg", desc = "Paste image [name]" },
    w = { cmd = "ObsidianWorkspace", desc = "Switch workspace [name]" },
    d = { notes.open_notes_directory, desc = "Open notes directory" },
    L = { [x] = { cmd = "ObsidianLinkNew", desc = "Link to new note [title]" } },
    k = { [x] = { cmd = "ObsidianLink", desc = "Link to existing note [query]" } },
  },
  gf = { notes.smart_follow_link, desc = "Follow link or file", expr = true },
  ["<leader>N"] = { notes.create_inbox_note, desc = "New note in inbox" },
})

-- ============================================================================
-- REGISTER GROUP DESCRIPTIONS WITH WHICH-KEY
-- ============================================================================

kmu.register_groups()

-- ============================================================================
-- SETUP KEYMAP INSPECT COMMAND
-- ============================================================================

kmu.setup_inspect()

-- ============================================================================
-- LOAD LEGACY KEYMAPS (at bottom to avoid being overwritten)
-- TODO: Migrate vim.keymap.set() style keymaps to map({}) style above
-- ============================================================================

require("config.keymaps-old")
