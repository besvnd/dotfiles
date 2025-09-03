vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.expandtab = true
vim.opt_local.autoindent = true
vim.opt_local.smarttab = true

local ok, dap = pcall(require, "dap")
if not ok then
  return
end

dap.configurations.java = dap.configurations.java or {}
table.insert(dap.configurations.java, {
  type = "java",
  request = "attach",
  name = "Attach to Quarkus (5005)",
  hostName = "127.0.0.1",
  port = 5005,
})
