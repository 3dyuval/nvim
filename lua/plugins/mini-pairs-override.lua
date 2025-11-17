return {
  {
    "nvim-mini/mini.pairs",
    opts = {
      -- Skip autopair when next character is one of these
      skip_next = [=[[%w%%%'%[%"%.%`%$]]=], -- word chars, %, ', [, ", ., `, $
      -- Skip autopair when the cursor is inside these treesitter nodes
      skip_ts = { "string", "comment" },
      -- Skip autopair when next character is closing pair and there are more closing pairs than opening pairs
      skip_unbalanced = true,
    },
  },
}