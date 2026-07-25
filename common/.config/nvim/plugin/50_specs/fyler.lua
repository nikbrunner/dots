Edit.later(function()
	vim.pack.add({ "https://github.com/FylerOrg/fyler.nvim" })

	local function natural(str)
		return (str:gsub("%d+", function(n)
			return string.format("%010d", n)
		end))
	end

	-- Mirrors fyler's tree order (fyler.lib.fs.sort): within a directory,
	-- subdirectories precede files, then natural-numeric name order.
	local function before_in_tree(a, b)
		local a_seg, b_seg = vim.split(a, "/"), vim.split(b, "/")
		for i = 1, math.min(#a_seg, #b_seg) do
			if a_seg[i] ~= b_seg[i] then
				local a_dir, b_dir = i < #a_seg, i < #b_seg
				if a_dir ~= b_dir then
					return a_dir
				end
				return natural(a_seg[i]) < natural(b_seg[i])
			end
		end
		return #a_seg < #b_seg
	end

	---@param root string
	---@return string[] paths relative to root, in tree order
	local function changed_files(root)
		local result = vim.system({ "git", "-C", root, "status", "--porcelain", "-z" }, { text = true }):wait()
		if result.code ~= 0 then
			return {}
		end

		local paths = {}
		local entries = vim.split(result.stdout or "", "\0", { trimempty = true })
		local skip_next = false
		for _, entry in ipairs(entries) do
			if skip_next then
				skip_next = false
			else
				local xy, path = entry:sub(1, 2), entry:sub(4)
				if path ~= "" then
					-- Renames encode "R  new" followed by a separate old-path record.
					if xy:sub(1, 1) == "R" then
						skip_next = true
					end
					-- Deleted paths never render in the tree, so they would trap the walk.
					if vim.uv.fs_stat(vim.fs.joinpath(root, path)) then
						table.insert(paths, path)
					end
				end
			end
		end

		table.sort(paths, before_in_tree)
		return paths
	end

	---@param instance table
	---@param direction -1|1
	local function goto_git_file(instance, direction)
		local root = instance.state.pseudo_root_path
		local paths = changed_files(root)
		if #paths == 0 then
			return vim.notify("Fyler: no changed files", vim.log.levels.INFO)
		end

		local node = require("fyler.finder").parse_cursor_line(instance)
		local current = node and node.path ~= root and vim.fs.relpath(root, node.path) or nil

		local target
		if direction == 1 then
			for _, path in ipairs(paths) do
				if not current or before_in_tree(current, path) then
					target = path
					break
				end
			end
			target = target or paths[1]
		else
			for i = #paths, 1, -1 do
				if not current or before_in_tree(paths[i], current) then
					target = paths[i]
					break
				end
			end
			target = target or paths[#paths]
		end

		instance:follow({ target_path = vim.fs.joinpath(root, target) })
	end

	require("fyler").setup({
		auto_confirm_simple_mutation = true,
		integrations = {
			icon = "mini_icons",
		},
		extensions = {
			git = { enabled = true, inline = false },
		},
		indent_guides = false,
		ui = {
			hidden_items = { switches = {} },
		},
		mappings = {
			n = {
				["g."] = {
					action = function(instance)
						local switches = instance.cache.ui.hidden_items.switches
						switches.dotfiles = not switches.dotfiles
						instance:refresh()
					end,
				},
				["]c"] = {
					action = function(instance)
						goto_git_file(instance, 1)
					end,
				},
				["[c"] = {
					action = function(instance)
						goto_git_file(instance, -1)
					end,
				},
			},
		},
	})

	vim.api.nvim_create_autocmd("CursorMoved", {
		group = vim.api.nvim_create_augroup("fyler_center_cursor", { clear = true }),
		callback = function(args)
			if vim.bo[args.buf].filetype == "fyler_finder" then
				vim.cmd("normal! zz")
			end
		end,
	})

	vim.keymap.set("n", "-", function()
		require("fyler").open()
	end, { desc = "Open Fyler" })

	vim.keymap.set("n", "<leader>we", function()
		require("fyler").open()
	end, { desc = "Open Fyler" })

	vim.keymap.set("n", "_", function()
		require("fyler").open({ root_path = vim.fn.getcwd() })
	end, { desc = "Open Fyler (Root)" })

	vim.keymap.set("n", "<leader>wE", function()
		require("fyler").open({ root_path = vim.fn.getcwd() })
	end, { desc = "Open Fyler (Root)" })
end)
