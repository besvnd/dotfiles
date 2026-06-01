vim.o.number = true
vim.o.relativenumber = true
vim.o.wrap = false
vim.o.tabstop = 4
vim.o.swapfile = false
vim.o.clipboard = "unnamedplus"
vim.g.mapleader = " "
vim.o.winborder = "rounded"

-- plugins
vim.pack.add({
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/scottmckendry/cyberdream.nvim" },
  { src = "https://github.com/stevearc/oil.nvim" },
  { src = "https://github.com/saghen/blink.lib" },
  {	src = "https://github.com/saghen/blink.cmp", version = 'v1' , },
  { src = "https://github.com/kdheepak/lazygit.nvim" },
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/nvim-telescope/telescope.nvim" },
  { src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  { src = "https://github.com/nvim-lualine/lualine.nvim" },
  { src = "https://github.com/GooseRooster/cairn.nvim" },
  { src = "https://github.com/romus204/tree-sitter-manager.nvim" }
}) 

-- keymaps
vim.keymap.set('n', '<leader>o', ':update<CR> :source<CR>')
vim.keymap.set('n', '<leader>w', ':write<CR>')
vim.keymap.set("n", "<leader>gg", '<cmd>LazyGit<CR>')
vim.keymap.set("n", '<leader>e', function()
  if vim.bo.filetype == 'oil' then
    require("oil.actions").close.callback()
  else
    vim.cmd('Oil')
  end
end)
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
vim.keymap.set('n', '<leader>xx', function()
  vim.diagnostic.setqflist({ severity = vim.diagnostic.severity.ERROR })
end)
vim.keymap.set("n", "=", vim.lsp.buf.format)
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- send deletes/changes to the black hole register so they don't clobber the clipboard
for _, key in ipairs({ "d", "D", "c", "C", "x", "X", "s", "S" }) do
  vim.keymap.set({ "n", "v" }, key, '"_' .. key)
end
-- keep a real cut available via <leader>d / <leader>D
vim.keymap.set({ "n", "v" }, "<leader>d", "d")
vim.keymap.set({ "n", "v" }, "<leader>D", "D")


-- telescope setup
local telescope = require("telescope")
telescope.setup({
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    },
  },
})
pcall(telescope.load_extension, "fzf")

-- lualine setup
require "lualine".setup()

-- oil setup
require("oil").setup({
  view_options = {
    show_hidden = true,
  },
})
-- lsp setup
vim.lsp.enable("jdtls")

-- cairn setup
require "cairn".setup()

-- tree-sitter-manager setup
require("tree-sitter-manager").setup({
  -- Default Options
  -- ensure_installed = {}, -- list of parsers to install at the start of a neovim session. If set to "all", install all parsers.
  -- border = nil, -- border style for the window (e.g. "rounded", "single"), if nil, use the default border style defined by 'vim.o.winborder'. See :h 'winborder' for more info.
  -- auto_install = false, -- if enabled, install missing parsers when editing a new file
  -- highlight = true, -- treesitter highlighting is enabled by default
  -- languages = {}, -- override or add new parser sources
})


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


-- themes etc 
vim.cmd("colorscheme cyberdream")
vim.cmd(":hi statusline guibg=NONE")
