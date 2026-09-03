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

local mode = kmu.flags.mode
local disabled = kmu.flags.disabled
local x = kmu.mod("x")
local ctrl = kmu.ctrl
local _ = kmu._
local remap = kmu.remap
local map = kmu.create_smart_map()
local cmd = kmu.cmd

pcall(vim.keymap.del, "n", "<leader>gd")
pcall(vim.keymap.del, "n", "<leader> ")
pcall(vim.keymap.del, "n", "<leader><space>")
pcall(vim.keymap.del, "n", "<leader>:")
pcall(vim.keymap.del, "n", "<leader>sb")

vim.keymap.set(
  "n",
  "<C-Space>",
  function()
    pcall(
      function()
        require("claudecode.terminal").simple_toggle()
      end
    )
  end,
  {desc = "Toggle Claude Code"}
)

map(
  {
    [mode] = {"n", "o", "x"},
    ["h"] = {"h", desc = "Left"},
    ["e"] = {"k", desc = "Up"},
    ["a"] = {"j", desc = "Down"},
    ["i"] = {"l", desc = "Right"}
  }
)

vim.defer_fn(
  function()
    vim.keymap.set(
      "c",
      "<C-S-V>",
      function()
        local reg = vim.fn.getcharstr()
        return "<C-r>=trim(getreg('" .. reg .. "'))<CR>"
      end,
      {expr = true, desc = "Paste trimmed from register"}
    )
    vim.keymap.set(
      "c",
      "<Up>",
      function()
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-p>", true, false, true), "n", false)
      end
    )
    vim.keymap.set(
      "c",
      "<Down>",
      function()
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-n>", true, false, true), "n", false)
      end
    )
  end,
  1000
)

map(
  {
    [mode] = {"o", "x"},
    ["r`"] = {code.select_fenced_code_block_inner, desc = "Inner code block"},
    ["t`"] = {code.select_fenced_code_block_around, desc = "Around code block"},
    ["r("] = {"i(", desc = "Inner parentheses"},
    ["r)"] = {"i)", desc = "Inner parentheses"},
    ["r["] = {"i[", desc = "Inner brackets"},
    ["r]"] = {"i]", desc = "Inner brackets"},
    ["r{"] = {"i{", desc = "Inner braces"},
    ["r}"] = {"i}", desc = "Inner braces"},
    ['r"'] = {'i"', desc = "Inner quotes"},
    ["r'"] = {"i'", desc = "Inner single quotes"},
    ["rw"] = {"iw", desc = "Inner word"},
    ["rW"] = {"iW", desc = "Inner WORD"},
    ["rp"] = {"ip", desc = "Inner paragraph"},
    ["rb"] = {"ib", desc = "Inner block"},
    ["rB"] = {"iB", desc = "Inner Block"},
    ["r<"] = {"i<", desc = "Inner angle brackets"},
    ["r>"] = {"i>", desc = "Inner angle brackets"},
    ["t("] = {"a(", desc = "Around parentheses"},
    ["t)"] = {"a)", desc = "Around parentheses"},
    ["t["] = {"a[", desc = "Around brackets"},
    ["t]"] = {"a]", desc = "Around brackets"},
    ["t{"] = {"a{", desc = "Around braces"},
    ["t}"] = {"a}", desc = "Around braces"},
    ['t"'] = {'a"', desc = "Around quotes"},
    ["t'"] = {"a'", desc = "Around single quotes"},
    ["tw"] = {"aw", desc = "Around word"},
    ["tW"] = {"aW", desc = "Around WORD"},
    ["tp"] = {"ap", desc = "Around paragraph"},
    ["tb"] = {"ab", desc = "Around block"},
    ["tB"] = {"aB", desc = "Around Block"},
    ["t<"] = {"a<", desc = "Around angle brackets"},
    ["t>"] = {"a>", desc = "Around angle brackets"},
    te = {
      [mode] = {"n", "o", "v"},
      require("utils.code").select_self_closing_tag,
      desc = "Select self-closing tag"
    }
  }
)

local function notify_use_d()
  vim.notify("Use 'd' to delete (x is retired)", vim.log.levels.WARN)
