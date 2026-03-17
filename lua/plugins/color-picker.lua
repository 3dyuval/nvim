return {
  {
    "3dyuval/colortweak.nvim",
    lazy = false,
    opts = {},
  },
  {
    dir = "/home/yuv/colortuner.nvim",
    cmd = {
      "Colortuner",
      "ColortunerPalette",
      "ColortunerTune",
      "ColortunerHue",
      "ColortunerSaturation",
      "ColortunerLightness",
    },
    keys = {
      { "<leader>cw", "<cmd>Colortuner<cr>",           desc = "Color tuner (auto)" },
      { "<leader>cp", "<cmd>ColortunerPalette<cr>",    desc = "Color palette" },
      { "<leader>ch", "<cmd>ColortunerHue<cr>",        desc = "Color hue" },
      { "<leader>cs", "<cmd>ColortunerSaturation<cr>", desc = "Color saturation" },
      { "<leader>cl", "<cmd>ColortunerLightness<cr>",  desc = "Color lightness" },
    },
    opts = {
      ui = {
        inline = {
          position = "right",
          steps = 9,
        },
        keys = {
          x_inc = "i",
          x_dec = "h",
          y_inc = "e",
          y_dec = "a",
        },
      },
    },
  },
  {
    "NvChad/nvim-colorizer.lua",
    event = "BufReadPost",
    keys = {
      { "<leader>ct", "<cmd>ColorizerToggle<cr>", desc = "Color highlight toggle" },
    },
    opts = {
      user_default_options = {
        names = false,
        css = true,
        tailwind = true,
      },
    },
  },
}
