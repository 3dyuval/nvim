return {
  {
    "Olical/conjure",
    ft = { "javascript", "fennel", "elixir", "ruby" },
    lazy = true,
    init = function()
      -- Disable HUD (use <leader>lv for log)
      vim.g["conjure#log#hud#enabled"] = false

      -- Remap 'e' prefix to 'r' (Graphite layout)
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
