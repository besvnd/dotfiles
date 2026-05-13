require("config.lazy")
require("keymaps")

vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"

--help files open in full window and are listed in buffer elements
vim.api.nvim_create_autocmd("FileType", {
	pattern = "help",
	callback = function()
		vim.cmd("only")
		vim.bo.buflisted = true
	end,
})

-- auto-reload files changed outside of nvim
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
	callback = function()
		vim.cmd("silent! checktime")
	end,
})

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.autoindent = true
vim.o.smartindent = true
vim.o.signcolumn = "yes"
vim.o.foldenable = false
vim.o.autoread = true
vim.wo.relativenumber = true

local treesitter = require("treesitter.treesitter_setup")
treesitter.setup()

-- colorscheme
vim.cmd([[colorscheme tokyonight]])