end

remap({"n", "x"}, "x", notify_use_d, {desc = "Use d to delete"})
remap({"n", "x"}, "X", notify_use_d, {desc = "Use d to delete"})

map(
  {
    [mode] = {"n", "v", "x"},
    ga = {"<C-d>zz", desc = "Scroll down (Graphite)"},
    ge = {"<C-u>zz", desc = "Scroll up (Graphite)"},
    ["<PageDown>"] = {"<C-d>zz", desc = "Scroll down"},
    ["<PageUp>"] = {"<C-u>zz", desc = "Scroll up"}
  }
)

map(
  {
    gs = {code.jump_to_matching_tag, desc = "Jump to matching tag"}
  }
)

local gs = require("gitsigns")

map(
  {
    g = {
      o = {smart_diff.smart_diffget, desc = "Get hunk (smart)", disabled = true},
      p = {smart_diff.smart_diffput, desc = "Put hunk (smart)", disabled = true},
      h = {"G", desc = "Go to bottom"}
    },
    ["<leader>g"] = {
      I = {cmd = "AiCommit", desc = "AI commit popup"},
      d = {cmd = "DiffviewOpen", desc = "Diff view open"},
      D = {cmd = "DiffviewOpen ", exec = false, desc = "Compare with branch"},
      f = {cmd = "DiffviewFileHistory", desc = "File history"},
      F = {cmd = "DiffviewFileHistory %", exec = false, desc = "File history"},
      s = {cmd = "DiffviewFileHistory -g --range=stash", desc = "Diff view stash"},
      x = {[mode] = {"n", "x"}, cmd = "Gitsigns reset_hunk", desc = "Reset Hunk"},

      z = {git.lazygit_root, desc = "Lazygit (Root Dir)"},
      Z = {git.lazygit_cwd, desc = "Lazygit (cwd)"},
      b = {git.git_branches_picker, desc = "Git branches (all)"},
      B = {git.git_branches_file_picker, desc = "Checkout file from branch"},
      ["!"] = {
        function()
          gs.diffthis("~")
        end,
        desc = "Diff This ~"
      },
      ["?"] = {
        function()
          gs.blame_line({full = true})
        end,
        desc = "Blame Line"
      }
    },

    ["<leader>u"] = {
      g = {
        g = {"<leader>uG", desc = "Toggle Git Signs"},
        l = {cmd = "Gitsigns toggle_linehl", desc = "Toggle line highlights"},
        n = {cmd = "Gitsigns toggle_numhl", desc = "Toggle number highlights"},
        w = {cmd = "Gitsigns toggle_word_diff", desc = "Toggle word diff"},
        b = {cmd = "Gitsigns toggle_current_line_blame", desc = "Toggle current line blame"}
      },
      l = {require("lensline").toggle_view, desc = "Toggle lensline"}
    },
    ["]s"] = {"]s", desc = "Next misspelled word"},
    ["[s"] = {"[s", desc = "Prev misspelled word"},
    ["]H"] = {
      function()
        gs.nav_hunk("last")
      end,
      desc = "Last Hunk"
    },
    ["[H"] = {
      function()
        gs.nav_hunk("first")
      end,
      desc = "First Hunk"
    }
  }
)

map(
  {
    ["<leader>p"] = {
      [mode] = {"n", "v"},
      c = {clipboard.copy_file_path, desc = "Copy file path (relative to cwd)"},
      p = {clipboard.copy_file_path_from_home, desc = "Copy file path (from home)"},
      n = {clipboard.copy_file_name, desc = "Copy file name"},
      a = {
        clipboard.copy_file_path_claude_style,
        desc = 'Copy file w "@" prefix'
      },
      g = {
        function()
          local path =
            vim.fn.system("git ls-files --full-name " .. vim.fn.shellescape(vim.fn.expand("%:p"))):gsub("\n", "")
          vim.fn.setreg("+", path)
          vim.notify("Copied: " .. path, vim.log.levels.INFO)
        end,
        desc = "Copy file path (relative to git)"
      },
      o = {clipboard.copy_code_path, desc = "Copy object path"},
      O = {clipboard.copy_code_path_with_types, desc = "Copy object path (with types)"},
      s = {clipboard.copy_path_from_src, desc = "Copy path from src (@/...)"},
      w = {cmd = "OpenFileInRepo", desc = "Open file in web browser"},
      l = {clipboard.copy_file_path_with_line, desc = "Copy file path to clipboard"},
      L = {cmd = "YankLineUrl +", desc = "Copy file URL with line to clipboard"}
    },
    [ctrl] = {
      l = {clipboard.copy_lines, [mode] = {"n", "v"}, desc = "Copy lines (or selection)"}
    }
  }
)

