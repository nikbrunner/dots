Edit.later(function()
	vim.pack.add({
		{
			src = "https://github.com/obsidian-nvim/obsidian.nvim",
			version = vim.version.range("*"),
		},
		{ src = "https://github.com/Dzejkop/datepicker.nvim" },
	})

	local vault = vim.fn.expand("~/repos/nikbrunner/notes")

	local function read_json(path)
		local file = assert(io.open(path, "r"))
		local content = file:read("*a")
		file:close()

		local ok, result = pcall(vim.json.decode, content)
		assert(ok, string.format("Could not decode Obsidian settings '%s': %s", path, result))
		vim.validate(path, result, "table")
		return result
	end

	local daily_path = vim.fs.joinpath(vault, ".obsidian", "daily-notes.json")
	local templates_path = vim.fs.joinpath(vault, ".obsidian", "templates.json")
	local daily_settings = read_json(daily_path)
	local template_settings = read_json(templates_path)

	vim.validate(daily_path .. ".folder", daily_settings.folder, "string")
	vim.validate(daily_path .. ".format", daily_settings.format, "string")
	vim.validate(daily_path .. ".template", daily_settings.template, "string", true)
	vim.validate(templates_path .. ".folder", template_settings.folder, "string")
	vim.validate(templates_path .. ".dateFormat", template_settings.dateFormat, "string")
	vim.validate(templates_path .. ".timeFormat", template_settings.timeFormat, "string", true)

	local daily_folder = daily_settings.folder
	local daily_format = daily_settings.format
	local daily_root = vim.fs.joinpath(vault, daily_folder)
	local daily_template = daily_settings.template
	if daily_template then
		daily_template = vim.fs.joinpath(vault, daily_template)
	end

	local templates = {
		folder = template_settings.folder,
		date_format = template_settings.dateFormat,
	}
	local time_format = template_settings.timeFormat
	if time_format then
		templates.time_format = time_format
	end
	templates.substitutions = {
		date = function(ctx, suffix)
			local timestamp = os.time()
			if ctx.destination_path then
				local relative_path = vim.fs.relpath(daily_root, tostring(ctx.destination_path))
				if relative_path then
					relative_path = relative_path:gsub("%.md$", "")
					local date, parse_error = require("obsidian.lib.moment").parse(relative_path, daily_format)
					if not date then
						error(
							string.format(
								"Could not parse daily note path '%s' with format '%s': %s",
								relative_path,
								daily_format,
								parse_error
							)
						)
					end
					timestamp = os.time(date)
				end
			end

			return require("obsidian.util").format_date(timestamp, suffix or templates.date_format)
		end,
	}

	vim.g.obsidian_default_keymap = false

	require("obsidian").setup({
		legacy_commands = false,
		workspaces = {
			{ name = "notes", path = vault },
		},
		picker = { name = "snacks.picker" },
		templates = templates,
		daily_notes = {
			folder = daily_folder,
			date_format = daily_format,
			template = daily_template,
			default_tags = {},
		},
		checkbox = { enabled = false },
		ui = { enable = false },
		frontmatter = { enabled = false },
		callbacks = {
			enter_note = function(note)
				vim.b[note.bufnr].vin_autoformat_disabled = true
			end,
			post_setup = function()
				local bufnr = vim.api.nvim_get_current_buf()
				local path = vim.api.nvim_buf_get_name(bufnr)
				if path ~= "" and vim.fs.relpath(vault, path) then
					vim.b[bufnr].vin_autoformat_disabled = true
				end
			end,
		},
	})

	local function open_daily(opts)
		local note = require("obsidian.daily").daily(opts)
		if not note:exists() then
			note:write()
		end
		note:open()
	end

	local map = vim.keymap.set
	map("n", "<leader>nt", function()
		open_daily()
	end, { desc = "[T]oday" })
	map("n", "<leader>nh", function()
		open_daily({ offset = -1 })
	end, { desc = "Previous day" })
	map("n", "<leader>nl", function()
		open_daily({ offset = 1 })
	end, { desc = "Next day" })
	map("n", "<leader>nd", "<cmd>Obsidian dailies<cr>", { desc = "[D]ailies" })
	map("n", "<leader>nk", function()
		require("datepicker").open({
			title = "Daily note",
			week_start = "monday",
			on_select = function(date)
				open_daily({ date = date.timestamp })
			end,
		})
	end, { desc = "[K]alendar" })
end)
