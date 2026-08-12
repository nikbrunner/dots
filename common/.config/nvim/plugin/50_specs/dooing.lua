Edit.later(function()
	-- vim.pack.add({ "https://github.com/atiladefreitas/dooing" })
	-- Development: comment line above, uncomment below — no other setup needed:
	vim.opt.rtp:prepend(vim.fn.expand("~/repos/nikbrunner/dooing"))

	local dooing = require("dooing")
	local config = require("dooing.config")
	local data_dir = vim.fn.stdpath("data")
	local dots_dir = vim.env.DOTS_DIR or vim.fn.expand("~/repos/nikbrunner/dots")
	local todo_paths = {
		nikbrunner = dots_dir .. "/todos_nikbrunner.json",
		black_atom = dots_dir .. "/todos_black_atom.json",
		imfusion = data_dir .. "/todos_imfusion.json",
	}

	dooing.setup({
		save_path = todo_paths.nikbrunner,
		ui = {
			style = "modern",
		},
		window = {
			border = "solid", -- Border style
			dimensions = function()
				return {
					width = math.max(40, math.floor(vim.o.columns * 0.65)),
					height = math.max(10, math.floor(vim.o.lines * 0.6)),
				}
			end,
		},
		per_project = {
			default_filename = "todos.json",
		},
		keymaps = {
			toggle_window = false,
			open_project_todo = false,
			new_todo = "c",
			create_nested_task = "a",
			toggle_todo = "<CR>",
			delete_completed = "<leader>D",
			add_due_date = false,
			remove_due_date = false,
			add_time_estimation = false,
			remove_time_estimation = false,
			toggle_priority = "p",
			edit_priorities = "P",
			clear_filter = "X",
			remove_duplicates = false,
			refresh_todos = "R",
			open_todo_scratchpad = "N",
		},
	})

	local function setup_custom_toggles(buf)
		local actions = require("dooing.ui.actions")
		local state = require("dooing.state")
		local utils = require("dooing.ui.utils")

		vim.keymap.set("n", "D", function()
			local todo_index = utils.todo_index_at_cursor()
			local todo = todo_index and state.todos[todo_index]
			if todo and todo.due_at then
				actions.remove_due_date()
			else
				actions.add_due_date()
			end
		end, { buffer = buf, nowait = true, desc = "Toggle due date" })

		vim.keymap.set("n", "T", function()
			local todo_index = utils.todo_index_at_cursor()
			local todo = todo_index and state.todos[todo_index]
			if todo and todo.estimated_hours then
				actions.remove_time_estimation()
			else
				actions.add_time_estimation()
			end
		end, { buffer = buf, nowait = true, desc = "Toggle time estimate" })
	end

	vim.api.nvim_create_autocmd("BufEnter", {
		group = vim.api.nvim_create_augroup("dooing-custom-keymaps", {}),
		callback = function(event)
			local constants = require("dooing.ui.constants")
			if event.buf == constants.buf_id then
				setup_custom_toggles(event.buf)
			end
		end,
	})

	local function open_todos(scope, title)
		config.options.save_path = todo_paths[scope]
		dooing.open_global_todo()
		require("dooing.state").current_context = title
		require("dooing.ui.window").update_window_title()
	end

	vim.keymap.set("n", "<leader>tn", function()
		open_todos("nikbrunner", "Private")
	end, { desc = "Open private todo list" })

	vim.keymap.set("n", "<leader>tb", function()
		open_todos("black_atom", "Black Atom")
	end, { desc = "Open Black Atom todo list" })

	vim.keymap.set("n", "<leader>ti", function()
		open_todos("imfusion", "ImFusion")
	end, { desc = "Open ImFusion todo list" })

	vim.keymap.set("n", "<leader>tp", function()
		dooing.open_project_todo()
	end, { desc = "Open project todo list" })
end)
