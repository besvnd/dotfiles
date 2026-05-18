return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	keys = {
		{ "\\", "<cmd>Neotree toggle<cr>", desc = "Toggle Neo-tree" },
	},
	opts = {
		filesystem = {
			filtered_items = {
				visible = true,
				hide_dotfiles = false,
				hide_gitignored = false,
			},
			follow_current_file = {
				enabled = true,
			},
		},
		window = {
			width = 35,
		},
		event_handlers = (function()
			-- Derive Java package name from file path (e.g., src/main/java/com/foo/Bar.java -> com.foo)
			local function java_package_from_path(path)
				local source_roots = { "src/main/java/", "src/test/java/", "src/" }
				for _, root in ipairs(source_roots) do
					local _, root_end = path:find(root, 1, true)
					if root_end then
						local rel = path:sub(root_end + 1)
						local dir = vim.fn.fnamemodify(rel, ":h")
						if dir == "." then
							return nil
						end
						return dir:gsub("/", ".")
					end
				end
				return nil
			end

			local function move_java_class(old_path, new_path)
				local old_pkg = java_package_from_path(old_path)
				local new_pkg = java_package_from_path(new_path)
				if not old_pkg or not new_pkg or old_pkg == new_pkg then
					return
				end

				local class_name = vim.fn.fnamemodify(new_path, ":t:r")
				local old_fqn = old_pkg .. "." .. class_name
				local new_fqn = new_pkg .. "." .. class_name

				-- Update the package declaration in the moved file
				local lines = vim.fn.readfile(new_path)
				for i, line in ipairs(lines) do
					local new_line = line:gsub(
						"^(package%s+)" .. old_pkg:gsub("%.", "%%.") .. "(%s*;)",
						"%1" .. new_pkg .. "%2"
					)
					if new_line ~= line then
						lines[i] = new_line
						break
					end
				end
				vim.fn.writefile(lines, new_path)

				-- Update imports in all other Java files in the project
				local project_root = vim.fs.root(0, { "gradlew", ".git", "mvnw", "pom.xml" }) or vim.fn.getcwd()
				local old_import = old_fqn:gsub("%.", "%%.")
				local new_import = new_fqn

				local java_files = vim.fn.globpath(project_root, "**/*.java", false, true)
				for _, file in ipairs(java_files) do
					if file ~= new_path then
						local flines = vim.fn.readfile(file)
						local file_modified = false
						for j, fline in ipairs(flines) do
							local updated = fline:gsub(
								"(import%s+)" .. old_import .. "(%s*;)",
								"%1" .. new_import .. "%2"
							)
							-- Also update static imports
							updated = updated:gsub(
								"(import%s+static%s+)" .. old_import .. "(%.%w+%s*;)",
								"%1" .. new_import .. "%2"
							)
							if updated ~= fline then
								flines[j] = updated
								file_modified = true
							end
						end
						if file_modified then
							vim.fn.writefile(flines, file)
						end
					end
				end

				-- Reload any open buffers that were modified
				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					if vim.api.nvim_buf_is_loaded(buf) then
						local name = vim.api.nvim_buf_get_name(buf)
						if name:match("%.java$") then
							vim.api.nvim_buf_call(buf, function()
								vim.cmd.edit({ bang = true })
							end)
						end
					end
				end
			end

			local function rename_java_class(old_path, new_path)
				local old_name = vim.fn.fnamemodify(old_path, ":t:r")
				local new_name = vim.fn.fnamemodify(new_path, ":t:r")
				if old_name == new_name then
					return
				end

				-- Load the renamed file into a buffer (file still has old class name)
				local bufnr = vim.fn.bufadd(new_path)
				vim.fn.bufload(bufnr)

				-- Find the class/interface/enum/record declaration position
				local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
				local target_line, target_col
				for i, line in ipairs(lines) do
					for _, kw in ipairs({ "class", "interface", "enum", "record" }) do
						local s = line:find(kw .. "%s+" .. old_name .. "[%s{<(]")
							or line:find(kw .. "%s+" .. old_name .. "$")
						if s then
							local name_start = line:find(old_name, s + #kw)
							target_line = i - 1
							target_col = name_start - 1
							break
						end
					end
					if target_line then
						break
					end
				end

				if not target_line then
					return
				end

				-- Use LSP textDocument/rename to update class name + all references
				local function try_rename(attempts)
					local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "jdtls" })
					if #clients > 0 then
						local client = clients[1]
						client.request("textDocument/rename", {
							textDocument = { uri = vim.uri_from_bufnr(bufnr) },
							position = { line = target_line, character = target_col },
							newName = new_name,
						}, function(err, result)
							if result then
								vim.lsp.util.apply_workspace_edit(result, client.offset_encoding)
								vim.cmd("silent! wall")
							elseif err then
								vim.notify("LSP rename failed: " .. vim.inspect(err), vim.log.levels.WARN)
							end
						end, bufnr)
					elseif attempts > 0 then
						vim.defer_fn(function()
							try_rename(attempts - 1)
						end, 500)
					else
						vim.notify("jdtls not ready — use F2 to rename the class manually", vim.log.levels.WARN)
					end
				end

				-- Give jdtls time to notice the file change
				vim.defer_fn(function()
					try_rename(20)
				end, 1000)
			end

			local function lsp_will_rename(old_path, new_path)
				for _, client in ipairs(vim.lsp.get_clients()) do
					local caps = client.server_capabilities or {}
					local fo = (caps.workspace or {}).fileOperations or {}
					if fo.willRename then
						local bufnr = vim.lsp.get_buffers_by_client_id(client.id)[1]
						if bufnr then
							local resp = client.request_sync("workspace/willRenameFiles", {
								files = {
									{
										oldUri = vim.uri_from_fname(old_path),
										newUri = vim.uri_from_fname(new_path),
									},
								},
							}, 3000, bufnr)
							if resp and resp.result then
								vim.lsp.util.apply_workspace_edit(resp.result, client.offset_encoding)
							end
						end
					end
				end
			end

			local function find_test_counterpart(path, old_name, new_name)
				local suffixes = { "Test", "Tests", "IT" }
				local project_root = vim.fs.root(0, { "gradlew", ".git", "mvnw", "pom.xml" }) or vim.fn.getcwd()

				local is_main = path:find("src/main/java/") ~= nil
				local is_test = path:find("src/test/java/") ~= nil

				if is_main then
					local rel = path:gsub(".*src/main/java/", "")
					local dir = vim.fn.fnamemodify(rel, ":h")
					for _, suffix in ipairs(suffixes) do
						local test_path = project_root
							.. "/src/test/java/"
							.. dir
							.. "/"
							.. old_name
							.. suffix
							.. ".java"
						if vim.uv.fs_stat(test_path) then
							local new_test_path = project_root
								.. "/src/test/java/"
								.. dir
								.. "/"
								.. new_name
								.. suffix
								.. ".java"
							return test_path, new_test_path
						end
					end
				elseif is_test then
					for _, suffix in ipairs(suffixes) do
						if old_name:sub(-#suffix) == suffix then
							local base_old = old_name:sub(1, -#suffix - 1)
							local base_new = new_name:sub(1, -#suffix - 1)
							if base_new == "" then
								break
							end
							local rel = path:gsub(".*src/test/java/", "")
							local dir = vim.fn.fnamemodify(rel, ":h")
							local main_path = project_root
								.. "/src/main/java/"
								.. dir
								.. "/"
								.. base_old
								.. ".java"
							if vim.uv.fs_stat(main_path) then
								local new_main_path = project_root
									.. "/src/main/java/"
									.. dir
									.. "/"
									.. base_new
									.. ".java"
								return main_path, new_main_path
							end
							break
						end
					end
				end
				return nil, nil
			end

			local function rename_counterpart(old_path, new_path, old_name, new_name)
				local counter_old, counter_new = find_test_counterpart(new_path, old_name, new_name)
				if not counter_old or not counter_new then
					return
				end

				local ok, err = os.rename(counter_old, counter_new)
				if not ok then
					vim.notify("Failed to rename counterpart: " .. (err or ""), vim.log.levels.WARN)
					return
				end

				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					if vim.api.nvim_buf_get_name(buf) == counter_old then
						vim.api.nvim_buf_set_name(buf, counter_new)
						vim.api.nvim_buf_call(buf, function()
							vim.cmd.edit({ bang = true })
						end)
					end
				end

				move_java_class(counter_old, counter_new)
				rename_java_class(counter_old, counter_new)

				local counter_file = vim.fn.fnamemodify(counter_new, ":t")
				vim.notify("Also renamed: " .. counter_file, vim.log.levels.INFO)
			end

			local function on_file_rename(args)
				local old = args.source
				local new = args.destination

				if old:match("%.java$") and new:match("%.java$") then
					local old_name = vim.fn.fnamemodify(old, ":t:r")
					local new_name = vim.fn.fnamemodify(new, ":t:r")
					move_java_class(old, new)
					rename_java_class(old, new)
					if old_name ~= new_name then
						rename_counterpart(old, new, old_name, new_name)
					end
				else
					lsp_will_rename(old, new)
				end
			end

			return {
				{ event = "file_renamed", handler = on_file_rename },
				{ event = "file_moved", handler = on_file_rename },
			}
		end)(),
	},
}
