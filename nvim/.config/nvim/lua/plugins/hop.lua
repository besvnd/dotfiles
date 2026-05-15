return {
	"smoka7/hop.nvim",
	version = "*",
	event = "VeryLazy",
	opts = {
		keys = "etovxqpdygfblzhckisuran",
	},
	keys = {
		{ "s", "<cmd>HopChar1<CR>", mode = { "n", "x", "o" }, desc = "Hop to char" },
		{ "S", "<cmd>HopWord<CR>", mode = { "n", "x", "o" }, desc = "Hop to word" },
		{ "<leader>j", "<cmd>HopLineStart<CR>", mode = { "n", "x", "o" }, desc = "Hop to line" },
	},
}
