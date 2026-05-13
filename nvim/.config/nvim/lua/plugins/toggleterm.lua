return {
	"akinsho/toggleterm.nvim",
	version = "*",
	opts = {
		open_mapping = [[<C-`>]],
		direction = "tab",
	},
	config = function(_, opts)
		require("toggleterm").setup(opts)

		local Terminal = require("toggleterm.terminal").Terminal
		local copilot = Terminal:new({
			cmd = "gh copilot",
			direction = "vertical",
			hidden = true,
			on_open = function(term)
				vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<leader>cc", "<cmd>close<cr>", { silent = true })
			end,
		})

		local term = Terminal:new({
			direction = "horizontal",
			hidden = true,
			on_open = function(t)
				vim.api.nvim_buf_set_keymap(t.bufnr, "t", "<leader>tt", "<cmd>close<cr>", { silent = true })
			end,
		})

		vim.keymap.set("n", "<leader>cc", function()
			copilot:toggle()
		end, { desc = "Toggle GitHub Copilot CLI" })

		vim.keymap.set("n", "<leader>tt", function()
			term:toggle()
		end, { desc = "Toggle terminal" })
	end,
}
