local root_dir = vim.fs.root(0, { "gradlew", ".git", "mvnw" })
local project_name = vim.fn.fnamemodify(root_dir or vim.fn.getcwd(), ":p:h:t")
local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

local function get_bundles()
	local bundles = {}
	local mason_path = vim.fn.stdpath("data") .. "/mason/packages"

	local debug_jar =
		vim.fn.glob(mason_path .. "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar")
	if debug_jar ~= "" then
		table.insert(bundles, debug_jar)
	end

	local test_jars = vim.fn.glob(mason_path .. "/java-test/extension/server/*.jar", false, true)
	for _, jar in ipairs(test_jars) do
		table.insert(bundles, jar)
	end

	return bundles
end

local config = {
	cmd = { "jdtls", "-data", workspace_dir },
	root_dir = root_dir,
	settings = {
		java = {},
	},
	init_options = {
		bundles = get_bundles(),
	},
	on_attach = function(client, bufnr)
		require("jdtls").setup_dap({ hotcodereplace = "auto" })
		require("jdtls.dap").setup_dap_main_class_configs()
	end,
}

require("jdtls").start_or_attach(config)
