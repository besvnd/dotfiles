vim.o.number = true
vim.o.relativenumber = true
vim.o.wrap = false
vim.o.tabstop = 4
vim.o.swapfile = false
vim.g.mapleader = " "
vim.o.winborder = "rounded"

-- plugins
vim.pack.add({
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/vague2k/vague.nvim" },
  { src = "https://github.com/stevearc/oil.nvim" },
  { src = "https://github.com/nvim-mini/mini.pick" },
  { src = "https://github.com/saghen/blink.lib" },
  {	src = "https://github.com/saghen/blink.cmp", version = 'v1' , },
  { src = "https://github.com/kdheepak/lazygit.nvim" },
}) 

-- keymaps
vim.keymap.set('n', '<leader>o', ':update<CR> :source<CR>')
vim.keymap.set('n', '<leader>w', ':write<CR>')
vim.keymap.set('n', '<leader>f', ':Pick files<CR>')
vim.keymap.set("n", "<leader>gg", '<cmd>LazyGit<CR>')
vim.keymap.set("n", '<leader>e', function()
  if vim.bo.filetype == 'oil' then
    require("oil.actions").close.callback()
  else
    vim.cmd('Oil')
  end
end)

require "mini.pick".setup()
require "oil".setup()
vim.lsp.enable("jdtls")

-- autocomplete
vim.api.nvim_create_autocmd("InsertEnter", {
	pattern = "*",
	group = group,
	once = true,
	callback = function()
		require("blink.cmp").setup({
			keymap = { preset = "super-tab" },
			appearance = {
				nerd_font_variant = "mono",
				use_nvim_cmp_as_default = true,
			},
			completion = {
				documentation = { auto_show = false },
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},
			fuzzy = { implementation = "prefer_rust_with_warning" },
		})
	end,
})

vim.cmd("colorscheme vague")
vim.cmd(":hi statusline guibg=NONE")
