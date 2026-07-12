-- Picker backend (files/grep/lsp/git/...) and small QoL utilities
-- (toggles, terminal, lazygit). mini.files stays the explorer; mini.visits
-- stays for frecency data (see mini/visits.lua). neogit owns its own git
-- status/log UI — this spec does not add lazygit/gitbrowse keymaps that
-- would collide with it.

local function get_window_relative_flow_config()
	local win = vim.api.nvim_get_current_win()
	local win_config = vim.api.nvim_win_get_config(win)
	local win_pos = vim.api.nvim_win_get_position(win)
	local win_width = vim.api.nvim_win_get_width(win)
	local win_height = vim.api.nvim_win_get_height(win)

	local editor_width = vim.o.columns
	local editor_height = vim.o.lines

	local win_col = win_pos[2]
	local win_row = win_pos[1]

	if win_config.relative and win_config.relative ~= "" then
		win_col = win_config.col or win_col
		win_row = win_config.row or win_row
	end

	local picker_width = math.min(win_width - 4, math.floor(editor_width * 0.4))
	local picker_height = math.floor(win_height * 0.3)

	local target_col = win_col + math.floor((win_width - picker_width) / 2)
	local target_row = win_row + math.floor(win_height * 0.67)

	if target_col < 0 then
		target_col = 0
	end
	if target_col + picker_width > editor_width then
		target_col = editor_width - picker_width
	end
	if target_row < 0 then
		target_row = 0
	end
	if target_row + picker_height > editor_height then
		target_row = editor_height - picker_height
	end

	return {
		preview = "main",
		layout = {
			backdrop = false,
			col = target_col,
			width = picker_width,
			min_width = 50,
			row = target_row,
			height = picker_height,
			min_height = 10,
			box = "vertical",
			border = "solid",
			title = "{title} {live} {flags}",
			title_pos = "center",
			{ win = "preview", title = "{preview}", width = 0.6, border = "left" },
			{ win = "input", height = 1, border = "solid" },
			{ win = "list", border = "none" },
		},
	}
end

