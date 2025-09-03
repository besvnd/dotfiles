return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    opts.formatters_by_ft = vim.tbl_extend("force", opts.formatters_by_ft or {}, {
      java = { "palantir_java_format" },
    })

    opts.formatters = opts.formatters or {}
    opts.formatters.palantir_java_format = {
      command = vim.fn.expand("~/opt/bin/palantir-java-format"),
      args = { "--palantir", "--replace", "$FILENAME" },
      stdin = false,
    }

    return opts
  end,
}
