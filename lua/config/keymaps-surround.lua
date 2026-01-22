require("keymap-utils").map({
  y = {
    group = "Yank/Surround",
    s = {
      ["("] = { desc = "(text)" },
      [")"] = { desc = "( text )" },
      ["["] = { desc = "[text]" },
      ["]"] = { desc = "[ text ]" },
      ["{"] = { desc = "{text}" },
      ["}"] = { desc = "{ text }" },
      ["<"] = { desc = "< text >" },
      [">"] = { desc = "<text>" },
      ['"'] = { desc = '"text"' },
      ["'"] = { desc = "'text'" },
      ["`"] = { desc = "```lang\\ntext\\n```" },
      ["*"] = { desc = "**text**" },
      ["_"] = { desc = "_text_" },
      ["~"] = { desc = "~text~" },
      i = {
        f = { desc = "func(text)" },
        t = { desc = "<tag>text</tag>" },
      },
    },
    S = {
      ["("] = { desc = "(\\ntext\\n)" },
      i = {
        f = { desc = "func(\\ntext\\n)" },
        t = { desc = "<tag>\\ntext\\n</tag>" },
      },
    },
    ss = { desc = "Surround line" },
    SS = { desc = "Surround line (newlines)" },
  },
  x = {
    group = "Delete",
    s = {
      ["("] = { desc = "Delete ()" },
      ["["] = { desc = "Delete []" },
      ["{"] = { desc = "Delete {}" },
      ['"'] = { desc = 'Delete ""' },
      ["'"] = { desc = "Delete ''" },
      i = {
        f = { desc = "Delete func()" },
        t = { desc = "Delete <tag></tag>" },
      },
    },
    st = { desc = "Delete surrounding tag" },
  },
  w = {
    group = "Change",
    s = {
      ["("] = { desc = "Change to ()" },
      ["["] = { desc = "Change to []" },
      ["{"] = { desc = "Change to {}" },
      ['"'] = { desc = 'Change to ""' },
      ["'"] = { desc = "Change to ''" },
      i = {
        f = { desc = "Change to func()" },
        t = { desc = "Change to <tag>" },
      },
    },
  },
  d = {
    group = "Delete (default)",
    s = {
      ["("] = { desc = "Delete ()" },
      i = {
        f = { desc = "Delete func()" },
        t = { desc = "Delete <tag></tag>" },
      },
    },
  },
  c = {
    group = "Change (default)",
    s = {
      ["("] = { desc = "Change to ()" },
      i = {
        f = { desc = "Change to func()" },
        t = { desc = "Change to <tag>" },
      },
    },
    S = {
      ["("] = { desc = "Change to (\\ntext\\n)" },
      i = {
        f = { desc = "Change to func(\\ntext\\n)" },
        t = { desc = "Change to <tag>\\ntext\\n</tag>" },
      },
    },
  },
  [mode] = { "x" },
  s = {
    group = "Surround",
    ["("] = { desc = "(text)" },
    [")"] = { desc = "( text )" },
    ["["] = { desc = "[text]" },
    ["{"] = { desc = "{text}" },
    ['"'] = { desc = '"text"' },
    ["'"] = { desc = "'text'" },
    i = {
      f = { desc = "func(text)" },
      t = { desc = "<tag>text</tag>" },
    },
  },
  S = {
    group = "Surround",
    ["("] = { desc = "(text)" },
    i = {
      f = { desc = "func(text)" },
      t = { desc = "<tag>text</tag>" },
    },
  },
  g = {
    group = "Go/Surround",
    S = {
      ["("] = { desc = "(\\ntext\\n)" },
      i = {
        f = { desc = "func(\\ntext\\n)" },
        t = { desc = "<tag>\\ntext\\n</tag>" },
      },
    },
  },
})
