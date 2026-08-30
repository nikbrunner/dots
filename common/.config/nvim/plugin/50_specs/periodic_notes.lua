Edit.later(function()
	vim.pack.add({ "https://github.com/wsdjeg/calendar.nvim" })

	local vault = vim.fn.expand("~/repos/nikbrunner/notes")
	local log_root = vim.fs.joinpath(vault, "Log")
	local month_names = {
		"January",
		"February",
		"March",
		"April",
		"May",
		"June",
		"July",
		"August",
		"September",
		"October",
		"November",
		"December",
	}
	local weekday_names = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" }

	local function date_parts(year, month, day)
		local date = os.time({ year = year, month = month, day = day, hour = 12 })
		return {
			year = year,
			month = month,
			day = day,
			month_name = month_names[month],
			weekday_name = weekday_names[tonumber(os.date("%w", date)) + 1],
		}
	end

	local function periodic_note(kind, year, month, day)
		local date = date_parts(year, month, day)
		local year_name = string.format("%04d", date.year)
		local month_name = string.format("%04d.%02d", date.year, date.month)
		local folder = vim.fs.joinpath(log_root, year_name, month_name)

		if kind == "daily" then
			local name = string.format("%s.%02d - %s.md", month_name, date.day, date.weekday_name)
			return vim.fs.joinpath(folder, name), name:sub(1, -4)
		end

		if kind == "monthly" then
			local name = string.format("%s - %s.md", month_name, date.month_name)
			return vim.fs.joinpath(folder, name), name:sub(1, -4)
		end

		local name = year_name .. ".md"
		return vim.fs.joinpath(log_root, year_name, name), year_name
	end

	local function note_content(title)
		return table.concat({
			"---",
			"aliases: []",
			"tags: []",
			'date created: "' .. os.date("%Y-%m-%dT%H:%M:%S") .. '"',
			"date modified:",
			"---",
			"",
			"# " .. title,
			"",
		}, "\n")
	end

	local function open_or_create(path, title)
		if vim.uv.fs_stat(path) == nil then
			vim.fn.mkdir(vim.fs.dirname(path), "p")
			local file, err = io.open(path, "w")
			if not file then
				vim.notify(string.format("Could not create periodic note '%s': %s", path, err), vim.log.levels.ERROR)
				return
			end
			file:write(note_content(title))
			file:close()
		end

		pcall(function()
			require("calendar.view").close()
		end)
		vim.cmd.edit(vim.fn.fnameescape(path))
	end

	local periodic_notes = {
		get = function()
			return {}
		end,
		actions = {
			Daily = function(year, month, day)
				local path, title = periodic_note("daily", year, month, day)
				open_or_create(path, title)
			end,
			Monthly = function(year, month, day)
				local path, title = periodic_note("monthly", year, month, day)
				open_or_create(path, title)
			end,
			Yearly = function(year, month, day)
				local path, title = periodic_note("yearly", year, month, day)
				open_or_create(path, title)
			end,
		},
	}

	require("calendar").setup({
		locale = "en-US",
		show_adjacent_days = true,
	})
	require("calendar.extensions").register("Periodic", periodic_notes)

	vim.keymap.set("n", "<leader>nk", function()
		require("calendar").open()
	end, { desc = "[K]alendar" })
end)
