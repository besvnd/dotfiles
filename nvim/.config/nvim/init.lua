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
  { src = "https://github.com/saghen/blink.lib" },
  {	src = "https://github.com/saghen/blink.cmp", version = 'v1' , },
  { src = "https://github.com/kdheepak/lazygit.nvim" },
  { src = "https://github.com/GooseRooster/cairn.nvim" },
  { src = "https://github.com/romus204/tree-sitter-manager.nvim" },
  { src = "https://github.com/folke/flash.nvim" },
  { src = "https://github.com/nvim-mini/mini.nvim" },
  { src = "https://github.com/sphamba/smear-cursor.nvim" },
}) 

-- keymaps
vim.keymap.set('n', '<leader>o', ':update<CR> :source<CR>')
vim.keymap.set('n', '<leader>w', ':write<CR>')
vim.keymap.set("n", "<leader>gg", '<cmd>LazyGit<CR>')
vim.keymap.set("n", '<leader>e', function()
  MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
end, { desc = "Open file explorer" })
vim.keymap.set("n", "<leader>ff", function() MiniPick.builtin.files() end, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", function() MiniPick.builtin.grep_live() end, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", function() MiniPick.builtin.buffers() end, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", function() MiniPick.builtin.help() end, { desc = "Help tags" })
vim.keymap.set("n", "<leader>fd", function()
  MiniExtra.pickers.diagnostic({ scope = "current" })
end, { desc = "Diagnostics (buffer)" })
vim.keymap.set("n", "<leader>fD", function()
  MiniExtra.pickers.diagnostic()
end, { desc = "Diagnostics (workspace)" })
vim.keymap.set('n', '<leader>xx', function()
  vim.diagnostic.setqflist({ severity = vim.diagnostic.severity.ERROR })
end)
vim.keymap.set("n", "=", vim.lsp.buf.format)

vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function(args)
    vim.keymap.set("n", "=", function()
      local view = vim.fn.winsaveview()
      local input = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
      local output = vim.fn.systemlist({ "palantir-java-format", "--palantir", "-" }, input)
      if vim.v.shell_error ~= 0 then
        vim.notify(table.concat(output, "\n"), vim.log.levels.ERROR)
        return
      end
      vim.api.nvim_buf_set_lines(0, 0, -1, false, output)
      vim.fn.winrestview(view)
    end, { buffer = args.buf, desc = "Palantir Java format" })
  end,
})
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

-- flash setup
require("flash").setup()
vim.keymap.set({ "n", "x", "o" }, "s", function() require("flash").jump() end, { desc = "Flash" })
vim.keymap.set({ "n", "x", "o" }, "S", function() require("flash").treesitter() end, { desc = "Flash Treesitter" })
vim.keymap.set("o", "r", function() require("flash").remote() end, { desc = "Remote Flash" })
vim.keymap.set({ "o", "x" }, "R", function() require("flash").treesitter_search() end, { desc = "Treesitter Search" })
vim.keymap.set("c", "<c-s>", function() require("flash").toggle() end, { desc = "Toggle Flash Search" })

-- mini setup
require('mini.pairs').setup()
require('mini.icons').setup()
MiniIcons.mock_nvim_web_devicons()
require('mini.pick').setup()
require('mini.extra').setup()
require('mini.files').setup({
  windows = {
    preview = true,
    width_focus = 40,
    width_nofocus = 20,
    width_preview = 60,
    max_number = 2,
  },
  options = { use_as_default_explorer = true },
})
require('mini.statusline').setup()

-- smear-cursor setup
require('smear_cursor').setup()

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
