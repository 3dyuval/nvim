-- Colorscheme configuration
-- This file is managed by omarchy-theme-set-neovim

return {
	{
		"folke/tokyonight.nvim",
		priority = 1000,
		opts = {
<<<<<<< Updated upstream:lua/plugins/colorscheme.lua
			transparent_background = true,
=======
			transparent = true,
			styles = {
				sidebars = "transparent",
				floats = "transparent",
			},
>>>>>>> Stashed changes:lua/plugins/colorscheme-persist.lua
		},
	},
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "tokyonight-night",
		},
	},
}
