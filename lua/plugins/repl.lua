return {
  -- Sniprun: Run code snippets in isolation (like Quokka)
  {
    "michaelb/sniprun",
    build = "sh install.sh",
    cmd = { "SnipRun", "SnipClose", "SnipReset" },
    opts = {
      display = { "VirtualText" },
      display_options = {
        virtual_text_line_number = 0,
      },
      repl_enable = { "JS_TS_deno" },
      interpreter_options = {
        JS_TS_deno = {
          use_on_filetypes = { "javascript", "typescript" },
        },
      },
    },
    config = function(_, opts)
      require("sniprun").setup(opts)
      -- Derive sniprun highlights from theme
      require("colortweak.tweak").hl({
        SniprunVirtualTextOk = { "DiagnosticOk", { l = 1.1 } },
        SniprunVirtualTextErr = { "DiagnosticError", {} },
      })
    end,
  },

  -- Conjure: Persistent REPL (disabled - use sniprun instead)
  {
    "Olical/conjure",
    enabled = false,
    ft = { "javascript", "fennel", "elixir", "ruby" },
    lazy = true,
    init = function()
      vim.g["conjure#log#hud#enabled"] = false
      vim.g["conjure#mapping#prefix"] = "<leader>"
      vim.g["conjure#mapping#eval_current_form"] = "rr"
      vim.g["conjure#mapping#eval_root_form"] = "re"
      vim.g["conjure#mapping#eval_buf"] = "rb"
      vim.g["conjure#mapping#eval_word"] = "rw"
      vim.g["conjure#mapping#eval_replace_form"] = "r!"
      vim.g["conjure#mapping#eval_visual"] = "r"
      vim.g["conjure#mapping#eval_motion"] = "rm"
      vim.g["conjure#mapping#eval_file"] = "rf"
    end,
  },
}