Edit.later(function()
	vim.pack.add({ "git@github.com:folke/snacks.nvim" })

	---@type snacks.Config
	require("snacks").setup({
		bigfile = { enabled = true },
		debug = { enabled = true },
		toggle = { enabled = true },
		gitbrowse = { enabled = true },
		input = { enabled = false },
		scroll = { enabled = false },
		notifier = {
			enabled = false,
			margin = { top = 0, right = 0, bottom = 1, left = 1 },
			style = "compact",
		},
		words = { debounce = 100 },
		lazygit = {
			configure = false,
			win = {
				backdrop = true,
				border = "solid",
				width = 0,
				height = 0,
			},
		},
		terminal = {
			win = {
				border = "solid",
				wo = {
					winbar = "",
				},
			},
		},
		styles = {
			notification_history = {
				border = "solid",
			},
			notification = {
				border = "single",
				wo = {
					winblend = 0,
					winhighlight = "Normal:SnacksNotifierHistory",
				},
			},
		},

		-- https://github.com/folke/snacks.nvim/blob/main/lua/snacks/picker/config/defaults.lua
		-- https://github.com/folke/snacks.nvim/blob/main/lua/snacks/picker/config/sources.lua
		picker = {
			ui_select = true,
			-- Every picker uses the flow layout, positioned relative to the
			-- current window rather than the whole editor.
			layout = get_window_relative_flow_config,
			matcher = {
				cwd_bonus = true,
				frecency = true,
				history_bonus = true,
			},
			formatters = {
				file = {
					filename_first = false,
					truncate = 80,
				},
			},
			previewers = {
				git = {
					native = true,
				},
			},

			win = {
				preview = {
					wo = {
						number = false,
					},
				},
				input = {
					keys = {
						["<c-t>"] = { "edit_tab", mode = { "i", "n" } },
						["<c-u>"] = { "preview_scroll_up", mode = { "i", "n" } },
						["<c-d>"] = { "preview_scroll_down", mode = { "i", "n" } },
					},
				},
				list = {
					keys = {
						["<c-t>"] = "edit_tab",
					},
				},
			},

			sources = {
				files = {
					hidden = true,
				},
				buffers = {
					current = false,
				},
				lsp_references = {
					pattern = "!import !default",
				},
				lsp_symbols = {
					finder = "lsp_symbols",
					format = "lsp_symbol",
					hierarchy = true,
					filter = {
						default = true,
						markdown = true,
						help = true,
					},
				},
				git_status = {
					preview = "git_status",
				},
			},
		},
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "VeryLazy",
		callback = function()
			-- stylua: ignore start
			Snacks.toggle.line_number():map("<leader>aol")
			Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>aoL")
			Snacks.toggle.inlay_hints():map("<leader>aoh")
			Snacks.toggle.treesitter():map("<leader>aoT")
			Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 1 and vim.o.conceallevel or 3 }):map("<leader>aoc")
			Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>aob")
			Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>aos")
			Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>aow")
			-- stylua: ignore end
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "SnacksTerminalClose",
		callback = function()
			vim.defer_fn(function()
				local ok, gitsigns = pcall(require, "gitsigns")
				if ok then
					gitsigns.refresh()
				end
			end, 100)
		end,
	})

	local map = vim.keymap.set
	local dots_path = vim.fn.expand("$HOME") .. "/repos/nikbrunner/dots"

	-- stylua: ignore start
	-- General
	map("n", "<leader>.",   function() Snacks.picker.resume() end, { desc = "Resume Picker" })
	map("n", "<leader>;",   function() Snacks.picker.commands() end, { desc = "Commands" })
	map("n", "<leader>:",   function() Snacks.picker.command_history() end, { desc = "Command History" })
	map("n", "<leader>'",   function() Snacks.picker.registers() end, { desc = "Registers" })

	-- App
	map("n", "<leader><leader>", function() Edit.pickers.smart_files() end, { desc = "Files (smart)" })
	map("n", "<leader>aa",  function() Snacks.picker.commands() end, { desc = "[A]ctions" })
	map("n", "<leader>ag",  function() Snacks.lazygit() end, { desc = "[G]it Module" })
	map("n", "<leader>ad",  function() Snacks.picker.files() end, { desc = "[D]ocument (in project)" })
	map("n", "<leader>ahh", function() Snacks.picker.highlights() end, { desc = "[H]ighlights" })
	map("n", "<leader>ahk", function() Snacks.picker.keymaps() end, { desc = "[K]eymaps" })
	map("n", "<leader>ahm", function() Snacks.picker.man() end, { desc = "[M]anuals" })
	map("n", "<leader>aht", function() Snacks.picker.help() end, { desc = "[T]ags" })
	map("n", "<leader>ar",  function() Snacks.picker.recent() end, { desc = "[R]ecent Documents (Anywhere)" })
	map("n", "<leader>at",  function() Snacks.picker.colorschemes() end, { desc = "[T]hemes" })
	map("n", "<leader>aw",  function() Edit.pickers.project_switch() end, { desc = "[W]orkspace" })
	map("n", "<leader>a,",  function() Snacks.picker.files({ cwd = dots_path }) end, { desc = "[,]Settings (Dots)" })

	-- Workspace
	map("n", "<leader>wd",  function() Snacks.picker.files() end, { desc = "[D]ocuments" })
	map("n", "<leader>wt",  function() Snacks.picker.grep() end, { desc = "[T]ext" })
	map("n", "<leader>wm",  function() Snacks.picker.git_status() end, { desc = "[M]odified files" })
	map("n", "<leader>wp",  function() Snacks.picker.diagnostics() end, { desc = "[P]roblems" })
	map("n", "<leader>wr",  function() Snacks.picker.recent({ filter = { cwd = true } }) end, { desc = "[R]ecent Documents" })
	map("n", "<leader>ws",  function() Snacks.picker.lsp_workspace_symbols() end, { desc = "[S]ymbols" })
	map("n", "<leader>wc",  function() Snacks.picker.git_diff() end, { desc = "[C]hanges" })
	map("n", "<leader>wgb", function() Snacks.picker.git_branches() end, { desc = "[B]ranches" })
	map("n", "<leader>wgh", function() Snacks.picker.git_log() end, { desc = "[H]istory" })
	map("n", "<leader>ww",  function() Edit.pickers.worktree_switch() end, { desc = "[W]orktrees" })

	-- Document
	map("n", "<leader>dr",  function() Edit.pickers.related_documents() end, { desc = "[R]elated Documents" })
	map("n", "<leader>dc",  function() Snacks.picker.git_diff({ path = vim.fn.expand("%") }) end, { desc = "[C]hanges" })
	map("n", "<leader>dj",  function() Edit.pickers.buffer_jumps() end, { desc = "[J]umps" })
	map("n", "<leader>dp",  function() Snacks.picker.diagnostics({ scope = "current" }) end, { desc = "[P]roblems" })
	map("n", "<leader>ds",  function() Snacks.picker.lsp_symbols() end, { desc = "[S]ymbols" })
	map("n", "<leader>dt",  function() Snacks.picker.lines() end, { desc = "[T]ext" })

	-- Symbol
	map("n", "<leader>sr",  function() Snacks.picker.lsp_references() end, { desc = "[R]eferences" })
	map("n", "<leader>si",  function() Snacks.picker.lsp_implementations() end, { desc = "[I]mplementations" })
	-- stylua: ignore end
end)