map(
  {
    ["<leader>sn"] = {
      L = {
        function()
          local messages = require("noice.message.manager").get({}, {history = true, sort = true})
          local last = messages[#messages]
          if last then
            vim.fn.setreg("+", last:content())
            vim.notify("Copied to clipboard")
          end
        end,
        desc = "Copied last notification to clipboard"
      },
      a = {
        cmd = "NoiceAll",
        desc = "Show all notifications"
      },
      l = {
        cmd = "NoiceLast",
        desc = "Show last notification"
      }
    }
  }
)

map(
  {
    g = {
      D = {code.go_to_source_definition, desc = "Go to source definition"},
      R = {code.file_references, desc = "File references"}
    }
  }
)

map(
  {
    ["<leader>c"] = {
      o = {code.organize_imports, desc = "Organize + Remove Unused Imports"},
      O = {code.organize_imports_and_fix, desc = "Organize Imports + Fix All Diagnostics"},
      I = {code.add_missing_imports, desc = "Add missing imports"},
      u = {code.remove_unused_imports, desc = "Remove unused imports"},
      F = {code.fix_all, desc = "Fix all diagnostics"},
      V = {code.select_ts_version, desc = "Select TS workspace version"},
      t = {editor.typescript_check, desc = "TypeScript check (tsc)"},
      g = {editor.typescript_check_go, desc = "TypeScript check (tsgo)"},
      C = {":Claude<CR>", desc = "Claude replace"}
    }
  }
)

map(
  {
    ["<leader>sr"] = {
      function()
        Snacks.picker.recent()
      end,
      desc = "Recent files"
    },
    [ctrl] = {
      w = {
        function()
          local win = vim.api.nvim_get_current_win()
          if vim.api.nvim_win_get_config(win).relative ~= "" then
            vim.api.nvim_win_close(win, false)
          else
            vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<C-w>", true, false, true), "n")
          end
        end,
        desc = "Close float / window prefix"
      },
      f = {files.find_files, desc = "Find files (git root)"},
      s = {files.save_file, desc = "Save file"},
      S = {files.save_and_stage_file, desc = "Save and stage file"},
      ["/"] = {cmd = ":SearxngAutocomplete", desc = "SearXNG Autocomplete"},
      ["\\"] = {cmd = ":SearxngEngines", desc = "SearXNG Engines"},
      k = {cmd = "bprev", desc = "Previous buffer"},
      y = {cmd = "bnext", desc = "Next buffer"},
      ["<C-S-PageDown>"] = {cmd = "bnext", desc = "Next buffer"},
      ["<C-S-PageUp>"] = {cmd = "bprev", desc = "Previous buffer"}
    }
  }
)

map(
  {
    ["<leader>h"] = {
      b = {cmd = "BrowserBookmarks", desc = "Browser bookmarks"},
      f = {cmd = "BrowserHistory", desc = "Browser history"},
      s = {history.smart_file_history, desc = "Smart history picker"},
      l = {history.git_log_picker, desc = "Git log"},
      u = {cmd = "undolist", desc = "View undo list"},
      T = {history.manual_backup_with_tag, desc = "Manual backup with tag"},
      p = {history.project_files_history, desc = "Project files history"}
    }
  }
)

map(
  {
    ["<leader>r"] = {
      l = {cmd = "Leet run", desc = "Leet run (test)"},
      S = {cmd = "SnipReset", desc = "Reset sniprun"}
    }
  }
)

map(
  {
    ["]t"] = {require("todo-comments").jump_next, desc = "Next Todo Comment"},
    ["[t"] = {require("todo-comments").jump_prev, desc = "Previous Todo Comment"}
  }
)

map(
  {
    ["<leader>x"] = {
      x = {cmd = "Trouble diagnostics toggle", desc = "Diagnostics (Trouble)"},
      X = {cmd = "Trouble diagnostics toggle filter.buf=0", desc = "Buffer Diagnostics (Trouble)"},
      L = {cmd = "Trouble loclist toggle", desc = "Location List (Trouble)"},
      Q = {cmd = "Trouble qflist toggle", desc = "Quickfix List (Trouble)"},
      s = {cmd = "Trouble symbols toggle", desc = "Symbols (Trouble)"},
      S = {cmd = "Trouble lsp toggle", desc = "LSP references/definitions (Trouble)"},
      t = {cmd = "Trouble todo toggle", desc = "Todo (Trouble)"},
      T = {cmd = "Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}", desc = "Todo/Fix/Fixme"}
    },
    ["[q"] = {
      function()
        if require("trouble").is_open() then
        else
          local ok, err = pcall(vim.cmd.cprev)
          if not ok then
            vim.notify(err, vim.log.levels.ERROR)
          end
        end
      end,
      desc = "Previous Trouble/Quickfix Item"
    },
    ["]q"] = {
      function()
        if require("trouble").is_open() then
        else
          local ok, err = pcall(vim.cmd.cnext)
          if not ok then
            vim.notify(err, vim.log.levels.ERROR)
          end
        end
      end,
      desc = "Next Trouble/Quickfix Item"
    }
  }
)

map(
  {
    ["<leader>s"] = {
      l = {
        function()
          Snacks.picker.lines()
        end,
        desc = "Search buffer lines"
      },
      K = {cmd = "KMUInspect", exec = true, desc = "KMU only inspect"},
      D = {cmd = "ProjectDiagnostics", desc = "Project Diagnostics"}
    }
  }
)

map(
  {
    ["<leader>db"] = {
      u = {cmd = "DBUIToggle", desc = "Toggle DBUI"},
      f = {cmd = "DBUIFindBuffer", desc = "Find buffer"},
      r = {cmd = "DBUIRenameTab", desc = "Rename buffer"},
      q = {cmd = "DBUILastQueryInfo", desc = "Last query info"}
    }
  }
)

map(
  {
    ["<leader>o"] = {
      group = "GitHub",
      i = {
        group = "Issues",
        l = {
          function()
            Snacks.picker.gh_issue({repo = git.get_github_repo()})
          end,
          desc = "Issues (open)"
        },
        i = {
          function()
            Snacks.picker.gh_issue({assignee = "@me", repo = git.get_github_repo()})
          end,
          desc = "Issues (assigned to me)"
        },
        a = {
          function()
            Snacks.picker.gh_issue({state = "all", repo = git.get_github_repo()})
          end,
          desc = "Issues (all - open + closed)"
        },
        c = {
          function()
            Snacks.picker.gh_issue({state = "closed", repo = git.get_github_repo()})
          end,
          desc = "Issues (closed)"
        },
        b = {
          function()
            Snacks.picker.gh_issue({author = vim.fn.input("Author: "), repo = git.get_github_repo()})
          end,
          desc = "Issues (filter by author)"
        },
        C = {cmd = "Octo issue create", desc = "Create new issue"},
        A = {
          group = "Assignees",
          a = {cmd = "Octo assignee add ", exec = false, desc = "Add assignee to issue"},
          d = {cmd = "Octo assignee remove ", exec = false, desc = "Remove assignee from issue"}
        }
      },
      p = {
        group = "Pull Requests",
        l = {
          function()
            Snacks.picker.gh_pr({repo = git.get_github_repo()})
          end,
          desc = "PRs (open)"
        },
        a = {
          function()
            Snacks.picker.gh_pr({state = "all", repo = git.get_github_repo()})
          end,
          desc = "PRs (all - open + closed + merged)"
        },
        m = {
          function()
            Snacks.picker.gh_pr({state = "merged", repo = git.get_github_repo()})
          end,
          desc = "PRs (merged only)"
        },
        c = {
          function()
            Snacks.picker.gh_pr({state = "closed", repo = git.get_github_repo()})
          end,
          desc = "PRs (closed only)"
        },
        d = {
          function()
            Snacks.picker.gh_pr({draft = true, repo = git.get_github_repo()})
          end,
          desc = "PRs (draft only)"
        },
        C = {cmd = "Octo pr create", desc = "Create new PR"},
        R = {
          group = "Reviewers",
          a = {cmd = "Octo reviewer add ", exec = false, desc = "Add reviewer to PR"},
          d = {cmd = "Octo reviewer remove ", exec = false, desc = "Remove reviewer from PR"}
        }
      },
      v = {
        group = "Review",
        s = {cmd = "Octo review start", desc = "Start review"},
        r = {cmd = "Octo review resume", desc = "Resume review"},
        S = {cmd = "Octo review submit", desc = "Submit review"},
        d = {cmd = "Octo review discard", desc = "Discard review"},
        c = {cmd = "Octo review comments", desc = "Review comments"}
      },
      t = {
        group = "Threads",
        r = {cmd = "Octo thread resolve", desc = "Resolve thread"},
        u = {cmd = "Octo thread unresolve", desc = "Unresolve thread"}
      },
      r = {
        group = "Repository",
        w = {cmd = "Octo repo browser", desc = "Browse repo"},
        i = {cmd = "Octo repo list", desc = "My repositories"},
        l = {cmd = "Octo repo url", desc = "Copy url"}
      },
      a = {
        function()
          local Actions = require("snacks.gh.actions")
          local Api = require("snacks.gh.api")
          local buf = vim.api.nvim_get_current_buf()
          local gh_meta = vim.b[buf].snacks_gh
          local item
          if gh_meta and gh_meta.type and gh_meta.repo and gh_meta.number then
            item = Api.get({type = gh_meta.type, repo = gh_meta.repo, number = gh_meta.number})
          else
            item = Api.current_pr()
          end
          if item then
            Actions.actions.gh_comment.action(item, {items = {item}})
          else
            vim.notify("Not in a GitHub PR/Issue buffer", vim.log.levels.WARN)
          end
        end,
        desc = "Add comment"
      },
      n = {cmd = "Octo notifications", desc = "Notifications"}
    }
  }
)

local notes = require("utils.notes")

map(
  {
    [disabled] = false,
    ["<leader>O"] = {
      n = {cmd = "ObsidianNew", desc = "New note [title]", icon = ""},
      N = {
        function()
        end,
        desc = "New note [YY-MM-DD-title]",
        icon = ""
      },
      o = {cmd = "ObsidianOpen", exec = false, desc = "Open note [query]"},
      q = {cmd = "ObsidianQuickSwitch", desc = "Quick switch [query]"},
      t = {cmd = "ObsidianToday", desc = "Today's note"},
      y = {cmd = "ObsidianYesterday", desc = "Yesterday's note"},
      T = {cmd = "ObsidianTomorrow", desc = "Tomorrow's note"},
      s = {cmd = "ObsidianSearch", desc = "Search notes [query]"},
      b = {cmd = "ObsidianBacklinks", desc = "Backlinks"},
      l = {cmd = "ObsidianLinks", desc = "Links in note"},
      g = {cmd = "ObsidianTags", desc = "Search tags [query]"},
      te = {disabled = true, cmd = "ObsidianTemplate", desc = "Insert template [name]"},
      to = {disabled = true, cmd = "ObsidianTOC", desc = "Table of contents"},
      r = {cmd = "ObsidianRename", desc = "Rename note [name]"},
      p = {cmd = "ObsidianPasteImg", desc = "Paste image [name]"},
      w = {cmd = "ObsidianWorkspace", desc = "Switch workspace [name]"},
      d = {notes.open_notes_directory, desc = "Open notes directory"},
      L = {[x] = {cmd = "ObsidianLinkNew", desc = "Link to new note [title]"}},
      k = {[x] = {cmd = "ObsidianLink", desc = "Link to existing note [query]"}}
    },
    ["<leader>N"] = {notes.create_inbox_note, desc = "New note in inbox"}
  }
)

kmu.register_groups()

kmu.setup_inspect()

require("config.keymaps.modes")
require("config.keymaps.insert")
require("config.keymaps.terminal")
require("config.keymaps.claude")

kmu.safe_del({"n", "x"}, "s")
vim.keymap.set({"n"}, "j", "o", {desc = "Open line below"})
vim.keymap.set({"n"}, "J", "O", {desc = "Open line above"})

vim.keymap.set({"n"}, "b", "r", {desc = "Replace single char"})
vim.keymap.set({"n"}, "B", "R", {desc = "Replace mode"})

vim.keymap.set({"v"}, "B", "r", {desc = "Replace selected text"})

vim.keymap.set({"n"}, "o", "<C-o>", {desc = "Jumplist backward"})
vim.keymap.set({"n"}, "O", "<C-i>", {desc = "Jumplist forward"})

vim.keymap.set({"n", "o", "x"}, "l", "b", {desc = "Word back"})
vim.keymap.set({"n", "o", "x"}, "L", "B", {desc = "WORD back"})
vim.keymap.set({"n", "o", "x"}, "D", "W", {desc = "WORD forward"})

vim.keymap.set({"n"}, "'", "gv", {desc = "Repeat last visual selection"})
vim.keymap.set({"n", "o", "x"}, "%", "%", {desc = "Jump to matching bracket"})

vim.keymap.set({"n", "o", "x"}, "<M-h>", "gE", {desc = "End of WORD back"})
vim.keymap.set({"n", "o", "x"}, "<M-o>", "E", {desc = "End of WORD forward"})

vim.keymap.set({"n", "x"}, "gX", "X", {desc = "Delete before cursor"})
vim.keymap.set({"n", "x"}, "gU", "U", {desc = "Uppercase"})
vim.keymap.set({"n", "x"}, "gQ", "Q", {desc = "Ex mode"})
vim.keymap.set({"n", "x"}, "gK", "K", {desc = "Lookup keyword"})
vim.keymap.set({"n", "x"}, "gh", "K", {desc = "Lookup keyword"})

vim.api.nvim_create_autocmd(
  "User",
  {
    pattern = "BufferClose",
    callback = function()
      local bufs =
        vim.tbl_filter(
        function(b)
          return vim.api.nvim_buf_is_loaded(b) and vim.bo[b].buflisted
        end,
        vim.api.nvim_list_bufs()
      )
      if #bufs == 0 then
        vim.schedule(
          function()
            require("snacks").dashboard()
          end
        )
      end
    end
  }
)

vim.keymap.set(
  {"n"},
  "<C-;>",
  function()
    vim.o.showtabline = vim.o.showtabline == 0 and 2 or 0
  end,
  {noremap = true, desc = "Toggle bento tabline"}
)

vim.keymap.set({"n", "i", "v"}, "<F1>", "<nop>", {desc = "Disabled"})

vim.keymap.set({"n", "o", "v"}, "r", "i", {desc = "O/V mode: inner (i)"})
vim.keymap.set({"n", "o", "v"}, "t", "a", {desc = "O/V mode: a/an (a)"})

vim.keymap.set({"o", "v"}, "X", "r", {desc = "Replace"})
vim.keymap.set({"o", "v"}, "rd", "iw", {desc = "Inner word"})
vim.keymap.set({"o", "v"}, "td", "aw", {desc = "Around word"})
vim.keymap.set({"o", "v"}, "rD", "iW", {desc = "Inner WORD"})
vim.keymap.set({"o", "v"}, "tD", "aW", {desc = "Around WORD"})
vim.keymap.set({"v"}, "rd", "iw", {desc = "Inner word (visual)"})
vim.keymap.set({"v"}, "td", "aw", {desc = "Around word (visual)"})
vim.keymap.set({"v"}, "rD", "iW", {desc = "Inner WORD (visual)"})
vim.keymap.set({"v"}, "tD", "aW", {desc = "Around WORD (visual)"})

vim.keymap.set(
  "v",
  "<leader>sF",
  search.grug_far_selection_current_file,
  {desc = "Search/Replace selection in current file (Grug-far)"}
)
