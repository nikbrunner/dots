-- VSCode-style diff view with explorer, history, and merge conflict support.

Edit.later(function()
	-- nui.nvim is a required dependency (vim.pack does not resolve dependencies)
	vim.pack.add({
		"git@github.com:MunifTanjim/nui.nvim",
		"git@github.com:esmuellert/codediff.nvim",
	})

	require("codediff").setup({
		char_brightness = 1, -- disable auto-adjustment
		explorer = {
			view_mode = "tree",
			height = 10,
		},
		keymaps = {
			view = {
				quit = "q",
				toggle_explorer = "<leader>b",
				focus_explorer = "<leader>e",
				next_hunk = "]c",
				prev_hunk = "[c",
				next_file = "]f",
				prev_file = "[f",
				diff_get = "do",
				diff_put = "dp",
				open_in_prev_tab = "gf",
				close_on_open_in_prev_tab = false,
				toggle_stage = "s",
				hunk_textobject = "ih",
				show_help = "g?",
				align_move = "gm",
				toggle_layout = "t",
			},
			explorer = {
				select = "<CR>",
				hover = "K",
				refresh = "R",
				open_in_prev_tab = "gf",
				toggle_view_mode = "i",
				toggle_stage = "s",
				stage_all = "S",
				unstage_all = "U",
				restore = "X",
				toggle_changes = "gu",
				toggle_staged = "gs",
				fold_open = "zo",
				fold_open_recursive = "zO",
				fold_close = "zc",
				fold_close_recursive = "zC",
				fold_toggle = "za",
				fold_toggle_recursive = "zA",
				fold_open_all = "zR",
				fold_close_all = "zM",
			},
			history = {
				select = "<CR>",
				toggle_view_mode = "i",
				fold_open = "zo",
				fold_open_recursive = "zO",
				fold_close = "zc",
				fold_close_recursive = "zC",
				fold_toggle = "za",
				fold_toggle_recursive = "zA",
				fold_open_all = "zR",
				fold_close_all = "zM",
			},
			conflict = {
				accept_incoming = "<leader>ct",
				accept_current = "<leader>co",
				accept_both = "<leader>cb",
				discard = "<leader>cx",
				next_conflict = "]x",
				prev_conflict = "[x",
				diffget_incoming = "2do",
				diffget_current = "3do",
			},
		},
	})

	-- Hook into set_tab_keymap to re-apply gf on explorer buffers.
	-- The view keymaps set gf tab-wide via set_tab_keymap, but the handler
	-- silently returns for non-diff buffers (explorer, history). This intercepts
	-- that call and overrides gf on explorer buffers to open the selected file
	-- in the previous tab.
	local lifecycle = require("codediff.ui.lifecycle")
	local orig_set_tab_keymap = lifecycle.set_tab_keymap

	lifecycle.set_tab_keymap = function(tabpage, mode, lhs, rhs, keymap_opts)
		orig_set_tab_keymap(tabpage, mode, lhs, rhs, keymap_opts)

		if lhs ~= "gf" or mode ~= "n" then
			return
		end

		local active_diffs = require("codediff.ui.lifecycle.session").get_active_diffs()
		local session = active_diffs[tabpage]
		if not session then
			return
		end

		local explorer = session.explorer
		if not explorer or not explorer.bufnr or not vim.api.nvim_buf_is_valid(explorer.bufnr) then
			return
		end

		vim.keymap.set("n", "gf", function()
			local node = explorer.tree:get_node()
			if not node or not node.data or not node.data.path then
				return
			end
			if node.data.type == "group" or node.data.type == "directory" then
				return
			end

			local full_path = explorer.git_root and (explorer.git_root .. "/" .. node.data.path) or node.data.path

			local current_tab = vim.api.nvim_get_current_tabpage()
			local tabs = vim.api.nvim_list_tabpages()
			local current_idx
			for i, tab in ipairs(tabs) do
				if tab == current_tab then
					current_idx = i
					break
				end
			end

			local target_tab
			if current_idx and current_idx > 1 then
				target_tab = tabs[current_idx - 1]
			else
				vim.cmd("tabnew")
				target_tab = vim.api.nvim_get_current_tabpage()
				vim.cmd("tabmove 0")
			end

			if vim.api.nvim_get_current_tabpage() ~= target_tab then
				vim.api.nvim_set_current_tabpage(target_tab)
			end

			pcall(vim.cmd, "edit " .. vim.fn.fnameescape(full_path))
		end, {
			buffer = explorer.bufnr,
			desc = "Open file in previous tab",
			noremap = true,
			silent = true,
			nowait = true,
		})
	end

	local map = vim.keymap.set

	-- Workspace level
	-- enew ensures CodeDiff resolves git root from cwd, not a stale buffer path
	map("n", "<leader>wgd", "<cmd>enew | CodeDiff<cr>", { desc = "Workspace [D]iff against working tree (CodeDiff)" })
	map("n", "<leader>wgD", "<cmd>enew | CodeDiff master<cr>", { desc = "Workspace [D]iff against master (CodeDiff)" })

	-- Document level
	map("n", "<leader>dgd", "<cmd>CodeDiff file HEAD<cr>", { desc = "Document [D]iff (CodeDiff)" })
	map("n", "<leader>dgD", "<cmd>CodeDiff file master<cr>", { desc = "Document [D]iff (CodeDiff)" })

	map("n", "<leader>wgb", function()
		vim.ui.input({ prompt = "Compare against branch: " }, function(branch)
			if branch and branch ~= "" then
				vim.cmd("enew | CodeDiff " .. branch)
			end
		end)
	end, { desc = "Compare [B]ranch (CodeDiff)" })

	map("n", "<leader>wgpm", "<cmd>CodeDiff merge<cr>", { desc = "[M]erge conflicts (CodeDiff)" })
end)
