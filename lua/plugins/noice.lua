return {
	"folke/noice.nvim",
	event = "VeryLazy",
	presets = {
		bottom_search = true,
		view = "cmdline", -- this enables the classic bottom bar
		command_palette = true,
		long_message_to_split = true,
	},
	routes = {
		{
			filter = {
				event = "msg_show",
				kind = "emsg",
				find = "E21",
			},
			opts = { skip = true },
		},
	},
}
