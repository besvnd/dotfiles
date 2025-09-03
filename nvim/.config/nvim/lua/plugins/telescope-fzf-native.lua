return {
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      -- This will run only *after* telescope is loaded
      require("telescope").load_extension("fzf")
    end,
  },
}
