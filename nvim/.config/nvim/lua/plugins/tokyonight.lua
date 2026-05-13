return {
	"folke/tokyonight.nvim",
	lazy = false,
	priority = 1000,
	opts = {
		transparent = true,
		on_highlights = function(hl, _)
			hl.NeoTreeNormal = { bg = "NONE" }
			hl.NeoTreeNormalNC = { bg = "NONE" }
			hl.NeoTreeEndOfBuffer = { bg = "NONE" }
			hl.NeoTreeWinSeparator = { bg = "NONE", fg = "NONE" }
		end,
	},
}
