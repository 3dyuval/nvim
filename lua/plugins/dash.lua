return {
	"johnseth97/gh-dash.nvim",
	lazy = true,
	cmd = { "GHdash", "GHdashToggle" },
	keys = {
		{
			"<leader>gh",
			function()
				require("gh_dash").toggle()
			end,
			desc = "GitHub Dashboard",
		},
	},
	opts = {
		keymaps = {},
		border = "rounded",
		width = 0.8,
		height = 0.8,
		autoinstall = true,
	},
}
