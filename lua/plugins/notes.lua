return {
  "epwalsh/obsidian.nvim",
  enabled = false,
  version = "*", -- recommended, use latest release instead of latest commit
  lazy = true,
  ft = "markdown",
  cmd = {
    "ObsidianNew",
    "ObsidianOpen",
    "ObsidianQuickSwitch",
    "ObsidianToday",
    "ObsidianYesterday",
    "ObsidianTomorrow",
    "ObsidianSearch",
    "ObsidianBacklinks",
    "ObsidianLinks",
    "ObsidianTags",
    "ObsidianTemplate",
    "ObsidianTOC",
    "ObsidianRename",
    "ObsidianPasteImg",
    "ObsidianWorkspace",
    "ObsidianLinkNew",
    "ObsidianLink",
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    workspaces = {
      {
        name = "notes",
        path = "~/notes",
      },
    },
  },
}
