return {
  "mfussenegger/nvim-jdtls",
  ft = { "java" },
  opts = function(_, opts)
    opts.settings = vim.tbl_deep_extend("force", opts.settings or {}, {
      java = {
        format = {
          -- disable JDTLS formatting
          enabled = false,
        },
      },
    })
    return opts
  end,
}
